import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:cai_gameengine/models/create_quiz.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';

import 'package:cai_gameengine/components/common/image_thumbnail.widget.dart';

import 'package:cai_gameengine/api/exam.api.dart';
import 'package:cai_gameengine/api/bucket.api.dart';
import 'package:cai_gameengine/api/content.api.dart';

import 'package:cai_gameengine/services/loading_dialog.service.dart';
import 'package:cai_gameengine/services/success_snackbar.service.dart';
import 'package:cai_gameengine/services/failure_dialog.service.dart';

import 'package:cai_gameengine/models/api_result.model.dart';
import 'package:cai_gameengine/models/login_session.model.dart';
import 'package:cai_gameengine/models/quiz.model.dart';
import 'package:cai_gameengine/models/create_bucket.model.dart';
import 'package:cai_gameengine/models/create_content.model.dart';
import 'package:cai_gameengine/models/bucket.model.dart';

class QuizDialog extends StatefulWidget {
  const QuizDialog({super.key,required this.inExamID, required this.inID});

  final int inExamID;
  final int? inID;

  @override
  State<QuizDialog> createState() => _QuizDialogState();
}

class _QuizDialogState extends State<QuizDialog> {
  QuizModel? editQuiz;

  final formKey = GlobalKey<FormState>();
  TextEditingController quiznoController = TextEditingController();
  TextEditingController quizminuteController = TextEditingController();
  TextEditingController questionController = TextEditingController();

  String? contentid;

  Uint8List? originalMediaBytes;
  TextEditingController mediafileController = TextEditingController();
  PlatformFile? mediaFile;
  Uint8List? mediaBytes;
  Widget? media;

  List<CreateQuizChoiceModel> quizchoiceList = [];
  List<TextEditingController> answerControllers = [];
  List<TextEditingController> choicenoControllers = [];
  List<TextEditingController> choicescoreControllers = [];
  List<ValueNotifier<bool>> becorrectSelections = [];

  List<Uint8List?> originalChoiceMediaBytes = [];
  List<TextEditingController> choiceMediafileControllers = [];
  List<PlatformFile?> choiceMediaFiles = [];
  List<Uint8List?> choiceMediaBytes = [];
  List<Widget?> choiceMedia = [];

  List<String> mediaidDeleteList = [];
  List<String> feedbackidDeleteList = [];

  bool isFormValid = false;
  bool isLoading = false;

  LoginSessionModel? loginSession;
  late BoxConstraints globalConstraints;
  late ColorScheme colorScheme;

  @override
  void initState() {
    super.initState();

    isLoading = false;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      loginSession = context.read<LoginSessionModel>();

      if(widget.inID != null) {
        await initializeEditData();
      }

      isLoading = true;
    });
  }

  initializeEditData() async {
    final LoadingDialogService loading = LoadingDialogService();
    // ignore: use_build_context_synchronously
    loading.presentLoading(context);

    bool valid = true;

    await getQuiz(widget.inID!);

    quiznoController.text = editQuiz!.quizno.toString();
    quizminuteController.text = editQuiz!.quizminute.toString();
    questionController.text = editQuiz!.question;

    contentid = editQuiz!.contentid;

    if(editQuiz!.mediaid != null && editQuiz!.mediaid!.isNotEmpty) {
      final bucket = await getMedia(editQuiz!.mediaid!);

      if(bucket != null) {
        originalMediaBytes = bucket.bucketdata.data;

        mediafileController.text = bucket.bucketname;
        mediaBytes = originalMediaBytes;

        final mimeType = lookupMimeType(bucket.bucketname);
        if(mimeType!.startsWith('image/')) {
          media = ImageThumbnailWidget(image: Image.memory(mediaBytes!));
        } else if(mimeType.contains('audio/')) {
          media = buildAudioPlayer(mediaBytes!, mimeType);
        } else if(mimeType.contains('video/')) {
          media = buildVideoPlayer(mediaBytes!, mimeType);
        } else if(mimeType.contains('application/pdf')) {
          media = buildPDFLink(mediaBytes!);
        }
      }
    }

    final int length = editQuiz!.choices!.length;
    for(int i = 0; i < length; i++) {
      quizchoiceList.add(
        CreateQuizChoiceModel(
          answer: editQuiz!.choices![i].answer,
          choiceno: editQuiz!.choices![i].choiceno,
          choicescore: editQuiz!.choices![i].choicescore,
          becorrect: editQuiz!.choices![i].becorrect,
          mediaid: editQuiz!.choices![i].mediaid,
          feedbackid: editQuiz!.choices![i].feedbackid
        )
      );
      answerControllers.add(TextEditingController(text: editQuiz!.choices![i].answer));
      choicenoControllers.add(TextEditingController(text: editQuiz!.choices![i].choiceno.toString()));
      choicescoreControllers.add(TextEditingController(text: editQuiz!.choices![i].choicescore.toString()));
      becorrectSelections.add(ValueNotifier<bool>(editQuiz!.choices![i].becorrect));

      if(editQuiz!.choices![i].mediaid != null && editQuiz!.choices![i].mediaid!.isNotEmpty) {
        final BucketAPI bucketAPI = BucketAPI();
        final APIResult res = await bucketAPI.readOne(loginSession!.token, editQuiz!.choices![i].mediaid!);

        if(res.status == 1) {
          final bucket = res.result[0] as BucketModel;

          originalChoiceMediaBytes.add(bucket.bucketdata.data);
          choiceMediafileControllers.add(TextEditingController(text: bucket.bucketname));
          choiceMediaBytes.add(bucket.bucketdata.data);
          choiceMediaFiles.add(null);

          final mimeType = lookupMimeType(bucket.bucketname);
          if(mimeType!.startsWith('image/')) {
            choiceMedia.add(ImageThumbnailWidget(image: Image.memory(bucket.bucketdata.data)));
          } else if(mimeType.contains('audio/')) {
            choiceMedia.add(buildAudioPlayer(bucket.bucketdata.data, mimeType));
          } else if(mimeType.contains('video/')) {
            choiceMedia.add(buildVideoPlayer(bucket.bucketdata.data, mimeType));
          } else if(mimeType.contains('application/pdf')) {
            choiceMedia.add(buildPDFLink(bucket.bucketdata.data));
          }
        } else {
          originalChoiceMediaBytes.add(null);
          choiceMediafileControllers.add(TextEditingController());
          choiceMediaBytes.add(null);
          choiceMediaFiles.add(null);
          choiceMedia.add(null);
        }
      } else {
        originalChoiceMediaBytes.add(null);
        choiceMediafileControllers.add(TextEditingController());
        choiceMediaBytes.add(null);
        choiceMediaFiles.add(null);
        choiceMedia.add(null);
      }
    }

    setState(() {
      isFormValid = valid;
    });

    // ignore: use_build_context_synchronously
    context.pop();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getQuiz(int id) async {
    final ExamAPI examAPI = ExamAPI();
    final APIResult res = await examAPI.readQuizOne(loginSession!.token, id);

    if(res.status == 1) {
      setState(() {
        editQuiz = res.result[0] as QuizModel;
      });
    }
  }

  Future<BucketModel?> getMedia(String bucketid) async {
    final BucketAPI bucketAPI = BucketAPI();
    final APIResult res = await bucketAPI.readOne(loginSession!.token, bucketid);

    if(res.status == 1) {
      return res.result[0] as BucketModel;
    } else {
      return null;
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

    final isEdit = editQuiz != null;
    final modalIcon = isEdit ? Icons.edit_square : Icons.add_circle_outline;

    return StatefulBuilder(
      builder: (context, setState) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            globalConstraints = constraints;
            
            final isLg = constraints.maxWidth > 992;
            final isMd = constraints.maxWidth > 768;
            final isSm = constraints.maxWidth > 576;

            final dialogWidth = isLg ? constraints.maxWidth * 0.4 : (isMd ? constraints.maxWidth * 0.5 : (isSm ? constraints.maxWidth * 0.8 : constraints.maxWidth * 0.9));

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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(modalIcon, size: 30, color: colorScheme.primary,),
                                Text(' ${isEdit ? 'แก้ไข' : 'เพิ่ม'}ข้อสอบ', style: const TextStyle(fontSize: 30,),),
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
                        Padding(
                          padding: const EdgeInsets.only(top: 0, left: 10, bottom: 0, right: 10),
                          child: Form(
                            key: formKey,
                            autovalidateMode: isEdit ? AutovalidateMode.always : AutovalidateMode.onUserInteraction,
                            onChanged: () {
                              validateQuizForm();
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: TextFormField(
                                    controller: quiznoController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'(^\d+)'),)],
                                    autocorrect: false,
                                    decoration: const InputDecoration(
                                      labelText: 'ลำดับข้อสอบ',
                                      counterText: ' ',
                                      border: OutlineInputBorder(),
                                      floatingLabelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      errorStyle: TextStyle(fontSize: 14, height: 0.8),
                                    ),
                                    validator: (value) => value!.isNotEmpty && RegExp(r'(^\d+$)').hasMatch(value) && int.parse(value) > 0 ? null : 'กรุณาระบุลำดับข้อสอบ',
                                    onFieldSubmitted: (value) {
                                      if(isFormValid) {
                                        quizSubmit();
                                      }
                                    },
                                    textInputAction: TextInputAction.none,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: TextFormField(
                                    controller: quizminuteController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'(^\d+)'),)],
                                    autocorrect: false,
                                    decoration: const InputDecoration(
                                      labelText: 'เวลาเฉพาะข้อสอบ (นาที)',
                                      counterText: ' ',
                                      border: OutlineInputBorder(),
                                      floatingLabelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      errorStyle: TextStyle(fontSize: 14, height: 0.8),
                                    ),
                                    validator: (value) => value!.isNotEmpty && RegExp(r'(^\d+$)').hasMatch(value) && int.parse(value) >= 0 ? null : 'กรุณาระบุเวลาเฉพาะข้อสอบ',
                                    onFieldSubmitted: (value) {
                                      if(isFormValid) {
                                        quizSubmit();
                                      }
                                    },
                                    textInputAction: TextInputAction.none,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: TextFormField(
                                    controller: questionController,
                                    autocorrect: false,
                                    minLines: 3,
                                    maxLines: 3,
                                    maxLength: 1000,
                                    decoration: const InputDecoration(
                                      labelText: 'คำถาม',
                                      counterText: ' ',
                                      border: OutlineInputBorder(),
                                      floatingLabelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      errorStyle: TextStyle(fontSize: 14, height: 0.8),
                                    ),
                                    validator: (value) => value!.isNotEmpty ? null : 'กรุณาระบุคำถาม',
                                    onFieldSubmitted: (value) {
                                      if(isFormValid) {
                                        quizSubmit();
                                      }
                                    },
                                    textInputAction: TextInputAction.none,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: TextFormField(
                                    controller: mediafileController,
                                    autocorrect: false,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: 'สื่อประกอบคำถาม (ภาพ, เสียง, วิดีโอ)',
                                      counterText: ' ',
                                      border: const OutlineInputBorder(),
                                      floatingLabelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      icon: IconButton(
                                        onPressed: () async {
                                          FilePickerResult? result = await FilePicker.platform.pickFiles(
                                            type: FileType.custom,
                                            allowedExtensions: ['jpg', 'jpeg', 'png', 'bmp', 'gif', 'wav', 'm4a', 'mp3', 'mp4', 'mpeg', 'mov', 'avi']
                                          );

                                          if(result != null) {
                                            final mimeType = lookupMimeType(result.files[0].name);

                                            mediafileController.text = result.files[0].name;
                                            mediaFile = result.files[0];
                                            mediaBytes = result.files[0].bytes!;

                                            if(mimeType!.startsWith('image/')) {
                                              media = ImageThumbnailWidget(image: Image.memory(mediaBytes!));
                                            } else if(mimeType.contains('audio/')) {
                                              media = buildAudioPlayer(mediaBytes!, mimeType);
                                            } else if(mimeType.contains('video/')) {
                                              media = buildVideoPlayer(mediaBytes!, mimeType);
                                            } else if(mimeType.contains('application/pdf')) {
                                              media = buildPDFLink(mediaBytes!);
                                            } else if(mimeType.contains('application/msword') || mimeType.contains('application/vnd.openxmlformats-officedocument.wordprocessingml.document')) {
                                              media = buildMSWordLink(mediaBytes!, mimeType);
                                            } else if(mimeType.contains('application/vnd.ms-excel') || mimeType.contains('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')) {
                                              media = buildMSExcelLink(mediaBytes!, mimeType);
                                            } else if(mimeType.contains('application/vnd.ms-powerpoint') || mimeType.contains('application/vnd.openxmlformats-officedocument.presentationml.presentation')) {
                                              media = buildMSPowerpointLink(mediaBytes!, mimeType);
                                            } else {
                                              final FailureDialog failureDialog = FailureDialog();

                                              // ignore: use_build_context_synchronously
                                              failureDialog.showFailure(context, colorScheme, 'ไม่ใช่ไฟล์แนบที่ถูกต้อง');
                                            }
                                          }
                                        },
                                        color: colorScheme.primary,
                                        icon: const Icon(Icons.file_present),
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: mediafileController.text.isEmpty ?
                                          null :
                                          () {
                                            setState(() {
                                              mediafileController.text = '';
                                              mediaFile = null;
                                              mediaBytes = null;
                                              media = null;
                                            });
                                          },
                                        icon: const Icon(Icons.clear),
                                      ),
                                    ),
                                    onFieldSubmitted: (value) {
                                      if(isFormValid) {
                                        quizSubmit();
                                      }
                                    },
                                    textInputAction: TextInputAction.none,
                                  ),
                                ),
                                Visibility(
                                  visible: media != null,
                                  child: SizedBox(
                                    width: double.maxFinite,
                                    height: 125,
                                    child: media ?? Container(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Row(
                            children: [
                              const Text('ตัวเลือก ', textAlign: TextAlign.start, style: TextStyle(fontSize: 16,),),
                              IconButton(
                                style: IconButton.styleFrom(
                                  backgroundColor: colorScheme.tertiary,
                                ),
                                onPressed: () async {
                                  setState(() {
                                    quizchoiceList.add(
                                      CreateQuizChoiceModel(
                                        answer: '',
                                        choiceno: 0,
                                        choicescore: 0,
                                        becorrect: false,
                                        mediaid: null,
                                        feedbackid: ''
                                      )
                                    );

                                    answerControllers.add(TextEditingController());
                                    choicenoControllers.add(TextEditingController());
                                    choicescoreControllers.add(TextEditingController());
                                    becorrectSelections.add(ValueNotifier<bool>(false));

                                    originalChoiceMediaBytes.add(null);
                                    choiceMediafileControllers.add(TextEditingController());
                                    choiceMediaFiles.add(null);
                                    choiceMediaBytes.add(null);
                                    choiceMedia.add(null);
                                  });

                                  validateQuizForm();
                                },
                                icon: Icon(Icons.add_circle_outline, color: colorScheme.onTertiary,),
                              ),
                            ],
                          ),
                        ),
                        Builder(
                          builder: (BuildContext context) {
                            if(isLoading && quizchoiceList.isNotEmpty) {
                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: quizchoiceList.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 3),
                                    child: Container(
                                      width: double.maxFinite,
                                      decoration: BoxDecoration(
                                        color: colorScheme.tertiaryContainer,
                                        border: Border(bottom: BorderSide(width: 1.5, color: colorScheme.onSurface)),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(3),
                                        child: Column(
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 10),
                                                        child: ValueListenableBuilder(
                                                          valueListenable: choicenoControllers[index],
                                                          builder: (context, TextEditingValue value, __) {
                                                            return Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                                              children: [
                                                                TextField(
                                                                  controller: choicenoControllers[index],
                                                                  keyboardType: TextInputType.number,
                                                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'(^\d+)'),)],
                                                                  autocorrect: false,
                                                                  decoration: InputDecoration(
                                                                    labelText: 'ลำดับตัวเลือก',
                                                                    counterText: ' ',
                                                                    filled: true,
                                                                    fillColor: colorScheme.surfaceBright,
                                                                    border: const OutlineInputBorder(),
                                                                    floatingLabelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                                    errorStyle: const TextStyle(fontSize: 14, height: 0.8),
                                                                    errorText: quizchoiceList[index].choiceno != 0 ? null : 'กรุณาระบุลำดับตัวเลือก',
                                                                  ),
                                                                  onChanged: (value) {
                                                                    setState(() {
                                                                      if(int.tryParse(value) != null) {
                                                                        quizchoiceList[index].choiceno = int.parse(value);
                                                                      } else {
                                                                        quizchoiceList[index].choiceno = 0;
                                                                      }
                                                                    });

                                                                    validateQuizForm();
                                                                  },
                                                                  textInputAction: TextInputAction.none,
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 10),
                                                        child: ValueListenableBuilder(
                                                          valueListenable: answerControllers[index],
                                                          builder: (context, TextEditingValue value, __) {
                                                            return Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                                              children: [
                                                                TextField(
                                                                  controller: answerControllers[index],
                                                                  autocorrect: false,
                                                                  maxLength: 250,
                                                                  decoration: InputDecoration(
                                                                    labelText: 'คำตอบ',
                                                                    counterText: ' ',
                                                                    filled: true,
                                                                    fillColor: colorScheme.surfaceBright,
                                                                    border: const OutlineInputBorder(),
                                                                    floatingLabelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                                    errorStyle: const TextStyle(fontSize: 14, height: 0.8),
                                                                    errorText: quizchoiceList[index].answer.isNotEmpty ? null : 'กรุณาระบุคำตอบ',
                                                                  ),
                                                                  onChanged: (value) {
                                                                    setState(() {
                                                                      quizchoiceList[index].answer = value;
                                                                    });

                                                                    validateQuizForm();
                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 10),
                                                        child: ValueListenableBuilder(
                                                          valueListenable: choicescoreControllers[index],
                                                          builder: (context, TextEditingValue value, __) {
                                                            return Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                                              children: [
                                                                TextField(
                                                                  controller: choicescoreControllers[index],
                                                                  keyboardType: TextInputType.number,
                                                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'(^\d+)'),)],
                                                                  autocorrect: false,
                                                                  decoration: InputDecoration(
                                                                    labelText: 'คะแนน',
                                                                    counterText: ' ',
                                                                    filled: true,
                                                                    fillColor: colorScheme.surfaceBright,
                                                                    border: const OutlineInputBorder(),
                                                                    floatingLabelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                                    errorStyle: const TextStyle(fontSize: 14, height: 0.8),
                                                                    errorText: quizchoiceList[index].choicescore > -1 ? null : 'กรุณาระบุคะแนน',
                                                                  ),
                                                                  onChanged: (value) {
                                                                    setState(() {
                                                                      if(int.tryParse(value) != null) {
                                                                        quizchoiceList[index].choicescore = int.parse(value);
                                                                      } else {
                                                                        quizchoiceList[index].choicescore = 0;
                                                                      }
                                                                    });

                                                                    validateQuizForm();
                                                                  },
                                                                  textInputAction: TextInputAction.none,
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 10),
                                                        child: ValueListenableBuilder(
                                                          valueListenable: becorrectSelections[index],
                                                          builder: (context, bool value, __) {
                                                            return Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                                              children: [
                                                                CheckboxListTile(
                                                                  title: const Text(' ข้อถูก', style: TextStyle(fontSize: 16),),
                                                                  fillColor: becorrectSelections[index].value ? WidgetStateProperty.all(colorScheme.primary) : WidgetStateProperty.all(colorScheme.surfaceBright),
                                                                  controlAffinity : ListTileControlAffinity.leading,
                                                                  value: becorrectSelections[index].value,
                                                                  onChanged: (value) {
                                                                    setState(() {
                                                                      final int length = becorrectSelections.length;
                                                                      for(int i = 0; i < length; i++) {
                                                                        quizchoiceList[i].becorrect = false;
                                                                        becorrectSelections[i].value = false;
                                                                      }

                                                                      becorrectSelections[index].value = value!;

                                                                      quizchoiceList[index].becorrect = value;

                                                                      validateQuizForm();
                                                                    });
                                                                  }
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 15),
                                                        child: ValueListenableBuilder(
                                                          valueListenable: choiceMediafileControllers[index],
                                                          builder: (context, TextEditingValue value, __) {
                                                            return Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                                              children: [
                                                                TextField(
                                                                  controller: choiceMediafileControllers[index],
                                                                  autocorrect: false,
                                                                  decoration: InputDecoration(
                                                                    labelText: 'ภาพประกอบตัวเลือก',
                                                                    counterText: ' ',
                                                                    filled: true,
                                                                    fillColor: colorScheme.surfaceBright,
                                                                    border: const OutlineInputBorder(),
                                                                    floatingLabelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                                    icon: IconButton(
                                                                      onPressed: () async {
                                                                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                                                                          type: FileType.custom,
                                                                          allowedExtensions: ['jpg', 'jpeg', 'png', 'bmp', 'gif']
                                                                        );

                                                                        if(result != null) {
                                                                          final mimeType = lookupMimeType(result.files[0].name);

                                                                          choiceMediafileControllers[index].text = result.files[0].name;
                                                                          choiceMediaFiles[index] = result.files[0];
                                                                          choiceMediaBytes[index] = result.files[0].bytes!;

                                                                          if(mimeType!.startsWith('image/')) {
                                                                            choiceMedia[index] = Image.memory(choiceMediaBytes[index]!);
                                                                          } else {
                                                                            final FailureDialog failureDialog = FailureDialog();

                                                                            // ignore: use_build_context_synchronously
                                                                            failureDialog.showFailure(context, colorScheme, 'ไม่ใช่ไฟล์ภาพที่ถูกต้อง');
                                                                          }

                                                                          setState(() {});
                                                                        }
                                                                      },
                                                                      color: colorScheme.primary,
                                                                      icon: const Icon(Icons.file_present),
                                                                    ),
                                                                    suffixIcon: IconButton(
                                                                      onPressed: choiceMediafileControllers[index].text.isEmpty ?
                                                                        null :
                                                                        () {
                                                                          setState(() {
                                                                            choiceMediafileControllers[index].text = '';
                                                                            choiceMediaFiles[index] = null;
                                                                            choiceMediaBytes[index] = null;
                                                                            choiceMedia[index] = null;
                                                                          });
                                                                        },
                                                                      icon: const Icon(Icons.clear),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      Visibility(
                                                        visible: choiceMedia[index] != null,
                                                        child: SizedBox(
                                                          width: double.maxFinite,
                                                          height: 125,
                                                          child: choiceMedia[index] ?? Container(),
                                                        ),
                                                      ),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                        children: [
                                                          IconButton(
                                                            style: IconButton.styleFrom(
                                                              backgroundColor: colorScheme.error,
                                                            ),
                                                            onPressed: () async {
                                                              setState(() {
                                                                if(quizchoiceList[index].mediaid != null) {
                                                                  mediaidDeleteList.add(quizchoiceList[index].mediaid!);
                                                                }
                                                                if(quizchoiceList[index].feedbackid != null) {
                                                                  feedbackidDeleteList.add(quizchoiceList[index].feedbackid!);
                                                                }

                                                                quizchoiceList.removeAt(index);

                                                                answerControllers.removeAt(index);
                                                                choicenoControllers.removeAt(index);
                                                                choicescoreControllers.removeAt(index);
                                                                becorrectSelections.removeAt(index);

                                                                originalChoiceMediaBytes.removeAt(index);
                                                                choiceMediafileControllers.removeAt(index);
                                                                choiceMediaFiles.removeAt(index);
                                                                choiceMediaBytes.removeAt(index);
                                                                choiceMedia.removeAt(index);
                                                              });
                                                              validateQuizForm();
                                                            },
                                                            icon: Icon(Icons.delete, color: colorScheme.onError,),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  )
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                          ],
                                        )
                                      ),
                                    ),
                                  );
                                },
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
                                      Text('ไม่มีตัวเลือก', style: TextStyle(fontSize: 16, color: colorScheme.onTertiaryContainer),),
                                    ],
                                  ),
                                ),
                              );
                            }
                          }
                        ),
                        const SizedBox(
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
                              onPressed: !isFormValid ?
                                null :
                                () {
                                  quizSubmit();
                                },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(modalIcon, size: 22, color: colorScheme.onPrimary,),
                                  Text(isEdit ? ' แก้ไข' : ' เพิ่ม', style: TextStyle(fontSize: 20, color: colorScheme.onPrimary,),),
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
                ),
              ),
            );
          }
        );
      }
    );
  }

  validateQuizForm() {
    if(formKey.currentState!.validate() && quizchoiceList.length >= 2 && quizchoiceList.every((e) => e.answer.isNotEmpty && e.choiceno > 0 && e.choicescore > -1) && quizchoiceList.any((e) => e.becorrect)) {
      setState(() {
        isFormValid = true;
      });
    } else {
      setState(() {
        isFormValid = false;
      });
    }
  }

  quizSubmit() async {
    final LoadingDialogService loading = LoadingDialogService();
    loading.presentLoading(context);

    String? mediaid;
    if(editQuiz != null) {
      if(mediaBytes == null && originalMediaBytes != null) {
        final BucketAPI bucketAPI = BucketAPI();

        await bucketAPI.deleteOne(loginSession!.token, editQuiz!.mediaid!);

        mediaid = null;
      } else if(mediaBytes != null && mediaBytes.toString() != originalMediaBytes.toString()) {
        final BucketAPI bucketAPI = BucketAPI();
        APIResult bucketRes = await bucketAPI.createOne(loginSession!.token, mediaFile!);

        if(bucketRes.status == 1) {
          mediaid = (bucketRes.result[0] as CreateBucketModel).bucketid;

          if(editQuiz!.mediaid != null && editQuiz!.mediaid!.isNotEmpty) {
            await bucketAPI.deleteOne(loginSession!.token, editQuiz!.mediaid!);
          }
        } else if(editQuiz!.mediaid != null) {
          mediaid = editQuiz!.mediaid;
        }
      } else if(mediaBytes.toString() == originalMediaBytes.toString()) {
        mediaid = editQuiz!.mediaid;
      }
    } else if(mediaBytes != null) {
      final BucketAPI bucketAPI = BucketAPI();
      APIResult bucketRes = await bucketAPI.createOne(loginSession!.token, mediaFile!);

      if(bucketRes.status == 1) {
        mediaid = (bucketRes.result[0] as CreateBucketModel).bucketid;
      }
    }

    if(contentid == null) {
      final ContentAPI contentAPI = ContentAPI();

      Uint8List bytes = Uint8List.fromList(utf8.encode(''));
      PlatformFile content = PlatformFile(name: 'm${widget.inExamID}-${DateFormat('yyyyMMddHHmmss').format(DateTime.now().subtract(DateTime.now().timeZoneOffset))}.txt', size: bytes.lengthInBytes, bytes: bytes);
      APIResult resCreate = await contentAPI.createOne(loginSession!.token, content);

      contentid = (resCreate.result[0] as CreateContentModel).contentid;
    }

    if(mediaidDeleteList.isNotEmpty) {
      final BucketAPI bucketAPI = BucketAPI();
      for(var mediaidDelete in mediaidDeleteList) {
        await bucketAPI.deleteOne(loginSession!.token, mediaidDelete);
      }
    }
    if(feedbackidDeleteList.isNotEmpty) {
      final ContentAPI contentAPI = ContentAPI();
      for(var feedbackidDelete in feedbackidDeleteList) {
        await contentAPI.deleteOne(loginSession!.token, feedbackidDelete);
      }
    }

    final int length = quizchoiceList.length;
    for(int i = 0; i < length; i++) {
      String? choiceMedia;
      if(choiceMediaBytes[i] == null && originalChoiceMediaBytes[i] != null) {
        final BucketAPI bucketAPI = BucketAPI();

        await bucketAPI.deleteOne(loginSession!.token, quizchoiceList[i].mediaid!);

        choiceMedia = null;
      } else if(choiceMediaBytes[i] != null && choiceMediaBytes[i].toString() != originalChoiceMediaBytes[i].toString()) {
        final BucketAPI bucketAPI = BucketAPI();
        APIResult bucketRes = await bucketAPI.createOne(loginSession!.token, choiceMediaFiles[i]!);

        if(bucketRes.status == 1) {
          choiceMedia = (bucketRes.result[0] as CreateBucketModel).bucketid;

          if(quizchoiceList[i].mediaid != null && quizchoiceList[i].mediaid!.isNotEmpty) {
            await bucketAPI.deleteOne(loginSession!.token, quizchoiceList[i].mediaid!);
          }
        } else if(quizchoiceList[i].mediaid != null) {
          choiceMedia = quizchoiceList[i].mediaid;
        }
      } else if(choiceMediaBytes[i].toString() == originalChoiceMediaBytes[i].toString()) {
        choiceMedia = quizchoiceList[i].mediaid;
      }

      quizchoiceList[i].mediaid = choiceMedia;

      if(quizchoiceList[i].feedbackid == null || quizchoiceList[i].feedbackid!.isEmpty) {
        final ContentAPI contentAPI = ContentAPI();

        Uint8List bytes = Uint8List.fromList(utf8.encode(''));
        PlatformFile content = PlatformFile(name: 'e${widget.inExamID}-q${quiznoController.value.text}-c${quizchoiceList[i].choiceno}-${DateFormat('yyyyMMddHHmmss').format(DateTime.now().subtract(DateTime.now().timeZoneOffset))}.txt', size: bytes.lengthInBytes, bytes: bytes);
        APIResult resCreate = await contentAPI.createOne(loginSession!.token, content);

        quizchoiceList[i].feedbackid = (resCreate.result[0] as CreateContentModel).contentid;
      }
    }
    
    final ExamAPI examAPI = ExamAPI();

    APIResult res;
    String message;
    if(widget.inID == null) {
      res = await examAPI.createQuizOne(loginSession!.token, widget.inExamID, int.parse(quiznoController.value.text), double.tryParse(quizminuteController.value.text) ?? 0, questionController.value.text, contentid, mediaid, quizchoiceList);
      message = 'เพิ่มข้อสอบเรียบร้อยแล้ว';
    } else {
      res = await examAPI.updateQuizOne(loginSession!.token, widget.inID!, widget.inExamID, int.parse(quiznoController.value.text), double.tryParse(quizminuteController.value.text) ?? 0, questionController.value.text, contentid, mediaid, quizchoiceList);
      message = 'แก้ไขข้อมูลข้อสอบเรียบร้อยแล้ว';
    }    

    // ignore: use_build_context_synchronously
    context.pop();

    if(res.status == 1) {
      // ignore: use_build_context_synchronously
      context.pop(true);

      SuccessSnackBar snackbar = SuccessSnackBar();

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(snackbar.showSuccess(message, globalConstraints, colorScheme));
    } else {
      final FailureDialog failureDialog = FailureDialog();

      // ignore: use_build_context_synchronously
      failureDialog.showFailure(context, colorScheme, res.message);
    }
  }
}