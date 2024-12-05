import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'package:cai_gameengine/constansts/doccument_status.const.dart';

import 'package:cai_gameengine/data/module/details/lesson.dialog.dart';
import 'package:cai_gameengine/data/module/details/lesson_content.dialog.dart';
import 'package:cai_gameengine/components/common/image_thumbnail.widget.dart';
import 'package:cai_gameengine/components/common/tag.chip.dart';

import 'package:cai_gameengine/api/module.api.dart';
import 'package:cai_gameengine/api/bucket.api.dart';
import 'package:cai_gameengine/api/content.api.dart';

import 'package:cai_gameengine/services/loading_dialog.service.dart';
import 'package:cai_gameengine/services/success_snackbar.service.dart';
import 'package:cai_gameengine/services/failure_dialog.service.dart';

import 'package:cai_gameengine/models/api_result.model.dart';
import 'package:cai_gameengine/models/login_session.model.dart';
import 'package:cai_gameengine/models/module.model.dart';
import 'package:cai_gameengine/models/lesson.model.dart';
import 'package:cai_gameengine/models/bucket.model.dart';

class ModuleDetailsPage extends StatefulWidget {
  const ModuleDetailsPage({super.key, required this.moduleID});

  final int moduleID;

  @override
  State<ModuleDetailsPage> createState() => _ModuleDetailsPageState();
}

class _ModuleDetailsPageState extends State<ModuleDetailsPage> {
  ModuleModel? module;
  List<LessonModel> lessons = [];

  bool isLoading = false;

  int currentPage = 0;
  int totalLessons = 0;

  final formatter = NumberFormat("#,##0.00", "en_US");

  late double cardWidth;

  late LoginSessionModel loginSession;
  late BoxConstraints globalConstraints;
  late ColorScheme colorScheme;

  @override
  void initState() {
    super.initState();

    final LoadingDialogService loading = LoadingDialogService();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      loading.presentLoading(context);

      loginSession = context.read<LoginSessionModel>();

      await loadModule();
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

  loadModule() async {
    if(loginSession.token.isNotEmpty) {
      final ModuleAPI moduleAPI = ModuleAPI();

      APIResult resOne = await moduleAPI.readOne(loginSession.token, widget.moduleID);
      if(resOne.status == 1) {
        module = resOne.result[0] as ModuleModel;
      }
    }
  }

  getTotalLessonCount() async {
    if(loginSession.token.isNotEmpty) {
      final ModuleAPI moduleAPI = ModuleAPI();

      APIResult resCount = await moduleAPI.readLessonCount(loginSession.token, widget.moduleID, null, null, null, []);

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
      APIResult resItemFilter = await moduleAPI.readLessonFilter(loginSession.token, 10, currentPage, "", widget.moduleID, null, null, null, []);
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

    return SingleChildScrollView(
      child: LayoutBuilder(
        builder: (context, BoxConstraints constraints) {
          globalConstraints = constraints;

          final isLg = globalConstraints.maxWidth > 992;
          final isMd = globalConstraints.maxWidth > 768;
          final isSm = globalConstraints.maxWidth > 576;

          final cardWidth = isLg ? globalConstraints.maxWidth * 0.5 : (isMd ? globalConstraints.maxWidth * 0.7 : (isSm ? globalConstraints.maxWidth * 0.8 : globalConstraints.maxWidth * 0.9));
          final itemCardWidth = isLg ? globalConstraints.maxWidth * 0.65 : (isMd ? globalConstraints.maxWidth * 0.75 : (isSm ? globalConstraints.maxWidth * 0.85 : globalConstraints.maxWidth * 0.95));

          return Builder(
            builder: (context) {
              if(module != null) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            iconSize: 30,
                            style: IconButton.styleFrom(
                              side: BorderSide(color: colorScheme.secondary),
                              backgroundColor: colorScheme.secondary
                            ),
                            onPressed: () {
                              context.go('/dat-module');
                            },
                            icon: Icon(Icons.arrow_circle_left_outlined, color: colorScheme.onSecondary,),
                          ),
                          Text(module!.title, style: const TextStyle(fontSize: 36),),
                          Container(),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: cardWidth,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('รหัสโมดูล', style: TextStyle(color: colorScheme.tertiary, fontSize: 12, fontWeight: FontWeight.bold),),
                                      Text(module!.modulecode, style: const TextStyle(fontSize: 14,),),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('คำชี้แจง', style: TextStyle(color: colorScheme.tertiary, fontSize: 12, fontWeight: FontWeight.bold),),
                                      Text(module!.caption, style: const TextStyle(fontSize: 14,),),
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
                                      Text(module!.descr ?? '-', style: const TextStyle(fontSize: 14,),),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: itemCardWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                lessonDialog(module!.id);
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(15),
                                backgroundColor: colorScheme.primary,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_circle_outline, color: colorScheme.onPrimary,),
                                  Text(' เพิ่มบทเรียน', style: TextStyle(fontSize: 16, color: colorScheme.onPrimary,),),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        width: itemCardWidth,
                        child: Builder(
                          builder: (BuildContext context) {
                            if(lessons.isNotEmpty) {
                              final Duration timezoneOffset = DateTime.now().timeZoneOffset;

                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: lessons.length,
                                itemBuilder: (context, index) {
                                  Future<Widget> coverWidget;
                                  if(lessons[index].coverid != null && lessons[index].coverid!.isNotEmpty) {
                                    coverWidget = getCover(lessons[index].coverid!, lessons[index].title);
                                  } else {
                                    coverWidget = Future.value(ImageThumbnailWidget(image: Image.asset('assets/images/default_picture.png',), title: lessons[index].title));
                                  }

                                  Future<Widget> mediaWidget;
                                  if(lessons[index].mediaid != null && lessons[index].mediaid!.isNotEmpty) {
                                    mediaWidget = getMedia(lessons[index].mediaid!);
                                  } else {
                                    mediaWidget = Future.value(ImageThumbnailWidget(image: Image.asset('assets/images/default_picture.png',)));
                                  }

                                  return Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: colorScheme.tertiaryContainer,
                                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 30,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text(lessons[index].lessonno.toString(), overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
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
                                                                Text(lessons[index].title, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14,),),
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
                                                            lessons[index].becancelled ?
                                                            Icon(Icons.cancel, color: colorScheme.error) :
                                                            (!lessons[index].belocked ?
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
                                                            Text(lessons[index].descr ?? '-', style: const TextStyle(fontSize: 14,),),
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
                                                                Text(DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.parse(lessons[index].created_at).add(timezoneOffset)), style: const TextStyle(fontSize: 14,),),
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
                                                                Text(lessons[index].updated_at != null ? DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.parse(lessons[index].updated_at!).add(timezoneOffset)) : '-', style: const TextStyle(fontSize: 14,),),
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
                                                            lessons[index].tags.isNotEmpty ?
                                                              Wrap(
                                                                runSpacing: 3,
                                                                children: [
                                                                  ...lessons[index].tags.map((e) => TagChip(tag: e)) 
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
                                                            Text(DocStatus.entries.firstWhere((e) => e.key == lessons[index].docstatus).value, style: const TextStyle(fontSize: 14,),),
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
                                                            Text(lessons[index].released_at != null ? DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.parse(lessons[index].released_at!).add(timezoneOffset)) : '-', style: const TextStyle(fontSize: 14,),),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Divider(
                                                    thickness: 1.0,
                                                    color: colorScheme.onSurface,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      ElevatedButton(
                                                        onPressed: () async {
                                                          contentDialog(lessons[index]);
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          shape: const CircleBorder(),
                                                          padding: const EdgeInsets.all(15),
                                                          backgroundColor: colorScheme.tertiary,
                                                        ),
                                                        child: Icon(Icons.edit_note, color: colorScheme.onTertiary,),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () async {
                                                          lessonDialog(module!.id, id: lessons[index].id);
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          shape: const CircleBorder(),
                                                          padding: const EdgeInsets.all(15),
                                                          backgroundColor: colorScheme.primary,
                                                        ),
                                                        child: Icon(Icons.edit_square, color: colorScheme.onPrimary,),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          confirmDeleteLessonDialog(lessons[index]);
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          shape: const CircleBorder(),
                                                          padding: const EdgeInsets.all(15),
                                                          backgroundColor: colorScheme.error,
                                                        ),
                                                        child: Icon(Icons.delete_forever_rounded, color: colorScheme.onError,),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  );
                                }
                              );
                            } else {
                              return Container(
                                width: double.maxFinite,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: colorScheme.tertiaryContainer,
                                  border: Border(bottom: BorderSide(width: 0.5, color: colorScheme.onSurface)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('ไม่พบบทเรียน', style: TextStyle(fontSize: 16, color: colorScheme.onTertiaryContainer),),
                                    ],
                                  ),
                                ),
                              );
                            }
                          }
                        ),
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
                          if(totalLessons > 0 && lessons.length < totalLessons) {
                            return VisibilityDetector(
                              key: const Key('RecipeItemInfiniteScroll'),
                              onVisibilityChanged: (visibilityInfo) {
                                var visiblePercentage = visibilityInfo.visibleFraction * 100;

                                if(visiblePercentage > 50) {
                                  setState(() {
                                    isLoading = true;
                                  });

                                  loadLessons();
                                }
                              },
                              child: const SizedBox(width: 100, height: 50,),
                            );
                          } else {
                            return Container();
                          }
                        }
                      ),
                    ],
                  ),
                );
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
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
            },
          );
        }
      ),
    );
  }

  contentDialog(LessonModel item) async {
    final String? contentid = await showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return LessonContentDialog(inLesson: item);
      },
    );

    if(contentid != null) {
      item.contentid = contentid;
    }
  }

  lessonDialog(int inModuleID, { int? id }) async {
    final isSuccess = await showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return LessonDialog(inModuleID: inModuleID, inID: id);
      },
    );

    if(isSuccess != null && isSuccess) {
      currentPage = 0;
      totalLessons = 0;
      lessons = [];

      await getTotalLessonCount();
      await loadLessons();
    }
  }

  confirmDeleteLessonDialog(LessonModel item) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete_forever_rounded, size: 30, color: colorScheme.error,),
            const Text(' ลบบทเรียน', style: TextStyle(fontSize: 30,),),
          ],
        ),
        content: Text('ต้องการลบบทเรียน "${item.title}" ออกจากระบบหรือไม่', style: const TextStyle(fontSize: 20,),),
        buttonPadding: const EdgeInsets.all(25),
        actions: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
            ),
            onPressed: () async {
              final LoadingDialogService loading = LoadingDialogService();
              loading.presentLoading(context);

              final ModuleAPI moduleAPI = ModuleAPI();
              APIResult res = await moduleAPI.deleteLessonOne(loginSession.token, item.id);

              final BucketAPI bucketAPI = BucketAPI();
              if(item.coverid != null && item.coverid!.isNotEmpty) {
                // ignore: unused_local_variable
                APIResult resBucket = await bucketAPI.deleteOne(loginSession.token, item.coverid!);
              }

              if(item.mediaid != null && item.mediaid!.isNotEmpty) {
                // ignore: unused_local_variable
                APIResult resBucket = await bucketAPI.deleteOne(loginSession.token, item.mediaid!);
              }

              final ContentAPI contentAPI = ContentAPI();
              // ignore: unused_local_variable
              APIResult resContent = await contentAPI.deleteOne(loginSession.token, item.contentid);

              // ignore: use_build_context_synchronously
              context.pop();
              // ignore: use_build_context_synchronously
              context.pop();
              
              if(res.status == 1) {
                totalLessons--;

                setState(() {
                  lessons.retainWhere((e) => e.id != item.id);
                });

                SuccessSnackBar snack = SuccessSnackBar();

                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(snack.showSuccess('ลบบทเรียนออกจากระบบเรียบร้อยแล้ว', globalConstraints, colorScheme));
              } else {
                final FailureDialog failureDialog = FailureDialog();

                // ignore: use_build_context_synchronously
                failureDialog.showFailure(context, colorScheme, res.message);
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.delete_forever_rounded, size: 22, color: colorScheme.onError,),
                Text(' ลบ', style: TextStyle(fontSize: 20, color: colorScheme.onError,),),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.secondary,
              padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
            ),
            onPressed: () => context.pop(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_circle_right_outlined, size: 22, color: colorScheme.onSecondary,),
                Text(' ถอยกลับ', style: TextStyle(fontSize: 20, color: colorScheme.onSecondary,),),
              ],
            ),
          ),
        ],
      ),
    );
  }

}