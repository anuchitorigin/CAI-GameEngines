import 'dart:convert';

import 'package:cai_gameengine/api/exam.api.dart';
import 'package:cai_gameengine/models/create_quiz.model.dart';
import 'package:cai_gameengine/models/quiz.model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quill/flutter_quill.dart' as Quill;

import 'package:cai_gameengine/api/content.api.dart';

import 'package:cai_gameengine/services/loading_dialog.service.dart';
import 'package:cai_gameengine/services/success_snackbar.service.dart';
import 'package:cai_gameengine/services/failure_dialog.service.dart';

import 'package:cai_gameengine/models/api_result.model.dart';
import 'package:cai_gameengine/models/login_session.model.dart';
import 'package:cai_gameengine/models/create_content.model.dart';
import 'package:cai_gameengine/models/content.model.dart';

class QuizChoiceContentDialog extends StatefulWidget {
  const QuizChoiceContentDialog({super.key, required this.inQuizID, required this.inQuizChoiceID});

  final int inQuizID;
  final int inQuizChoiceID;

  @override
  State<QuizChoiceContentDialog> createState() => _QuizChoiceContentDialogState();
}

class _QuizChoiceContentDialogState extends State<QuizChoiceContentDialog> {
  final Quill.QuillController _controller = Quill.QuillController.basic();

  late final QuizModel quiz;
  late final QuizChoiceModel choice;

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
      quiz = resQuiz.result[0] as QuizModel;
      choice = quiz.choices!.firstWhere((e) => e.id == widget.inQuizChoiceID);

      final ContentAPI contentAPI = ContentAPI();
      APIResult resContent = await contentAPI.readOne(loginSession!.token, choice.feedbackid);

      if(resContent.status == 1) {
        if((resContent.result[0] as ContentModel).bucketdata.data.isNotEmpty) {
          _controller.document = Quill.Document.fromJson(jsonDecode(utf8.decode((resContent.result[0] as ContentModel).bucketdata.data)));
        }
      }

      // ignore: use_build_context_synchronously
      context.pop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            globalConstraints = constraints;
            
            final double textareaHeight = globalConstraints.maxHeight > 500 ? globalConstraints.maxHeight - 250 : 250;

            return Dialog.fullscreen(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: SizedBox(
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
                                Icon(Icons.edit_note, size: 30, color: colorScheme.primary,),
                                const Text(' เนื้อหาคำอธิบายตัวเลือก', style: TextStyle(fontSize: 30,),),
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
                          child: Column(
                            children: [
                              Quill.QuillSimpleToolbar(
                                controller: _controller,
                                configurations: const Quill.QuillSimpleToolbarConfigurations(
                                  showSmallButton: true,
                                  showLineHeightButton: true,
                                  showAlignmentButtons: true,
                                  showDirection: true,
                                  showLink: false,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(5),
                                width: double.maxFinite,
                                height: textareaHeight,
                                decoration: BoxDecoration(
                                  border: Border.all(width: 1, color: colorScheme.onSurface),
                                ),
                                child: Quill.QuillEditor.basic(
                                  controller: _controller,
                                  configurations: const Quill.QuillEditorConfigurations(),
                                ),
                              ),
                            ],
                          ),
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
                              onPressed: () {
                                contentSubmit();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.save, size: 22, color: colorScheme.onPrimary,),
                                  Text(' บันทึก', style: TextStyle(fontSize: 20, color: colorScheme.onPrimary,),),
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

  contentSubmit() async {
    final LoadingDialogService loading = LoadingDialogService();
    loading.presentLoading(context);

    final ContentAPI contentAPI = ContentAPI();
    // ignore: unused_local_variable
    APIResult resDelete = await contentAPI.deleteOne(loginSession!.token, choice.feedbackid);

    Uint8List bytes = Uint8List.fromList(utf8.encode(jsonEncode(_controller.document.toDelta().toJson())));
    PlatformFile content = PlatformFile(name: 'e${quiz.exam_id}-q${quiz.quizno}-c${choice.choiceno}-${DateFormat('yyyyMMddHHmmss').format(DateTime.now().subtract(DateTime.now().timeZoneOffset))}.txt', size: bytes.lengthInBytes, bytes: bytes);
    APIResult resCreate = await contentAPI.createOne(loginSession!.token, content);

    if(resCreate.status == 1) {
      final String contentid = (resCreate.result[0] as CreateContentModel).contentid;

      List<CreateQuizChoiceModel> newChoices = [];
      final int length = quiz.choices!.length;
      for(int i = 0; i < length; i++) {
        newChoices.add(
          CreateQuizChoiceModel(
            answer: quiz.choices![i].answer,
            choiceno: quiz.choices![i].choiceno,
            choicescore: quiz.choices![i].choicescore,
            becorrect: quiz.choices![i].becorrect,
            mediaid: quiz.choices![i].mediaid,
            feedbackid: quiz.choices![i].id == choice.id ? contentid : quiz.choices![i].feedbackid
          )
        );
      }

      final ExamAPI examAPI = ExamAPI();
      // ignore: unused_local_variable
      APIResult resUpdateItem = await examAPI.updateQuizOne(loginSession!.token, quiz.id, quiz.exam_id, quiz.quizno, quiz.quizminute, quiz.question, quiz.contentid, quiz.mediaid, newChoices);
    
      // ignore: use_build_context_synchronously
      context.pop();
      // ignore: use_build_context_synchronously
      context.pop(true);

      SuccessSnackBar snackbar = SuccessSnackBar();

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(snackbar.showSuccess('บันทึกเนื้อหาคำอธิบายตัวเลือกเรียบร้อยแล้ว', globalConstraints, colorScheme));
    } else {
      // ignore: use_build_context_synchronously
      context.pop();

      final FailureDialog failureDialog = FailureDialog();

      // ignore: use_build_context_synchronously
      failureDialog.showFailure(context, colorScheme, resCreate.message);
    }
  }
}