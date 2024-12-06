import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quill/flutter_quill.dart' as Quill;

import 'package:cai_gameengine/components/common/image_thumbnail.widget.dart';

import 'package:cai_gameengine/api/module.api.dart';
import 'package:cai_gameengine/api/assessment.api.dart';
import 'package:cai_gameengine/api/bucket.api.dart';
import 'package:cai_gameengine/api/content.api.dart';

import 'package:cai_gameengine/services/loading_dialog.service.dart';
import 'package:cai_gameengine/services/failure_dialog.service.dart';

import 'package:cai_gameengine/models/api_result.model.dart';
import 'package:cai_gameengine/models/recordcount.model.dart';
import 'package:cai_gameengine/models/login_session.model.dart';
import 'package:cai_gameengine/models/module.model.dart';
import 'package:cai_gameengine/models/assessment.model.dart';
import 'package:cai_gameengine/models/bucket.model.dart';
import 'package:cai_gameengine/models/content.model.dart';

class ExamPage extends StatefulWidget {
  const ExamPage({super.key});

  @override
  State<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  bool noModuleOrExam = false;
  bool isFinish = false;

  final Quill.QuillController _quizContentController = Quill.QuillController.basic();
  final Quill.QuillController _choiceContentController = Quill.QuillController.basic();

  int quizIndex = -1;

  int examTime = 0;
  Timer? examTimer;

  List<CreateUpdateOne> quizChoiceList = [];

  ModuleModel? module;
  CreateAssessmentResult? assessment;

  QuizChoice? choiceSelection;

  bool isLoading = false;

  late LoginSessionModel loginSession;
  late BoxConstraints globalConstraints;
  late ColorScheme colorScheme;

  @override
  void initState() {
    super.initState();

    final LoadingDialogService loading = LoadingDialogService();

    _quizContentController.readOnly = true;
    _choiceContentController.readOnly = true;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      loading.presentLoading(context);

      loginSession = context.read<LoginSessionModel>();

      await loadModule();

      await loadExam();

      if(mounted) {
        setState(() {
          isLoading = false;
        });
      }

      // ignore: use_build_context_synchronously
      context.pop();
    });
  }

  @override
  void dispose() {
    super.dispose();

    examTimer?.cancel();
  }

  loadModule() async {
    if(loginSession.token.isNotEmpty) {
      final ModuleAPI moduleAPI = ModuleAPI();

      APIResult resModuleCount = await moduleAPI.readCount(loginSession.token, null, null, null, null, null, null, null, null, []);

      if(resModuleCount.status == 1 && (resModuleCount.result[0] as RecordCountModel).RecordCount > 0) {
        int i = 0;
        do {
          i++;

          APIResult resModule = await moduleAPI.readOne(loginSession.token, i);
          if(resModule.status == 1) {
            module = resModule.result[0] as ModuleModel;
          }
        } while(module == null);
      } else {
        setState(() {
          noModuleOrExam = true;
        });
      }
    }
  }

  loadExam() async {
    if(loginSession.token.isNotEmpty) {
      final AssessmentAPI assessmentAPI = AssessmentAPI();

      try {
        APIResult resAssessment = await assessmentAPI.createOne(loginSession.token, null, module!.id, 0);

        if(resAssessment.status == 1) {
          setState(() {
            quizIndex = -1;
            assessment = resAssessment.result[0] as CreateAssessmentResult;

            examTime = assessment!.examminute.toInt() * 60;

            final int length = assessment!.quizzes.length;
            for(int i = 0; i < length; i++) {
              quizChoiceList.add(
                CreateUpdateOne(
                  id: assessment!.quizzes[i].id,
                  choice_id: 0
                )
              );
            }

            isLoading = false;
          });
        } else {
          setState(() {
            noModuleOrExam = true;
            isLoading = false;
          });
        }
      } catch(err) {
        setState(() {
          noModuleOrExam = true;
          isLoading = false;
        });
      }
    }
  }

  getQuizContent(String contentid) async {
    final ContentAPI contentAPI = ContentAPI();
    APIResult resContent = await contentAPI.readOne(loginSession.token, contentid);

    if(resContent.status == 1) {
      if((resContent.result[0] as ContentModel).bucketdata.data.isNotEmpty) {
        _quizContentController.document = Quill.Document.fromJson(jsonDecode(utf8.decode((resContent.result[0] as ContentModel).bucketdata.data)));
      }
    }
  }

  void timerCallback(timer) {
    setState(() {
      examTime--;
    });

    if(examTime <= 0) {
      examTimer?.cancel();
      showExpireDialog();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    setState(() {
      colorScheme = Theme.of(context).colorScheme;
    });

    return LayoutBuilder(
      builder: (context, BoxConstraints constraints) {
        globalConstraints = constraints;

        final isLg = globalConstraints.maxWidth > 992;
        final isMd = globalConstraints.maxWidth > 768;
        final isSm = globalConstraints.maxWidth > 576;

        final cardWidth = isLg ? globalConstraints.maxWidth * 0.5 : (isMd ? globalConstraints.maxWidth * 0.7 : (isSm ? globalConstraints.maxWidth * 0.8 : globalConstraints.maxWidth * 0.9));

        return SizedBox(
          width: globalConstraints.maxWidth,
          height: globalConstraints.maxHeight,
          child: Builder(
            builder: (BuildContext context) {
              if(noModuleOrExam) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('ไม่พบโมดูลหรือแบบทดสอบในระบบ', style: TextStyle(fontSize: 36),),
                    Text(module!.title, style: const TextStyle(fontSize: 40),),
                  ],
                );
              } else if(isFinish) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('จบแบบทดสอบ', style: TextStyle(fontSize: 36),),
                    Text(module!.title, style: const TextStyle(fontSize: 40),),
                    ElevatedButton(
                      onPressed: () {
                        final LoadingDialogService loading = LoadingDialogService();
                        loading.presentLoading(context);

                        examTimer?.cancel();
                        examTimer = null;

                        examTime = assessment!.examminute.toInt() * 60;

                        quizIndex = -1;
                        choiceSelection = null;

                        for(var quizChoice in quizChoiceList) {
                          quizChoice.choice_id = 0;
                        }

                        setState(() {
                          isFinish = false;
                          isLoading = false;
                        });

                        context.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        maximumSize: const Size.fromWidth(175),
                        padding: const EdgeInsets.all(15),
                        backgroundColor: Colors.black,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('ทำแบบทดสอบอีกครั้ง', style: TextStyle(fontSize: 16, color: Colors.white,),),
                        ],
                      ),
                    ),
                  ],
                );
              } else if(!isLoading && module != null && assessment != null && assessment!.quizzes.isNotEmpty) {
                if(quizIndex >= 0) {
                  return buildQuiz(assessment!.quizzes[quizIndex], globalConstraints.maxWidth);
                } else {
                  return buildExam();
                }
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: cardWidth,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: const BorderRadius.all(Radius.circular(5)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                        ],
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        );
      }
    );
  }

  buildExam() {
    return Column(
      children: [
        const SizedBox(
          height: 15,
        ),
        Expanded(
          flex: 9,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(assessment!.title, style: const TextStyle(fontSize: 36),),
              Text(assessment!.caption, style: const TextStyle(fontSize: 20),),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0,),
                  child: Container(
                    width: double.maxFinite,
                    height: double.maxFinite,
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorScheme.onSurface,
                        width: 2.0,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: SingleChildScrollView(
                      child: Text(assessment!.descr, style: const TextStyle(fontSize: 20),),
                    )
                  ),
                ),
              ),
            ]
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  if(examTime > 0) {
                    examTimer = Timer.periodic(const Duration(seconds: 1), timerCallback);
                  }

                  setState(() {
                    quizIndex++;
                  });
                },
                style: ElevatedButton.styleFrom(
                  maximumSize: const Size.fromWidth(180),
                  padding: const EdgeInsets.all(15),
                  backgroundColor: colorScheme.primary,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('เริ่มทำแบบทดสอบ ', style: TextStyle(fontSize: 16, color: colorScheme.onPrimary,),),
                    Icon(Icons.arrow_forward, color: colorScheme.onPrimary,),
                  ],
                ),
              ),
            ],
          )
        ),
      ],
    );
  }

  buildQuiz(CreateAssessmentQuiz currentQuiz, double maxWidth) {
    Future<Widget> mediaWidget;
    if(currentQuiz.mediaid.isNotEmpty) {
      mediaWidget = getMedia(currentQuiz.mediaid);
    } else {
      mediaWidget = Future.value(ImageThumbnailWidget(image: Image.asset('assets/images/default_picture.png',)));
    }

    if(currentQuiz.contentid.isNotEmpty) {
      getQuizContent(currentQuiz.contentid);
    }

    return Column(
      children: [
        const SizedBox(
          height: 15,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: Container(),
            ),
            Expanded(
              flex: 7,
              child: Text('แบบทดสอบ: ${assessment!.title}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold,),),
            ),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.access_time,),
                        Text(examTimer != null ? '${(examTime / 60).floor().toString().padLeft(2, '0')}:${(examTime % 60).toString().padLeft(2, '0')}' : '--:--', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),),
                        Text(examTimer != null ? 'เวลาคงเหลือ' : 'ไม่กำหนดเวลา', style: const TextStyle(fontSize: 12,),),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          examTimer?.cancel();
                          examTimer = null;

                          final bool isSubmit = await showSubmitExamDialog();

                          if(isSubmit) {
                            final LoadingDialogService loading = LoadingDialogService();
                            // ignore: use_build_context_synchronously
                            loading.presentLoading(context);
                            
                            examTime = 0;

                            quizIndex = -1;
                            choiceSelection = null;

                            // ignore: use_build_context_synchronously
                            context.pop();

                            setState(() {
                              isLoading = false;
                              isFinish = true;
                            });
                          } else {
                            if(examTime > 0) {
                              examTimer = Timer.periodic(const Duration(seconds: 1), timerCallback);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          maximumSize: const Size.fromWidth(175),
                          padding: const EdgeInsets.all(15),
                          backgroundColor: Colors.black,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('ส่งกระดาษคำตอบ', style: TextStyle(fontSize: 16, color: Colors.white,),),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(),
            ),
          ]
        ),
        Expanded(
          flex: 9,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('${currentQuiz.quizno}. ${currentQuiz.question}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),),
                        const SizedBox(
                          height: 10.0,
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: currentQuiz.choices.length,
                          itemBuilder: (context, index) {
                            Future<Widget> choiceMediaWidget = Future.value(Container());
                            if(currentQuiz.choices[index].mediaid.isNotEmpty) {
                              choiceMediaWidget = getMedia(currentQuiz.choices[index].mediaid);
                            }

                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Radio<QuizChoice>(
                                      value: currentQuiz.choices[index],
                                      groupValue: choiceSelection,
                                      onChanged: (QuizChoice? value) async {
                                        setState(() {
                                          choiceSelection = value;
                                          quizChoiceList.firstWhere((e) => e.id == currentQuiz.id).choice_id = choiceSelection!.id;
                                        });
                                      },
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    FutureBuilder<Widget>(
                                      future: choiceMediaWidget,
                                      builder: (context, AsyncSnapshot coverSnapshot) {
                                        if(coverSnapshot.hasData) {
                                          if(coverSnapshot.data!.toString() != 'Container') {
                                            return Container(
                                              width: 100,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(10.0),
                                              ),
                                              child: coverSnapshot.data!
                                            );
                                          } else {
                                            return coverSnapshot.data!;
                                          }
                                        } else {
                                          return SizedBox(
                                            width: 60,
                                            height: 60,
                                            child: CircularProgressIndicator(
                                              color: colorScheme.secondary,
                                            ),
                                          );
                                        }
                                      }
                                    ),
                                    FutureBuilder<Widget>(
                                      future: choiceMediaWidget,
                                      builder: (context, AsyncSnapshot coverSnapshot) {
                                        if(coverSnapshot.hasData) {
                                          if(coverSnapshot.data!.toString() != 'Container') {
                                            return const SizedBox(
                                              width: 10,
                                            );
                                          } else {
                                            return Container();
                                          }
                                        } else {
                                          return Container();
                                        }
                                      }
                                    ),
                                    Text(currentQuiz.choices[index].answer, style: TextStyle(fontSize: 16, color: colorScheme.onSurface,),),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20.0,
                                ),
                              ],
                            );
                          }
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    width: double.maxFinite,
                    height: double.maxFinite,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: colorScheme.onSurface),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          FutureBuilder<Widget>(
                            future: mediaWidget,
                            builder: (context, AsyncSnapshot mediaSnapshot) {
                              if(mediaSnapshot.hasData) {
                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    return SizedBox(
                                      width: constraints.maxWidth / 3,
                                      child: mediaSnapshot.data!,
                                    );
                                  },
                                );
                              } else {
                                return SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: CircularProgressIndicator(
                                    color: colorScheme.secondary,
                                  ),
                                );
                              }
                            }
                          ),
                          FutureBuilder<Widget>(
                            future: mediaWidget,
                            builder: (context, AsyncSnapshot coverSnapshot) {
                              if(coverSnapshot.hasData) {
                                return const SizedBox(
                                  height: 10,
                                );
                              } else {
                                return Container();
                              }
                            }
                          ),
                          Quill.QuillEditor.basic(
                            controller: _quizContentController,
                            configurations: const Quill.QuillEditorConfigurations(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ),
        const SizedBox(
          height: 15,
        ),
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: quizIndex > 0,
                child: ElevatedButton(
                  onPressed: () async {
                    final LoadingDialogService loading = LoadingDialogService();
                    loading.presentLoading(context);

                    quizIndex--;

                    final CreateUpdateOne checkCurrentChoice = quizChoiceList.firstWhere((e) => e.id == assessment!.quizzes[quizIndex].id);
                    if(checkCurrentChoice.choice_id != 0) {
                      choiceSelection = assessment!.quizzes[quizIndex].choices.firstWhere((e) => e.id == checkCurrentChoice.choice_id);
                    } else {
                      choiceSelection = null;
                    }

                    // ignore: use_build_context_synchronously
                    context.pop();

                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    maximumSize: const Size.fromWidth(140),
                    padding: const EdgeInsets.all(15),
                    backgroundColor: colorScheme.secondary,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back, color: colorScheme.onSecondary,),
                      Text(' ถอยกลับ', style: TextStyle(fontSize: 16, color: colorScheme.onSecondary,),),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: (quizIndex > 0) && (quizIndex < assessment!.quizzes.length - 1),
                child: const SizedBox(
                  width: 50.0,
                ),
              ),
              Visibility(
                visible: quizIndex < assessment!.quizzes.length - 1,
                child: ElevatedButton(
                  onPressed: () async {
                    final LoadingDialogService loading = LoadingDialogService();
                    loading.presentLoading(context);

                    quizIndex++;

                    final CreateUpdateOne checkCurrentChoice = quizChoiceList.firstWhere((e) => e.id == assessment!.quizzes[quizIndex].id);
                    if(checkCurrentChoice.choice_id != 0) {
                      choiceSelection = assessment!.quizzes[quizIndex].choices.firstWhere((e) => e.id == checkCurrentChoice.choice_id);
                    } else {
                      choiceSelection = null;
                    }

                    // ignore: use_build_context_synchronously
                    context.pop();

                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    maximumSize: const Size.fromWidth(140),
                    padding: const EdgeInsets.all(15),
                    backgroundColor: colorScheme.primary,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('ถัดไป ', style: TextStyle(fontSize: 16, color: colorScheme.onPrimary,),),
                      Icon(Icons.arrow_forward, color: colorScheme.onPrimary,),
                    ],
                  ),
                ),
              ),
            ],
          )
        ),
      ],
    );
  }

  showSubmitExamDialog() async {
    return await showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ต้องการส่งกระดาษคำตอบหรือไม่', style: TextStyle(fontSize: 36, color: colorScheme.onSurface,),),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
              ),
              onPressed: () async {
                final bool submitSuccess = await submitExam();

                if(submitSuccess) {
                  // ignore: use_build_context_synchronously
                  context.pop(true);
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('ส่ง', style: TextStyle(fontSize: 20, color: colorScheme.onPrimary,),),
                ],
              ),
            ),
            const SizedBox(
              width: 30.0,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
              ),
              onPressed: () async {
                context.pop(false);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('ยกเลิก', style: TextStyle(fontSize: 20, color: colorScheme.onSecondary,),),
                ],
              ),
            ),
          ],
        );
      },
    ).then((value) => value);
  }

  showExpireDialog() {
    showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('หมดเวลาทำแบบทดสอบ', style: TextStyle(fontSize: 36, color: colorScheme.onSurface,),),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
              ),
              onPressed: () async {
                examTimer?.cancel();
                examTimer = null;

                final bool submitSuccess = await submitExam();

                if(submitSuccess) {
                  final LoadingDialogService loading = LoadingDialogService();
                  // ignore: use_build_context_synchronously
                  loading.presentLoading(context);

                  // ignore: use_build_context_synchronously
                  context.pop();

                  setState(() {
                    isFinish = true;
                    isLoading = false;
                  });
                } else {
                  if(examTime > 0) {
                    examTimer = Timer.periodic(const Duration(seconds: 1), timerCallback);
                  }
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('ตกลง', style: TextStyle(fontSize: 20, color: colorScheme.onSecondary,),),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> submitExam() async {
    if(quizChoiceList.any((e) => e.choice_id == 0)) {
      final AssessmentAPI assessmentAPI = AssessmentAPI();

      for(var quizchoice in quizChoiceList) {
        if(quizchoice.choice_id == 0) {
          final CreateAssessmentQuiz checkingQuiz = assessment!.quizzes.firstWhere((e) => e.id == quizchoice.id);

          for(var choice in checkingQuiz.choices) {
            APIResult resCheckChoice = await assessmentAPI.checkChoice(loginSession.token, assessment!.examid, checkingQuiz.id, choice.id);
            
            if(resCheckChoice.status == 1) {
              final checkChoice = resCheckChoice.result[0] as CheckChoiceModel;

              if(!checkChoice.becorrect) {
                quizchoice.choice_id = checkChoice.id;
                break;
              }
            }
          }
        }
      }
    }

    final AssessmentAPI assessmentAPI = AssessmentAPI();
    APIResult resUpdate = await assessmentAPI.updateOne(loginSession.token, assessment!.assessment_id, assessment!.examid, assessment!.examminute > 0 ? (((assessment!.examminute * 60) - examTime) / 60).ceil() : 1, quizChoiceList);
    if(resUpdate.status == 1) {
      examTimer?.cancel();
      examTimer = null;
      examTime = 0;

      choiceSelection = null;

      loginSession.pretestDone = true;

      return true;
    } else {
      final FailureDialog failureDialog = FailureDialog();

      // ignore: use_build_context_synchronously
      failureDialog.showFailure(context, colorScheme, resUpdate.message);

      return false;
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
        return await buildAudioPlayer(bucketid, mimeType);
      } else if(mimeType.contains('video/')) {
        return await buildVideoPlayer(bucketid, mimeType);
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

  Future<Widget> buildAudioPlayer(String bucketid, String mimeType) async {
    final BucketAPI bucketAPI = BucketAPI();
    final APIResult res = await bucketAPI.readOne(loginSession.token, bucketid);

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

    return LayoutBuilder(
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
    );
  }

  Future<Widget> buildVideoPlayer(String bucketid, String mimeType) async {
    final BucketAPI bucketAPI = BucketAPI();
    final APIResult res = await bucketAPI.readOne(loginSession.token, bucketid);

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

    return LayoutBuilder(
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
    );
  }

  Widget buildPDFLink(String bucketid) {
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

  Widget buildMSWordLink(String bucketid, String mimeType) {
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

  Widget buildMSExcelLink(String bucketid, String mimeType) {
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

  Widget buildMSPowerpointLink(String bucketid, String mimeType) {
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

}