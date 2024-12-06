import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';

import 'package:cai_gameengine/data/exam/details/quiz_choice_content.dialog.dart';
import 'package:cai_gameengine/components/common/image_thumbnail.widget.dart';

import 'package:cai_gameengine/api/exam.api.dart';
import 'package:cai_gameengine/api/bucket.api.dart';

import 'package:cai_gameengine/services/loading_dialog.service.dart';

import 'package:cai_gameengine/models/api_result.model.dart';
import 'package:cai_gameengine/models/login_session.model.dart';
import 'package:cai_gameengine/models/quiz.model.dart';
import 'package:cai_gameengine/models/bucket.model.dart';

class QuizChoiceDialog extends StatefulWidget {
  const QuizChoiceDialog({super.key, required this.inQuizID});

  final int inQuizID;

  @override
  State<QuizChoiceDialog> createState() => _QuizChoiceDialogState();
}

class _QuizChoiceDialogState extends State<QuizChoiceDialog> {
  QuizModel? quiz;

  LoginSessionModel? loginSession;
  late BoxConstraints globalConstraints;
  late ColorScheme colorScheme;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      loginSession = context.read<LoginSessionModel>();

      final LoadingDialogService loading = LoadingDialogService();
      loading.presentLoading(context);

      final ExamAPI examAPI = ExamAPI();
      APIResult resQuiz = await examAPI.readQuizOne(loginSession!.token, widget.inQuizID);
      
      setState(() {
        quiz = resQuiz.result[0] as QuizModel;
      });

      // ignore: use_build_context_synchronously
      context.pop();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Widget> getMedia(String bucketid) async {
    final BucketAPI bucketAPI = BucketAPI();
    final APIResult res = await bucketAPI.readOne(loginSession!.token, bucketid);

    if(res.status == 1) {
      final bucket = res.result[0] as BucketModel;

      final String? mimeType = lookupMimeType(bucket.bucketname);
      final Uint8List mediaBytes = bucket.bucketdata.data;

      if(mimeType!.startsWith('image/')) {
        return ImageThumbnailWidget(image: Image.memory(mediaBytes));
      } else if(mimeType.contains('audio/')) {
        return buildAudioPlayer(mediaBytes, mimeType);
      } else if(mimeType.contains('video/')) {
        return buildVideoPlayer(mediaBytes, mimeType);
      } else if(mimeType.contains('application/pdf')) {
        return buildPDFLink(mediaBytes);
      } else if(mimeType.contains('application/msword') || mimeType.contains('application/vnd.openxmlformats-officedocument.wordprocessingml.document')) {
        return buildMSWordLink(mediaBytes, mimeType);
      } else if(mimeType.contains('application/vnd.ms-excel') || mimeType.contains('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')) {
        return buildMSExcelLink(mediaBytes, mimeType);
      } else if(mimeType.contains('application/vnd.ms-powerpoint') || mimeType.contains('application/vnd.openxmlformats-officedocument.presentationml.presentation')) {
        return buildMSPowerpointLink(mediaBytes, mimeType);
      } else {
        return ImageThumbnailWidget(image: Image.asset('assets/images/default_picture.png',));
      }
    } else {
      return ImageThumbnailWidget(image: Image.asset('assets/images/default_picture.png',));
    }
  }

  buildAudioPlayer(Uint8List mediaBytes, String mimeType) {
    final sourceElement = html.SourceElement();
    sourceElement.type = mimeType;
    sourceElement.src = Uri.dataFromBytes(mediaBytes.toList(), mimeType: mimeType).toString();

    final audioElement = html.AudioElement();
    audioElement.controls = true;
    audioElement.children = [sourceElement];
    audioElement.style.height = '100%';
    audioElement.style.width = '100%';

    final String id = 'upload-${DateTime.now().millisecondsSinceEpoch}';
    ui_web.platformViewRegistry.registerViewFactory(id, (int viewId) => audioElement);

    return HtmlElementView(viewType: id);
  }

  buildVideoPlayer(Uint8List mediaBytes, String mimeType) {
    final sourceElement = html.SourceElement();
    sourceElement.type = mimeType;
    sourceElement.src = Uri.dataFromBytes(mediaBytes.toList(), mimeType: mimeType).toString();

    final videoElement = html.VideoElement();
    videoElement.controls = true;
    videoElement.children = [sourceElement];
    videoElement.style.height = '100%';
    videoElement.style.width = '100%';

    final String id = 'upload-${DateTime.now().millisecondsSinceEpoch}';
    ui_web.platformViewRegistry.registerViewFactory(id, (int viewId) => videoElement);

    return HtmlElementView(viewType: id);
  }

  buildPDFLink(Uint8List mediaBytes) {
    return Material(
      borderRadius: BorderRadius.circular(10.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: () {
          final blob = html.Blob([mediaBytes], 'application/pdf');
          final url = html.Url.createObjectUrlFromBlob(blob);
          html.window.open(url, '_blank');
          html.Url.revokeObjectUrl(url);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.asset('assets/images/pdf.png',),
        ),
      ),
    );
  }

  buildMSWordLink(Uint8List mediaBytes, String mimeType) {
    return Material(
      borderRadius: BorderRadius.circular(10.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: () {
          final blob = html.Blob([mediaBytes], mimeType);
          final url = html.Url.createObjectUrlFromBlob(blob);
          html.window.open(url, '_blank');
          html.Url.revokeObjectUrl(url);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.asset('assets/images/ms-word.png',),
        ),
      ),
    );
  }

  buildMSExcelLink(Uint8List mediaBytes, String mimeType) {
    return Material(
      borderRadius: BorderRadius.circular(10.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: () {
          final blob = html.Blob([mediaBytes], mimeType);
          final url = html.Url.createObjectUrlFromBlob(blob);
          html.window.open(url, '_blank');
          html.Url.revokeObjectUrl(url);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.asset('assets/images/ms-excel.png',),
        ),
      ),
    );
  }

  buildMSPowerpointLink(Uint8List mediaBytes, String mimeType) {
    return Material(
      borderRadius: BorderRadius.circular(10.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: () {
          final blob = html.Blob([mediaBytes], mimeType);
          final url = html.Url.createObjectUrlFromBlob(blob);
          html.window.open(url, '_blank');
          html.Url.revokeObjectUrl(url);
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

    return StatefulBuilder(
      builder: (context, setState) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final isLg = constraints.maxWidth > 992;
            final isMd = constraints.maxWidth > 768;
            final isSm = constraints.maxWidth > 576;

            final dialogWidth = isLg ? constraints.maxWidth * 0.4 : (isMd ? constraints.maxWidth * 0.55 : (isSm ? constraints.maxWidth * 0.9 : constraints.maxWidth * 0.95));

            return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: SizedBox(
                  width: dialogWidth,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(),
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.format_list_bulleted, size: 30, color: colorScheme.tertiary,),
                                      const Text(' ตัวเลือก', style: TextStyle(fontSize: 30,),),
                                    ],
                                  ),
                                  Text(quiz?.question ?? '', style: TextStyle(fontSize: 14, color: colorScheme.primary,),),
                                ],
                              ),
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
                          width: double.infinity,
                          height: 10,
                        ),
                        if(quiz != null)
                          ...buildQuizChoiceList(quiz!.id, quiz!.choices!),
                        const SizedBox(
                          width: double.infinity,
                          height: 25,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
                ),
              ),
            );
          },
        );
      }
    );
  }

  buildQuizChoiceList(int quizID, List<QuizChoiceModel> choices) {
    List<Widget> itemWidgetList = [];

    final TextStyle nameStyle = TextStyle(color: colorScheme.onSecondaryContainer, fontSize: 17);

    for(var choice in choices) {
      Future<Widget> mediaWidget;
      if(choice.mediaid != null && choice.mediaid!.isNotEmpty) {
        mediaWidget = getMedia(choice.mediaid!);
      } else {
         mediaWidget = Future.value(ImageThumbnailWidget(image: Image.asset('assets/images/default_picture.png',)));
      }

      itemWidgetList.addAll([
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 3, right: 3, bottom: 8),
          child: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(10),
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
                      Text(choice.choiceno.toString(), overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                    ],
                  ),
                ),
                Expanded(
                  flex: 9,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
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
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(choice.answer, style: nameStyle,),
                            ],
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('คะแนน', style: TextStyle(color: colorScheme.tertiary, fontSize: 12, fontWeight: FontWeight.bold),),
                                Text(choice.choicescore.toString(), style: const TextStyle(fontSize: 14,),),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ข้อถูก', style: TextStyle(color: colorScheme.tertiary, fontSize: 12, fontWeight: FontWeight.bold),),
                                choice.becorrect ?
                                  Icon(Icons.check, color: colorScheme.brightness == Brightness.light ? const Color( 0xFF009000 ) : const Color( 0xFF0FF000 ),) :
                                  const Icon(Icons.close, color: Colors.red,)
                              ],
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        thickness: 1,
                        color: colorScheme.onSurface,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              choiceContentDialog(quizID, choice.id);
                            },
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(15),
                              backgroundColor: colorScheme.tertiary,
                            ),
                            child: Icon(Icons.edit_note, color: colorScheme.onTertiary,),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ]);
    }

    return itemWidgetList;
  }

  choiceContentDialog(int quizID, int choiceID) async {
    bool? isChanged = await showDialog<bool?>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return QuizChoiceContentDialog(inQuizID: quizID, inQuizChoiceID: choiceID);
      },
    ).then((value) => value);

    if(isChanged != null && isChanged) {
      final ExamAPI examAPI = ExamAPI();
      APIResult resQuiz = await examAPI.readQuizOne(loginSession!.token, widget.inQuizID);

      setState(() {
        quiz = resQuiz.result[0] as QuizModel;
      });
    }
  }

}