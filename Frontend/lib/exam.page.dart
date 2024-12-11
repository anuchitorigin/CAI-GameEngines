import 'dart:async';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
// ignore: library_prefixes
import 'package:flutter_quill/flutter_quill.dart' as Quill;

import 'package:cai_gameengine/components/common/image_thumbnail.widget.dart';
import 'package:cai_gameengine/components/common/exam_timer.widget.dart';

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
  int finishminute = 0;
  int finishscore = 0;
  int maxscore = 0;

  final Quill.QuillController _quizContentController = Quill.QuillController.basic();

  int quizIndex = -1;

  bool stopTimer = false;
  int examTime = 0;

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
    if(loginSession.token.isNotEmpty && module != null) {
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
    } else {
      setState(() {
        noModuleOrExam = true;
        isLoading = false;
      });
    }
  }

  getQuizContent(String contentid) async {
    final ContentAPI contentAPI = ContentAPI();
    APIResult resContent = await contentAPI.readOne(loginSession.token, contentid);

    if(resContent.status == 1) {
      if((resContent.result[0] as ContentModel).bucketdata.data.isNotEmpty) {
        if(mounted) {
          setState(() {
            _quizContentController.document = Quill.Document.fromJson(jsonDecode(utf8.decode((resContent.result[0] as ContentModel).bucketdata.data)));
          });
        }
      }
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
                    Text('ไม่พบโมดูลหรือแบบทดสอบในระบบ', style: TextStyle(fontSize: 20.sp),),
                  ],
                );
              } else if(isFinish) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('สรุปผล', style: TextStyle(fontSize: 18.sp),),
                    Text(assessment!.title, style: TextStyle(fontSize: 20.sp),),
                    Text('คะแนน $finishscore/$maxscore', style: TextStyle(fontSize: 17.sp, color: Colors.grey,),),
                    Text('เวลา: $finishminute.00 นาที', style: TextStyle(fontSize: 17.sp, color: Colors.grey,),),
                    const SizedBox(
                      height: 30.0,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final LoadingDialogService loading = LoadingDialogService();
                        loading.presentLoading(context);

                        examTime = assessment!.examminute.toInt() * 60;

                        quizIndex = -1;
                        choiceSelection = null;

                        for(var quizChoice in quizChoiceList) {
                          quizChoice.choice_id = 0;
                        }

                        setState(() {
                          isFinish = false;
                          isLoading = false;
                          stopTimer = true;

                          finishminute = 0;
                          finishscore = 0;
                          maxscore = 0;
                        });

                        context.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        maximumSize: Size.fromWidth(50.sp),
                        padding: EdgeInsets.all(6.sp),
                        backgroundColor: Colors.black,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('ทำแบบทดสอบอีกครั้ง', style: TextStyle(fontSize: 15.sp, color: Colors.white,),),
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
              Text(assessment!.title, style: TextStyle(fontSize: 20.sp),),
              Text(assessment!.caption, style: TextStyle(fontSize: 16.sp),),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.sp, vertical: 4.sp,),
                  child: Container(
                    width: double.maxFinite,
                    height: double.maxFinite,
                    padding: EdgeInsets.all(8.sp),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorScheme.onSurface,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(8.sp)),
                    ),
                    child: SingleChildScrollView(
                      child: Text(assessment!.descr, style: TextStyle(fontSize: 15.sp),),
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
                  examTime = assessment!.examminute.toInt() * 60;
                  setState(() {
                    stopTimer = false;
                  });

                  setState(() {
                    quizIndex++;
                  });
                },
                style: ElevatedButton.styleFrom(
                  maximumSize: Size.fromWidth(45.sp),
                  padding: EdgeInsets.all(10.sp),
                  backgroundColor: colorScheme.primary,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('เริ่มทำแบบทดสอบ ', style: TextStyle(fontSize: 14.sp, color: colorScheme.onPrimary,),),
                    Icon(Icons.arrow_forward, size: 14.sp, color: colorScheme.onPrimary,),
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
      mediaWidget = Future.value(const SizedBox(width: 0.0, height: 0.0,));
    }

    if(currentQuiz.contentid.isNotEmpty && _quizContentController.document.isEmpty()) {
      getQuizContent(currentQuiz.contentid);
    }

    return Column(
      children: [
        const SizedBox(
          height: 10.0,
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
              child: Text('แบบทดสอบ: ${assessment!.title}', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold,),),
            ),
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  ExamTimerWidget(
                    isStop: stopTimer,
                    remainingSeconds: examTime,
                    onCount: (remainingTime) {
                      examTime = remainingTime;

                      if(examTime <= 0) {
                        showExpireDialog();
                      }
                    }
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            stopTimer = true;
                          });

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
                            setState(() {
                              stopTimer = false;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          maximumSize: Size.fromWidth(40.sp),
                          padding: EdgeInsets.all(6.sp),
                          backgroundColor: Colors.black,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('ส่งกระดาษคำตอบ', style: TextStyle(fontSize: 13.sp, color: Colors.white,),),
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
          flex: 8,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: globalConstraints.maxWidth > 768 ? 1 : 0,
                  child: Container(),
                ),
                Expanded(
                  flex: 5,
                  child: SizedBox(
                    height: double.maxFinite,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${currentQuiz.quizno}. ${currentQuiz.question}', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold,),),
                          const SizedBox(
                            height: 10.0,
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: currentQuiz.choices.length,
                            itemBuilder: (context, index) {
                              Future<Widget> choiceMediaWidget = Future.value(const SizedBox(width: 0.0, height: 0.0,));
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
                                      SizedBox(
                                        width: 6.sp,
                                      ),
                                      FutureBuilder<Widget>(
                                        future: choiceMediaWidget,
                                        builder: (context, AsyncSnapshot coverSnapshot) {
                                          if(coverSnapshot.hasData) {
                                            if(coverSnapshot.data!.toString() != 'SizedBox.shrink') {
                                              return Container(
                                                width: 30.sp,
                                                height: 30.sp,
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
                                              width: 30.sp,
                                              height: 30.sp,
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
                                            if(coverSnapshot.data!.toString() != 'SizedBox.shrink') {
                                              return SizedBox(
                                                width: 6.sp,
                                              );
                                            } else {
                                              return const SizedBox(width: 0.0, height: 0.0,);
                                            }
                                          } else {
                                            return const SizedBox(width: 0.0, height: 0.0,);
                                          }
                                        }
                                      ),
                                      Expanded(
                                        child: SizedBox(
                                          child: Text(currentQuiz.choices[index].answer, style: TextStyle(fontSize: 14.sp, color: colorScheme.onSurface,),),
                                        ),
                                      ),
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
                ),
                Visibility(
                  visible: currentQuiz.mediaid.isNotEmpty || !_quizContentController.document.isEmpty(),
                  child: Expanded(
                    flex: 5,
                    child: Container(
                      padding: EdgeInsets.all(6.sp),
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
                                  if(mediaSnapshot.data!.toString() != 'SizedBox.shrink') {
                                    return LayoutBuilder(
                                      builder: (context, constraints) {
                                        return SizedBox(
                                          width: constraints.maxWidth / 3,
                                          child: mediaSnapshot.data!,
                                        );
                                      },
                                    );
                                  } else {
                                    return const SizedBox(width: 0.0, height: 0.0,);
                                  }
                                } else {
                                  return const SizedBox(width: 0.0, height: 0.0,);
                                }
                              }
                            ),
                            FutureBuilder<Widget>(
                              future: mediaWidget,
                              builder: (context, AsyncSnapshot mediaSnapshot) {
                                if(mediaSnapshot.hasData) {
                                  return SizedBox(
                                    height: 6.sp,
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
                ),
              ],
            ),
          )
        ),
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.only(right: 20.sp),
                  child: Visibility(
                    visible: quizIndex > 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
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

                            setState(() {
                              _quizContentController.document = Quill.Document();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            maximumSize: Size.fromWidth(35.sp),
                            padding: EdgeInsets.all(8.sp),
                            backgroundColor: colorScheme.secondary,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_back, size: 14.sp, color: colorScheme.onSecondary,),
                              Text(' ถอยกลับ', style: TextStyle(fontSize: 14.sp, color: colorScheme.onSecondary,),),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('ไปที่ข้อสอบ', style: TextStyle(fontSize: 12.sp,),),
                    DropdownButton(
                      padding: EdgeInsets.symmetric(horizontal: 7.sp, vertical: 2.sp),
                      onChanged: (value) async {
                        if(value != null) {
                          final LoadingDialogService loading = LoadingDialogService();
                          loading.presentLoading(context);

                          quizIndex = value;

                          final CreateUpdateOne checkCurrentChoice = quizChoiceList.firstWhere((e) => e.id == assessment!.quizzes[quizIndex].id);
                          if(checkCurrentChoice.choice_id != 0) {
                            choiceSelection = assessment!.quizzes[quizIndex].choices.firstWhere((e) => e.id == checkCurrentChoice.choice_id);
                          } else {
                            choiceSelection = null;
                          }

                          // ignore: use_build_context_synchronously
                          context.pop();

                          setState(() {
                            _quizContentController.document = Quill.Document();
                          });
                        }
                      },
                      value: quizIndex,
                      items: assessment!.quizzes.asMap().map((i, element) {
                        return MapEntry(i,
                          DropdownMenuItem<int>(
                            value: i,
                            child: Text('ข้อ ${element.quizno}.', style: TextStyle(fontSize: 14.sp,),),
                          ),
                        );
                      }).values.toList(),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.only(left: 20.sp),
                  child: Visibility(
                    visible: quizIndex < assessment!.quizzes.length - 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ElevatedButton(
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

                            setState(() {
                              _quizContentController.document = Quill.Document();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            maximumSize: Size.fromWidth(35.sp),
                            padding: EdgeInsets.all(8.sp),
                            backgroundColor: colorScheme.primary,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('ถัดไป ', style: TextStyle(fontSize: 14.sp, color: colorScheme.onPrimary,),),
                              Icon(Icons.arrow_forward, size: 14.sp, color: colorScheme.onPrimary,),
                            ],
                          ),
                        )
                      ],
                    ),
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
          title: Text('ต้องการส่งกระดาษคำตอบหรือไม่', style: TextStyle(fontSize: 20.sp, color: colorScheme.onSurface,),),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp,),
              ),
              onPressed: () async {
                final LoadingDialogService loading = LoadingDialogService();
                // ignore: use_build_context_synchronously
                loading.presentLoading(context);

                final bool submitSuccess = await submitExam();

                if(submitSuccess) {
                  final AssessmentAPI assessmentAPI = AssessmentAPI();
                  APIResult resExamResult = await assessmentAPI.readFilter(loginSession.token, 1, 1, "desc", null, null, null, null, loginSession.user!.userid, null, module!.id, 0);
                  if(resExamResult.status == 1) {
                    finishminute = (resExamResult.result[0] as AssessmentModel).finishminute;
                    finishscore = (resExamResult.result[0] as AssessmentModel).finishscore;
                    maxscore = assessment!.maxscore;
                  }

                  // ignore: use_build_context_synchronously
                  context.pop(true);
                  // ignore: use_build_context_synchronously
                  context.pop(true);

                  setState(() {
                    isFinish = true;
                    isLoading = false;
                  });
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('ส่ง', style: TextStyle(fontSize: 16.sp, color: colorScheme.onPrimary,),),
                ],
              ),
            ),
            const SizedBox(
              width: 30.0,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp,),
              ),
              onPressed: () async {
                context.pop(false);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('ยกเลิก', style: TextStyle(fontSize: 16.sp, color: colorScheme.onSecondary,),),
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
          title: Text('หมดเวลาทำแบบทดสอบ', style: TextStyle(fontSize: 20.sp, color: colorScheme.onSurface,),),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp,),
              ),
              onPressed: () async {
                final LoadingDialogService loading = LoadingDialogService();
                // ignore: use_build_context_synchronously
                loading.presentLoading(context);

                final bool submitSuccess = await submitExam();

                if(submitSuccess) {
                  final AssessmentAPI assessmentAPI = AssessmentAPI();
                  APIResult resExamResult = await assessmentAPI.readFilter(loginSession.token, 1, 1, "desc", null, null, null, null, loginSession.user!.userid, null, module!.id, 0);
                  if(resExamResult.status == 1) {
                    finishminute = (resExamResult.result[0] as AssessmentModel).finishminute;
                    finishscore = (resExamResult.result[0] as AssessmentModel).finishscore;
                    maxscore = assessment!.maxscore;
                  }

                  // ignore: use_build_context_synchronously
                  context.pop();
                  // ignore: use_build_context_synchronously
                  context.pop();

                  setState(() {
                    isFinish = true;
                    isLoading = false;
                  });
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('ตกลง', style: TextStyle(fontSize: 16.sp, color: colorScheme.onSecondary,),),
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
    APIResult resUpdate = await assessmentAPI.updateOne(loginSession.token, assessment!.assessment_id, assessment!.examid, assessment!.examminute > 0 && (((assessment!.examminute * 60) - examTime) / 60).ceil() > 0 ? (((assessment!.examminute * 60) - examTime) / 60).ceil() : 1, quizChoiceList);
    if(resUpdate.status == 1) {
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
        return const SizedBox(width: 0.0, height: 0.0,);
      }
    } else {
      return const SizedBox(width: 0.0, height: 0.0,);
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