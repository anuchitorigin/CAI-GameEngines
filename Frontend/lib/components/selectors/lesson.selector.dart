import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';

import 'package:cai_gameengine/constansts/doccument_status.const.dart';

import 'package:cai_gameengine/components/common/image_thumbnail.widget.dart';
import 'package:cai_gameengine/components/common/tag.chip.dart';

import 'package:cai_gameengine/services/loading_dialog.service.dart';

import 'package:cai_gameengine/api/module.api.dart';
import 'package:cai_gameengine/api/bucket.api.dart';

import 'package:cai_gameengine/models/api_result.model.dart';
import 'package:cai_gameengine/models/login_session.model.dart';
import 'package:cai_gameengine/models/lesson.model.dart';
import 'package:cai_gameengine/models/bucket.model.dart';
import 'package:visibility_detector/visibility_detector.dart';

class LessonSelector extends StatefulWidget {
  const LessonSelector({super.key, required this.inModuleID});

  final int inModuleID;

  @override
  State<LessonSelector> createState() => _LessonSelectorState();
}

class _LessonSelectorState extends State<LessonSelector> {
  List<LessonModel> lessons = [];
  LessonModel? currentLesson;

  bool isLoading = true;

  int currentPage = 0;
  int totalLessons = 0;

  late LoginSessionModel loginSession;
  late BoxConstraints globalConstraints;
  late ColorScheme colorScheme;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final LoadingDialogService loading = LoadingDialogService();
      // ignore: use_build_context_synchronously
      loading.presentLoading(context);

      loginSession = context.read<LoginSessionModel>();

      await getTotalLessonCount();
      await loadLessons();

      // ignore: use_build_context_synchronously
      context.pop();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  getTotalLessonCount() async {
    if(loginSession.token.isNotEmpty) {
      final ModuleAPI moduleAPI = ModuleAPI();

      APIResult resCount = await moduleAPI.readLessonCount(loginSession.token, widget.inModuleID, null, null, null, []);

      if(resCount.status == 1 && resCount.result[0].RecordCount > 0) {
        totalLessons = resCount.result[0].RecordCount;
      } else {
        if(mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  loadLessons() async {
    if(loginSession.token.isNotEmpty && totalLessons > 0) {
      final ModuleAPI moduleAPI = ModuleAPI();

      currentPage++;
      APIResult resItemFilter = await moduleAPI.readLessonFilter(loginSession.token, 10, currentPage, "", widget.inModuleID, null, null, null, []);
      if(resItemFilter.status == 1) {
        lessons.addAll(resItemFilter.result as List<LessonModel>);
      }

      if(mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<Widget> getCover(String bucketid, String name) async {
    final BucketAPI bucketAPI = BucketAPI();
    final APIResult res = await bucketAPI.readOne(loginSession.token, bucketid);

    if(res.status == 1) {
      final bucket = res.result[0] as BucketModel;

      final String? mimeType = lookupMimeType(bucket.bucketname);
      final Uint8List  mediaBytes = bucket.bucketdata.data;

      if(mimeType!.startsWith('image/')) {
        return ImageThumbnailWidget(image: Image.memory(mediaBytes), title: name);
      } else {
        return Container();
      }
    } else {
      return Container();
    }
  }

  Future<Widget> getMedia(String bucketid) async {
    final BucketAPI bucketAPI = BucketAPI();
    final APIResult res = await bucketAPI.readOne(loginSession.token, bucketid);

    if(res.status == 1) {
      final bucket = res.result[0] as BucketModel;

      final String? mimeType = lookupMimeType(bucket.bucketname);
      final Uint8List  mediaBytes = bucket.bucketdata.data;

      if(mimeType!.startsWith('image/')) {
        return ImageThumbnailWidget(image: Image.memory(mediaBytes));
      } else if(mimeType.contains('audio/')) {
        return buildAudioPlayer(bucketid, mimeType);
      } else if(mimeType.contains('video/')) {
        return buildVideoPlayer(bucketid, mimeType);
      } else if(mimeType.contains('application/pdf')) {
        return buildPDFLink(bucketid);
      } else if(mimeType.contains('application/msword') || mimeType.contains('application/vnd.openxmlformats-officedocument.wordprocessingml.document')) {
        return buildMSWordLink(bucketid, mimeType);
      } else if(mimeType.contains('application/vnd.ms-excel') || mimeType.contains('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')) {
        return buildMSExcelLink(bucketid, mimeType);
      } else if(mimeType.contains('application/vnd.ms-powerpoint') || mimeType.contains('application/vnd.openxmlformats-officedocument.presentationml.presentation')) {
        return buildMSPowerpointLink(bucketid, mimeType);
      } else {
        return ImageThumbnailWidget(image: Image.asset('assets/images/default_picture.png',));
      }
    } else {
      return ImageThumbnailWidget(image: Image.asset('assets/images/default_picture.png',));
    }
  }

  buildAudioPlayer(String bucketid, String mimeType) {
    return Material(
      borderRadius: BorderRadius.circular(10.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: () async {
          final LoadingDialogService loading = LoadingDialogService();
          loading.presentLoading(context);

          final BucketAPI bucketAPI = BucketAPI();
          final APIResult res = await bucketAPI.readOne(loginSession.token, bucketid);

          // ignore: use_build_context_synchronously
          context.pop();

          final String id = 'audio-$bucketid';
          if(res.status == 1) {
            final bucket = res.result[0] as BucketModel;

            final String? mimeType = lookupMimeType(bucket.bucketname);
            final Uint8List  mediaBytes = bucket.bucketdata.data;

            final sourceElement = html.SourceElement();
            sourceElement.type = mimeType!;
            sourceElement.src = Uri.dataFromBytes(mediaBytes.toList(), mimeType: mimeType).toString();

            final audioElement = html.AudioElement();
            audioElement.controls = true;
            audioElement.children = [sourceElement];
            audioElement.style.height = '100%';
            audioElement.style.width = '100%';

            ui_web.platformViewRegistry.registerViewFactory(id, (int viewId) => audioElement);
          }

          // ignore: use_build_context_synchronously
          showDialog(context: context, builder: (context) {
            return Dialog.fullscreen(
              backgroundColor: Colors.transparent,
              child: InkWell(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () {
                  context.pop();
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isLg = globalConstraints.maxWidth > 992;

                    final playerWidth = isLg ? globalConstraints.maxWidth * 0.4 : globalConstraints.maxWidth * 0.7;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Wrap(
                            direction: Axis.horizontal,
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainer,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: playerWidth,
                                      height: 50,
                                      child: HtmlElementView(viewType: id),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                ),
              )
            );
          });
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: const Icon(Icons.audiotrack),
        ),
      ),
    );
  }

  buildVideoPlayer(String bucketid, String mimeType) {
    return Material(
      borderRadius: BorderRadius.circular(10.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: () async {
          final LoadingDialogService loading = LoadingDialogService();
          loading.presentLoading(context);

          final BucketAPI bucketAPI = BucketAPI();
          final APIResult res = await bucketAPI.readOne(loginSession.token, bucketid);

          // ignore: use_build_context_synchronously
          context.pop();

          final String id = 'video-$bucketid';
          if(res.status == 1) {
            final bucket = res.result[0] as BucketModel;

            final String? mimeType = lookupMimeType(bucket.bucketname);
            final Uint8List  mediaBytes = bucket.bucketdata.data;

            final sourceElement = html.SourceElement();
            sourceElement.type = mimeType!;
            sourceElement.src = Uri.dataFromBytes(mediaBytes.toList(), mimeType: mimeType).toString();

            final videoElement = html.VideoElement();
            videoElement.controls = true;
            videoElement.children = [sourceElement];
            videoElement.style.height = '100%';
            videoElement.style.width = '100%';

            ui_web.platformViewRegistry.registerViewFactory(id, (int viewId) => videoElement);
          }

          // ignore: use_build_context_synchronously
          showDialog(context: context, builder: (context) {
            return Dialog.fullscreen(
              backgroundColor: Colors.transparent,
              child: InkWell(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () {
                  context.pop();
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Wrap(
                            direction: Axis.horizontal,
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainer,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: constraints.maxWidth - 40,
                                      height: constraints.maxHeight - 170,
                                      child: HtmlElementView(viewType: id),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                ),
              )
            );
          });
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: const Icon(Icons.ondemand_video),
        ),
      ),
    );
  }

  buildPDFLink(String bucketid) {
    return Material(
      borderRadius: BorderRadius.circular(10.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: () async {
          final LoadingDialogService loading = LoadingDialogService();
          loading.presentLoading(context);

          final BucketAPI bucketAPI = BucketAPI();
          final APIResult res = await bucketAPI.readOne(loginSession.token, bucketid);

          // ignore: use_build_context_synchronously
          context.pop();

          if(res.status == 1) {
            final bucket = res.result[0] as BucketModel;

            final Uint8List  mediaBytes = bucket.bucketdata.data;

            final blob = html.Blob([mediaBytes], 'application/pdf');
            final url = html.Url.createObjectUrlFromBlob(blob);
            html.window.open(url, '_blank');
            html.Url.revokeObjectUrl(url);
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.asset('assets/images/pdf.png',),
        ),
      ),
    );
  }

  buildMSWordLink(String bucketid, String mimeType) {
    return Material(
      borderRadius: BorderRadius.circular(10.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: () async {
          final LoadingDialogService loading = LoadingDialogService();
          loading.presentLoading(context);

          final BucketAPI bucketAPI = BucketAPI();
          final APIResult res = await bucketAPI.readOne(loginSession.token, bucketid);

          // ignore: use_build_context_synchronously
          context.pop();

          if(res.status == 1) {
            final bucket = res.result[0] as BucketModel;

            final Uint8List  mediaBytes = bucket.bucketdata.data;

            final blob = html.Blob([mediaBytes], mimeType);
            final url = html.Url.createObjectUrlFromBlob(blob);
            html.window.open(url, '_blank');
            html.Url.revokeObjectUrl(url);
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.asset('assets/images/ms-word.png',),
        ),
      ),
    );
  }

  buildMSExcelLink(String bucketid, String mimeType) {
    return Material(
      borderRadius: BorderRadius.circular(10.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: () async {
          final LoadingDialogService loading = LoadingDialogService();
          loading.presentLoading(context);

          final BucketAPI bucketAPI = BucketAPI();
          final APIResult res = await bucketAPI.readOne(loginSession.token, bucketid);

          // ignore: use_build_context_synchronously
          context.pop();

          if(res.status == 1) {
            final bucket = res.result[0] as BucketModel;

            final Uint8List  mediaBytes = bucket.bucketdata.data;

            final blob = html.Blob([mediaBytes], mimeType);
            final url = html.Url.createObjectUrlFromBlob(blob);
            html.window.open(url, '_blank');
            html.Url.revokeObjectUrl(url);
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.asset('assets/images/ms-excel.png',),
        ),
      ),
    );
  }

  buildMSPowerpointLink(String bucketid, String mimeType) {
    return Material(
      borderRadius: BorderRadius.circular(10.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: () async {
          final LoadingDialogService loading = LoadingDialogService();
          loading.presentLoading(context);

          final BucketAPI bucketAPI = BucketAPI();
          final APIResult res = await bucketAPI.readOne(loginSession.token, bucketid);

          // ignore: use_build_context_synchronously
          context.pop();

          if(res.status == 1) {
            final bucket = res.result[0] as BucketModel;

            final Uint8List  mediaBytes = bucket.bucketdata.data;

            final blob = html.Blob([mediaBytes], mimeType);
            final url = html.Url.createObjectUrlFromBlob(blob);
            html.window.open(url, '_blank');
            html.Url.revokeObjectUrl(url);
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.asset('assets/images/ms-powerpoint.png',),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      colorScheme = Theme.of(context).colorScheme;
    });

    return Dialog(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final listHeight = constraints.maxHeight * 0.64;

          final isLg = constraints.maxWidth > 992;
          final isMd = constraints.maxWidth > 768;
          final isSm = constraints.maxWidth > 576;

          final dialogWidth = isLg ? constraints.maxWidth * 0.6 : (isMd ? constraints.maxWidth * 0.7 : (isSm ? constraints.maxWidth * 0.9 : constraints.maxWidth * 0.95));

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: SizedBox(
                width: dialogWidth,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_note, size: 30, color: colorScheme.primary,),
                            const Text(' เลือกบทเรียน', style: TextStyle(fontSize: 30,),),
                          ],
                        ),
                        IconButton(
                          style: IconButton.styleFrom(
                            side: BorderSide(color: colorScheme.onSecondary),
                            backgroundColor: colorScheme.secondary
                          ),
                          onPressed: () {
                            context.pop();
                          },
                          icon: Icon(Icons.close, color: colorScheme.onSecondary,),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, left: 10, bottom: 0, right: 10),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('รายชื่อบทเรียน', style: TextStyle(fontSize: 14),),
                                Container(
                                  width: double.maxFinite,
                                  height: listHeight,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: colorScheme.onSurface,
                                      width: 1,
                                    ),
                                  ),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Builder(
                                          builder: (BuildContext context) {
                                            if(lessons.isNotEmpty) {
                                              return Flex(
                                                direction: Axis.vertical,
                                                children: buildLessonList(lessons, double.maxFinite),
                                              );
                                            } else if(!isLoading) {
                                              return Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: double.maxFinite,
                                                    padding: const EdgeInsets.all(10),
                                                    decoration: BoxDecoration(
                                                      color: colorScheme.secondaryContainer,
                                                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text('ไม่พบบทเรียนตามเงื่อนไขการค้นหา', style: TextStyle(color: colorScheme.onSecondaryContainer, fontSize: 18))
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              );
                                            } else {
                                              return Container();
                                            }
                                          },
                                        ),
                                        Visibility(
                                          visible: isLoading,
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              CircularProgressIndicator(),
                                            ],
                                          ),
                                        ),
                                        Builder(
                                          builder: (BuildContext context) {
                                            if(lessons.length < totalLessons) {
                                              return VisibilityDetector(
                                                key: const Key('LessonInfiniteScroll'),
                                                onVisibilityChanged: (visibilityInfo) {
                                                  var visiblePercentage = visibilityInfo.visibleFraction * 100;

                                                  if(visiblePercentage > 50) {
                                                    setState(() {
                                                      isLoading = true;
                                                    });

                                                    loadLessons();
                                                  }
                                                },
                                                child: const SizedBox(width: double.maxFinite, height: 60,),
                                              );
                                            } else {
                                              return Container();
                                            }
                                          }
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: double.infinity,
                      height: 25,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
                          ),
                          onPressed: currentLesson != null ? () {
                            context.pop(currentLesson);
                          } : null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_note, size: 22, color: colorScheme.onPrimary,),
                              Text(' ยืนยัน', style: TextStyle(fontSize: 20, color: colorScheme.onPrimary,),),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.secondary,
                            padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
                          ),
                          onPressed: () {
                            context.pop();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.close, size: 22, color: colorScheme.onSecondary,),
                              Text(' ปิด', style: TextStyle(fontSize: 20, color: colorScheme.onSecondary,),),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          );
        }
      ),
    );
  }

  List<Widget> buildLessonList(List<LessonModel> lessonList, double cardWidth) {
    List<Widget> lessonWidgetList = [];

    final Duration timezoneOffset = DateTime.now().timeZoneOffset;

    for(final lesson in lessonList) {
      Future<Widget> coverWidget;
      if(lesson.coverid != null && lesson.coverid!.isNotEmpty) {
        coverWidget = getCover(lesson.coverid!, lesson.title);
      } else {
        coverWidget = Future.value(ImageThumbnailWidget(image: Image.asset('assets/images/default_picture.png',), title: lesson.title));
      }

      Future<Widget> mediaWidget;
      if(lesson.mediaid != null && lesson.mediaid!.isNotEmpty) {
        mediaWidget = getMedia(lesson.mediaid!);
      } else {
        mediaWidget = Future.value(ImageThumbnailWidget(image: Image.asset('assets/images/default_picture.png',)));
      }

      lessonWidgetList.addAll([
        Material(
          color: currentLesson == lesson ? colorScheme.tertiaryContainer : colorScheme.secondaryContainer,
          child: InkWell(
            onTap: () {
              setState(() {
                currentLesson = lesson;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(lesson.lessonno.toString(), overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 9,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                          child: FutureBuilder<Widget>(
                                            future: coverWidget,
                                            builder: (context, AsyncSnapshot coverSnapshot) {
                                              if(coverSnapshot.hasData) {
                                                return coverSnapshot.data!;
                                              } else {
                                                return Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width: 60,
                                                      height: 60,
                                                      child: CircularProgressIndicator(
                                                        color: colorScheme.secondary,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }
                                            }
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(lesson.title, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14,),),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  lesson.becancelled ?
                                  Icon(Icons.cancel, color: colorScheme.error) :
                                  (!lesson.belocked ?
                                  Icon(Icons.lock_open, color: colorScheme.brightness == Brightness.light ? const Color( 0xFF009000 ) : const Color( 0xFF0FF000 ),) :
                                  Icon(Icons.lock_outline, color: colorScheme.error)),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          thickness: 0.5,
                          color: colorScheme.onSurface,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('รายละเอียด', style: TextStyle(color: colorScheme.tertiary, fontSize: 12, fontWeight: FontWeight.bold),),
                                  Text(lesson.descr ?? '-', style: const TextStyle(fontSize: 14,),),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          thickness: 0.5,
                          color: colorScheme.onSurface,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('วันที่สร้าง', style: TextStyle(color: colorScheme.tertiary, fontSize: 12, fontWeight: FontWeight.bold),),
                                  Row(
                                    children: [
                                      Text(DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.parse(lesson.created_at).add(timezoneOffset)), style: const TextStyle(fontSize: 14,),),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('วันที่แก้ไขล่าสุด', style: TextStyle(color: colorScheme.tertiary, fontSize: 12, fontWeight: FontWeight.bold),),
                                  Row(
                                    children: [
                                      Text(lesson.updated_at != null ? DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.parse(lesson.updated_at!).add(timezoneOffset)) : '-', style: const TextStyle(fontSize: 14,),),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          thickness: 0.5,
                          color: colorScheme.onSurface,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text('สื่อประกอบการสอน', style: TextStyle(color: colorScheme.tertiary, fontSize: 12, fontWeight: FontWeight.bold),),
                                        Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                          child: FutureBuilder<Widget>(
                                            future: mediaWidget,
                                            builder: (context, AsyncSnapshot mediaSnapshot) {
                                              if(mediaSnapshot.hasData) {
                                                return mediaSnapshot.data!;
                                              } else {
                                                return Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width: 60,
                                                      height: 60,
                                                      child: CircularProgressIndicator(
                                                        color: colorScheme.secondary,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }
                                            }
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('ป้ายกำกับ', style: TextStyle(color: colorScheme.tertiary, fontSize: 12, fontWeight: FontWeight.bold),),
                                  lesson.tags.isNotEmpty ?
                                    Wrap(
                                      runSpacing: 3,
                                      children: [
                                        ...lesson.tags.map((e) => TagChip(tag: e)) 
                                      ],
                                    ) :
                                    const SizedBox(
                                      height: 20,
                                    )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          thickness: 0.5,
                          color: colorScheme.onSurface,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('สถานะ', style: TextStyle(color: colorScheme.tertiary, fontSize: 12, fontWeight: FontWeight.bold),),
                                  Text(DocStatus.entries.firstWhere((e) => e.key == lesson.docstatus).value, style: const TextStyle(fontSize: 14,),),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('วันที่เผยแพร่', style: TextStyle(color: colorScheme.tertiary, fontSize: 12, fontWeight: FontWeight.bold),),
                                  Text(lesson.released_at != null ? DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.parse(lesson.released_at!).add(timezoneOffset)) : '-', style: const TextStyle(fontSize: 14,),),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ]);
    }

    return lessonWidgetList;
  }

}