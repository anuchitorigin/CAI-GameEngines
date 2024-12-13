import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_quill/flutter_quill.dart' as Quill;

import 'package:cai_gameengine/components/common/image_thumbnail.widget.dart';
import 'package:cai_gameengine/components/common/exam_timer.widget.dart';

import 'package:cai_gameengine/services/storage_manager.service.dart';

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
import 'package:cai_gameengine/models/lesson.model.dart';
import 'package:cai_gameengine/models/assessment.model.dart';
import 'package:cai_gameengine/models/bucket.model.dart';
import 'package:cai_gameengine/models/content.model.dart';

class CreateUpdateOneState extends CreateUpdateOne {
  bool becorrect;
  Uint8List feedback;

  CreateUpdateOneState({
    required super.id,
    required super.choice_id,
    required this.becorrect,
    required this.feedback
  });
}

class LessonListItem {
  int lessonID;
  int lessonNo;
  String lessonTitle;

  LessonListItem({
    required this.lessonID,
    required this.lessonNo,
    required this.lessonTitle
  });
}

class LessonPage extends StatefulWidget {
  const LessonPage({super.key});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  final Quill.QuillController _lessonContentController = Quill.QuillController.basic();
  final Quill.QuillController _quizContentController = Quill.QuillController.basic();
  final Quill.QuillController _choiceContentController = Quill.QuillController.basic();
  final Quill.QuillController _feedbackContentController = Quill.QuillController.basic();

  List<LessonListItem> lessonList = [];

  int lessonListIndex = -1;
  int quizIndex = -1;

  bool stopTimer = false;
  int examTime = 0;

  List<CreateUpdateOneState> quizChoiceList = [];

  ModuleModel? module;
  LessonModel? lesson;
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

    _lessonContentController.readOnly = true;
    _quizContentController.readOnly = true;
    _choiceContentController.readOnly = true;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      loading.presentLoading(context);

      loginSession = context.read<LoginSessionModel>();

      await loadModule();

      await loadLessonIDList();

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

      int i = 0;
      do {
        i++;

        APIResult resModule = await moduleAPI.readOne(loginSession.token, i);
        if(resModule.status == 1) {
          module = resModule.result[0] as ModuleModel;
        }
      } while(module == null);
    }
  }

  loadLessonIDList() async {
    if(loginSession.token.isNotEmpty) {
      final ModuleAPI moduleAPI = ModuleAPI();
      APIResult resLessonCount = await moduleAPI.readLessonCount(loginSession.token, module!.id, null, null, null, []);

      if(resLessonCount.status == 1) {
        final int count = (resLessonCount.result[0] as RecordCountModel).RecordCount;

        if(count > 0) {
          APIResult resLessons = await moduleAPI.readLessonFilter(loginSession.token, count, 1, "", module!.id, null, null, null, []);

          if(resLessons.status == 1) {
            final List<LessonModel> lessons = resLessons.result as List<LessonModel>;

            final int length = lessons.length;
            for(int i = 0; i < length; i++) {
              lessonList.add(
                LessonListItem(
                  lessonID: lessons[i].id,
                  lessonNo: lessons[i].lessonno,
                  lessonTitle: lessons[i].title
                )
              );
            }
          }
        }
      }
    }
  }

  loadLesson(int id) async {
    if(loginSession.token.isNotEmpty) {
      final ModuleAPI moduleAPI = ModuleAPI();

      APIResult resLesson = await moduleAPI.readLessonOne(loginSession.token, id);
      if(resLesson.status == 1) {
        lesson = resLesson.result[0] as LessonModel;
      }
    }
  }

  getLessonContent(String contentid) async {
    final ContentAPI contentAPI = ContentAPI();
    APIResult resContent = await contentAPI.readOne(loginSession.token, contentid);

    if(resContent.status == 1) {
      if((resContent.result[0] as ContentModel).bucketdata.data.isNotEmpty) {
        _lessonContentController.document = Quill.Document.fromJson(jsonDecode(utf8.decode((resContent.result[0] as ContentModel).bucketdata.data)));
      } else {
        _lessonContentController.document = Quill.Document();
      }
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
              if(!isLoading && module != null) {
                if(lessonListIndex >= lessonList.length) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('จบบทเรียน', style: TextStyle(fontSize: 18.sp),),
                      Text(module!.title, style: TextStyle(fontSize: 20.sp),),
                      const SizedBox(
                        height: 30.0,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final LoadingDialogService loading = LoadingDialogService();
                          loading.presentLoading(context);

                          lessonListIndex = -1;
                          lesson = null;

                          examTime = 0;

                          quizIndex = -1;
                          choiceSelection = null;
                          quizChoiceList.clear();
                          assessment = null;

                          setState(() {});

                          context.pop();
                        },
                        style: ElevatedButton.styleFrom(
                          maximumSize: Size.fromWidth(45.sp),
                          padding: EdgeInsets.all(6.sp),
                          backgroundColor: Colors.black,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('เริ่มต้นใหม่อีกครั้ง', style: TextStyle(fontSize: 15.sp, color: Colors.white,),),
                          ],
                        ),
                      ),
                    ],
                  );
                } else if(assessment != null && assessment!.quizzes.isNotEmpty) {
                  if(quizIndex >= 0) {
                    return buildQuiz(assessment!.quizzes[quizIndex], globalConstraints.maxWidth);
                  } else {
                    return buildExam();
                  }
                } else if(lesson != null) {
                  return buildLesson();
                } else {
                  return buildModule();
                }
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: cardWidth,
                      padding: EdgeInsets.all(4.sp),
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

  buildModule() {
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
              Text(module!.title, style: TextStyle(fontSize: 20.sp),),
              Text(module!.caption, style: TextStyle(fontSize: 16.sp),),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 6.sp,),
                  child: Container(
                    width: double.maxFinite,
                    height: double.maxFinite,
                    padding: EdgeInsets.all(6.sp),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorScheme.onSurface,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(4.sp)),
                    ),
                    child: SingleChildScrollView(
                      child: Text(module!.descr ?? '', style: TextStyle(fontSize: 14.sp),),
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
                  final LoadingDialogService loading = LoadingDialogService();
                  loading.presentLoading(context);
                  
                  lessonListIndex = 0;
                  await loadLesson(lessonList[lessonListIndex].lessonID);

                  // ignore: use_build_context_synchronously
                  context.pop();

                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  maximumSize: Size.fromWidth(45.sp),
                  padding: EdgeInsets.all(10.sp),
                  backgroundColor: colorScheme.primary,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('เข้าสู่บทเรียน ', style: TextStyle(fontSize: 14.sp, color: colorScheme.onPrimary,),),
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

  buildLesson() {
    Future<Widget> coverWidget;
    if(lesson!.coverid != null && lesson!.coverid!.isNotEmpty) {
      coverWidget = getCover(lesson!.coverid!, lesson!.title);
    } else {
      coverWidget = Future.value(Container());
    }

    Future<Widget?> mediaWidget;
    if(lesson!.mediaid != null && lesson!.mediaid!.isNotEmpty) {
      mediaWidget = getMedia(lesson!.mediaid!);
    } else {
      mediaWidget = Future.value(ImageThumbnailWidget(image: Image.asset('assets/images/default_picture.png',)));
    }

    if(lesson!.contentid.isNotEmpty) {
      getLessonContent(lesson!.contentid);
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
              child: Text(module!.title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold,),),
            ),
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (BuildContext context) {
                          TextEditingController mynoteController = TextEditingController();
                          if(loginSession.user != null) {
                            StorageManager.readData('mynote-${loginSession.user!.userid}').then((onValue) {
                              mynoteController.text = onValue ?? '';
                            });
                          }

                          return LayoutBuilder(
                            builder: (BuildContext context, BoxConstraints constraints) {
                              globalConstraints = constraints;
                              
                              final isLg = constraints.maxWidth > 992;
                              final isMd = constraints.maxWidth > 768;
                              final isSm = constraints.maxWidth > 576;

                              final dialogWidth = isLg ? constraints.maxWidth * 0.4 : (isMd ? constraints.maxWidth * 0.5 : (isSm ? constraints.maxWidth * 0.8 : constraints.maxWidth * 0.9));

                              return Dialog(
                                backgroundColor: colorScheme.surfaceContainer,
                                child: Padding(
                                  padding: EdgeInsets.all(8.sp),
                                  child: SizedBox(
                                    width: dialogWidth,
                                    // height: constraints.maxHeight / 2,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 10.sp,),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Text('โน้ตของฉัน', style: TextStyle(fontSize: 18.sp,),),
                                                ],
                                              ),
                                              IconButton(
                                                style: IconButton.styleFrom(
                                                  fixedSize: Size(20.sp, 20.sp),
                                                  side: BorderSide(color: colorScheme.onSecondary),
                                                  backgroundColor: colorScheme.secondary
                                                ),
                                                onPressed: () {
                                                  context.pop();
                                                },
                                                icon: Icon(Icons.close, size: 15.sp, color: colorScheme.onSecondary,),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: colorScheme.surfaceContainerLow,
                                              border: Border.all(width: 1.0, color: colorScheme.onSurface,),
                                              borderRadius: BorderRadius.circular(4.sp),
                                            ),
                                            child: TextField(
                                              controller: mynoteController,
                                              minLines: 30,
                                              maxLines: 30,
                                            ),
                                          ),
                                        ),
                                        const Divider(
                                          thickness: 1.0,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 10.sp,),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: colorScheme.primary,
                                                  padding: EdgeInsets.symmetric(horizontal: 18.sp, vertical: 6.sp,),
                                                ),
                                                onPressed: () {
                                                  final LoadingDialogService loading = LoadingDialogService();
                                                  loading.presentLoading(context);
                                                  
                                                  StorageManager.saveData('mynote-${loginSession.user!.userid}', mynoteController.value.text);

                                                  context.pop();
                                                  context.pop();
                                                },
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text('บันทึก', style: TextStyle(fontSize: 16.sp, color: colorScheme.onPrimary,),),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: 8.sp,
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: colorScheme.secondary,
                                                  padding: EdgeInsets.symmetric(horizontal: 18.sp, vertical: 6.sp,),
                                                ),
                                                onPressed: () {
                                                  context.pop();
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
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                          );
                        }
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      maximumSize: Size.fromWidth(40.sp),
                      padding: EdgeInsets.all(6.sp),
                      backgroundColor: Colors.black,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('โน้ตของฉัน', style: TextStyle(fontSize: 13.sp, color: Colors.white,),),
                      ],
                    ),
                  )
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
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: globalConstraints.maxHeight - 200,
                        padding: const EdgeInsets.all(10),
                        child: FutureBuilder<Widget?>(
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
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                    width: double.maxFinite,
                    height: double.maxFinite,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          FutureBuilder<Widget>(
                            future: coverWidget,
                            builder: (context, AsyncSnapshot coverSnapshot) {
                              if(coverSnapshot.hasData) {
                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    return SizedBox(
                                      width: constraints.maxWidth / 3,
                                      child: coverSnapshot.data!,
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
                            future: coverWidget,
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
                          SizedBox(
                            child: Text('${lesson!.lessonno}. ${lesson!.title}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold,),),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          lesson!.descr != null ?
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(lesson!.descr ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey,),)
                                ),
                              ],
                            ) :
                            Container(),
                          lesson!.descr != null ?
                            const SizedBox(
                              height: 5,
                            ) :
                            Container(),
                          Quill.QuillEditor.basic(
                            controller: _lessonContentController,
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
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final LoadingDialogService loading = LoadingDialogService();
                        loading.presentLoading(context);

                        setState(() {
                          isLoading = true;
                        });

                        final AssessmentAPI assessmentAPI = AssessmentAPI();
                        try {
                          APIResult resAssessment = await assessmentAPI.createOne(loginSession.token, null, module!.id, lesson!.id);

                          if(resAssessment.status == 1) {
                            // ignore: use_build_context_synchronously
                            context.pop();

                            setState(() {
                              quizIndex = -1;
                              assessment = resAssessment.result[0] as CreateAssessmentResult;

                              examTime = assessment!.examminute.toInt() * 60;

                              final int length = assessment!.quizzes.length;
                              for(int i = 0; i < length; i++) {
                                quizChoiceList.add(
                                  CreateUpdateOneState(
                                    id: assessment!.quizzes[i].id,
                                    choice_id: 0,
                                    becorrect: false,
                                    feedback: Uint8List(0)
                                  )
                                );
                              }

                              isLoading = false;
                            });
                          } else {
                            final FailureDialog failureDialog = FailureDialog();

                            // ignore: use_build_context_synchronously
                            failureDialog.showFailure(context, colorScheme, resAssessment.message);
                          }
                        } catch(err) {
                          final FailureDialog failureDialog = FailureDialog();

                          // ignore: use_build_context_synchronously
                          failureDialog.showFailure(context, colorScheme, 'ไม่มีแบบทดสอบสำหรับบทเรียนนี้');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        maximumSize: Size.fromWidth(40.sp),
                        padding: EdgeInsets.all(8.sp),
                        backgroundColor: Colors.black,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('แบบทดสอบ', style: TextStyle(fontSize: 14.sp, color: Colors.white,),),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 6.sp,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    style: IconButton.styleFrom(
                      fixedSize: Size(18.sp, 18.sp),
                      side: BorderSide(color: colorScheme.onSecondary),
                      backgroundColor: colorScheme.secondary
                    ),
                    onPressed: () async {
                      final LoadingDialogService loading = LoadingDialogService();
                      loading.presentLoading(context);

                      setState(() {
                        isLoading = true;
                      });

                      lessonListIndex--;
                      if(lessonListIndex >= 0) {
                        await loadLesson(lessonList[lessonListIndex].lessonID);

                        // ignore: use_build_context_synchronously
                        context.pop();

                        setState(() {
                          isLoading = false;
                        });
                      } else {
                        mediaWidget = Future.value(null);

                        quizIndex = -1;
                        lesson = null;

                        // ignore: use_build_context_synchronously
                        context.pop();

                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                    icon: Icon(Icons.arrow_back, size: 14.sp, color: colorScheme.onSecondary,),
                  ),
                  // ElevatedButton(
                  //   onPressed: () async {
                  //     final LoadingDialogService loading = LoadingDialogService();
                  //     loading.presentLoading(context);

                  //     setState(() {
                  //       isLoading = true;
                  //     });

                  //     lessonListIndex--;
                  //     if(lessonListIndex >= 0) {
                  //       await loadLesson(lessonList[lessonListIndex].lessonID);

                  //       // ignore: use_build_context_synchronously
                  //       context.pop();

                  //       setState(() {
                  //         isLoading = false;
                  //       });
                  //     } else {
                  //       mediaWidget = Future.value(null);

                  //       quizIndex = -1;
                  //       lesson = null;

                  //       // ignore: use_build_context_synchronously
                  //       context.pop();

                  //       setState(() {
                  //         isLoading = false;
                  //       });
                  //     }
                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //     maximumSize: Size.fromWidth(35.sp),
                  //     padding: EdgeInsets.all(8.sp),
                  //     backgroundColor: colorScheme.secondary,
                  //   ),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       Icon(Icons.arrow_back, color: colorScheme.onSecondary,),
                  //     ],
                  //   ),
                  // ),
                  SizedBox(
                    width: 10.sp,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ไปที่เนื้อหา', style: TextStyle(fontSize: 12.sp,),),
                      DropdownButton(
                        padding: EdgeInsets.symmetric(horizontal: 6.sp, vertical: 1.sp),
                        onChanged: (value) async {
                          if(value != null) {
                            final LoadingDialogService loading = LoadingDialogService();
                            // ignore: use_build_context_synchronously
                            loading.presentLoading(context);

                            lessonListIndex = value;

                            await loadLesson(lessonList[lessonListIndex].lessonID);

                            // ignore: use_build_context_synchronously
                            context.pop();

                            setState(() {});
                          }
                        },
                        value: lessonListIndex,
                        items: lessonList.asMap().map((i, element) {
                          return MapEntry(i,
                            DropdownMenuItem<int>(
                              value: i,
                              child: SizedBox(
                                width: 55.sp,
                                child: Text('${element.lessonNo}. ${element.lessonTitle}', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.sp,),),
                              )
                            ),
                          );
                        }).values.toList(),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 10.sp,
                  ),
                  IconButton(
                    style: IconButton.styleFrom(
                      fixedSize: Size(18.sp, 18.sp),
                      side: BorderSide(color: colorScheme.onPrimary),
                      backgroundColor: colorScheme.primary
                    ),
                    onPressed: () async {
                      final LoadingDialogService loading = LoadingDialogService();
                      loading.presentLoading(context);

                      setState(() {
                        isLoading = true;
                      });

                      lessonListIndex++;
                      if(lessonListIndex < lessonList.length) {
                        await loadLesson(lessonList[lessonListIndex].lessonID);
                      }

                      // ignore: use_build_context_synchronously
                      context.pop();

                      setState(() {
                        isLoading = false;
                      });
                    },
                    icon: Icon(Icons.arrow_forward, size: 14.sp, color: colorScheme.onSecondary,),
                  ),
                  // ElevatedButton(
                  //   onPressed: () async {
                  //     final LoadingDialogService loading = LoadingDialogService();
                  //     loading.presentLoading(context);

                  //     setState(() {
                  //       isLoading = true;
                  //     });

                  //     lessonListIndex++;
                  //     if(lessonListIndex < lessonList.length) {
                  //       await loadLesson(lessonList[lessonListIndex].lessonID);
                  //     }

                  //     // ignore: use_build_context_synchronously
                  //     context.pop();

                  //     setState(() {
                  //       isLoading = false;
                  //     });
                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //     maximumSize: Size.fromWidth(35.sp),
                  //     padding: EdgeInsets.all(8.sp),
                  //     backgroundColor: colorScheme.primary,
                  //   ),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       Icon(Icons.arrow_forward, color: colorScheme.onPrimary,),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
              Container(),
            ],
          )
        ),
      ],
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
                            quizChoiceList.clear();
                            assessment = null;

                            // ignore: use_build_context_synchronously
                            context.pop();

                            setState(() {
                              isLoading = false;
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
                            Text('ปิดแบบทดสอบ', style: TextStyle(fontSize: 13.sp, color: Colors.white,),),
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
                                        onChanged: choiceSelection != null && quizChoiceList.firstWhere((e) => e.id == currentQuiz.id).choice_id == choiceSelection!.id ? null : (QuizChoice? value) async {
                                          setState(() {
                                            choiceSelection = value;
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
                                              return const SizedBox(
                                                width: 10,
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
                                      Visibility(
                                        visible: choiceSelection != null && quizChoiceList.firstWhere((e) => e.id == currentQuiz.id).choice_id == currentQuiz.choices[index].id,
                                        child: SizedBox(
                                          width: 6.sp,
                                        ),
                                      ),
                                      Visibility(
                                        visible: choiceSelection != null && quizChoiceList.firstWhere((e) => e.id == currentQuiz.id).choice_id == currentQuiz.choices[index].id,
                                        child: quizChoiceList.firstWhere((e) => e.id == currentQuiz.id).becorrect ?
                                          Icon(Icons.check, size: 18.sp, color: colorScheme.brightness == Brightness.light ? const Color( 0xFF009000 ) : const Color( 0xFF0FF000 ),) :
                                          Icon(Icons.close, size: 18.sp, color: const Color(0xFFFF0000),),
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
                          Visibility(
                            visible: choiceSelection != null && quizChoiceList.firstWhere((e) => e.id == currentQuiz.id).choice_id == choiceSelection!.id && quizChoiceList.firstWhere((e) => e.id == currentQuiz.id).feedback.isNotEmpty,
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 18.sp, vertical: 4.sp,),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  width: double.maxFinite,
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 3.0, color: colorScheme.onSurface,),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Quill.QuillEditor.basic(
                                    controller: _feedbackContentController,
                                    configurations: const Quill.QuillEditorConfigurations(),
                                  ),
                                ),
                              ),
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
                flex: 1,
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
                            maximumSize: Size.fromWidth(40.sp),
                            padding: EdgeInsets.all(8.sp),
                            backgroundColor: colorScheme.secondary,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_back, size: 15.sp, color: colorScheme.onSecondary,),
                              Text(' ถอยกลับ', style: TextStyle(fontSize: 15.sp, color: colorScheme.onSecondary,),),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Visibility(
              //   visible: quizIndex > 0,
              //   child: ElevatedButton(
              //     onPressed: () async {
                    
              //     },
              //     style: ElevatedButton.styleFrom(
              //       maximumSize: const Size.fromWidth(140),
              //       padding: const EdgeInsets.all(15),
              //       backgroundColor: colorScheme.secondary,
              //     ),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Icon(Icons.arrow_back, color: colorScheme.onSecondary,),
              //         Text(' ถอยกลับ', style: TextStyle(fontSize: 16, color: colorScheme.onSecondary,),),
              //       ],
              //     ),
              //   ),
              // ),
              // Visibility(
              //   visible: quizIndex > 0,
              //   child: const SizedBox(
              //     width: 50.0,
              //   ),
              // ),
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: choiceSelection == null || (choiceSelection != null && quizChoiceList.firstWhere((e) => e.id == currentQuiz.id).choice_id == choiceSelection!.id) ? null : () async {
                    final LoadingDialogService loading = LoadingDialogService();
                    loading.presentLoading(context);

                    final AssessmentAPI assessmentAPI = AssessmentAPI();
                    APIResult resCheckChoice = await assessmentAPI.checkChoice(loginSession.token, assessment!.examid, assessment!.quizzes[quizIndex].id, choiceSelection!.id);
                    if(resCheckChoice.status == 1) {
                      final CheckChoiceModel checkchoice = resCheckChoice.result[0] as CheckChoiceModel;

                      final ContentAPI contentAPI = ContentAPI();
                      APIResult resFeedback = await contentAPI.readOne(loginSession.token, checkchoice.feedbackid);

                      if(resFeedback.status == 1) {
                        final ContentModel feedback = resFeedback.result[0] as ContentModel;

                        // ignore: use_build_context_synchronously
                        context.pop();

                        setState(() {
                          stopTimer = true;
                        });

                        await showFeedbackDialog(checkchoice.becorrect, feedback.bucketdata.data);

                        CreateUpdateOneState quizChoice = quizChoiceList.firstWhere((e) => e.id == currentQuiz.id);
                        quizChoice.choice_id = choiceSelection!.id;
                        quizChoice.becorrect = checkchoice.becorrect;
                        quizChoice.feedback = feedback.bucketdata.data;

                        if(quizChoice.feedback.isNotEmpty) {
                          _feedbackContentController.document = Quill.Document.fromJson(jsonDecode(utf8.decode(quizChoice.feedback)));
                        } else {
                          _feedbackContentController.document = Quill.Document();
                        }

                        setState(() {
                          stopTimer = false;
                        });
                      }
                    }

                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    maximumSize: Size.fromWidth(40.sp),
                    padding: EdgeInsets.all(8.sp),
                    backgroundColor: colorScheme.tertiary,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('ยืนยันคำตอบ', style: TextStyle(fontSize: 15.sp, color: colorScheme.onTertiary,),),
                    ],
                  ),
                ),
              ),
              // Visibility(
              //   visible: quizIndex < assessment!.quizzes.length - 1,
              //   child: const SizedBox(
              //     width: 50.0,
              //   ),
              // ),
              Expanded(
                flex: 1,
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
                            maximumSize: Size.fromWidth(40.sp),
                            padding: EdgeInsets.all(8.sp),
                            backgroundColor: colorScheme.primary,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('ถัดไป ', style: TextStyle(fontSize: 15.sp, color: colorScheme.onPrimary,),),
                              Icon(Icons.arrow_forward, size: 15.sp, color: colorScheme.onPrimary,),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              // Visibility(
              //   visible: quizIndex < assessment!.quizzes.length - 1,
              //   child: ElevatedButton(
              //     onPressed: () async {
              //       final LoadingDialogService loading = LoadingDialogService();
              //       loading.presentLoading(context);

              //       quizIndex++;

              //       final CreateUpdateOne checkCurrentChoice = quizChoiceList.firstWhere((e) => e.id == assessment!.quizzes[quizIndex].id);
              //       if(checkCurrentChoice.choice_id != 0) {
              //         choiceSelection = assessment!.quizzes[quizIndex].choices.firstWhere((e) => e.id == checkCurrentChoice.choice_id);
              //       } else {
              //         choiceSelection = null;
              //       }

              //       // ignore: use_build_context_synchronously
              //       context.pop();

              //       setState(() {});
              //     },
              //     style: ElevatedButton.styleFrom(
              //       maximumSize: const Size.fromWidth(140),
              //       padding: const EdgeInsets.all(15),
              //       backgroundColor: colorScheme.primary,
              //     ),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Text('ถัดไป ', style: TextStyle(fontSize: 16, color: colorScheme.onPrimary,),),
              //         Icon(Icons.arrow_forward, color: colorScheme.onPrimary,),
              //       ],
              //     ),
              //   ),
              // ),
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
          title: Text('ต้องการปิดแบบทดสอบหรือไม่', style: TextStyle(fontSize: 36, color: colorScheme.onSurface,),),
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
                  Text('ปิด', style: TextStyle(fontSize: 20, color: colorScheme.onPrimary,),),
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
                final LoadingDialogService loading = LoadingDialogService();
                // ignore: use_build_context_synchronously
                loading.presentLoading(context);

                final bool submitSuccess = await submitExam();

                // ignore: use_build_context_synchronously
                context.pop();

                if(submitSuccess) {
                  lessonListIndex++;
                  if(lessonListIndex < lessonList.length) {
                    await loadLesson(lessonList[lessonListIndex].lessonID);
                  }
                  
                  // ignore: use_build_context_synchronously
                  context.pop();

                  setState(() {
                    isLoading = false;
                  });
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
      examTime = 0;

      assessment = null;
      choiceSelection = null;
      quizChoiceList.clear();

      return true;
    } else {
      final FailureDialog failureDialog = FailureDialog();

      // ignore: use_build_context_synchronously
      failureDialog.showFailure(context, colorScheme, resUpdate.message);

      return false;
    }
  }

  showFeedbackDialog(bool becorrect, Uint8List data) async {
    if(data.isNotEmpty) {
      _choiceContentController.document = Quill.Document.fromJson(jsonDecode(utf8.decode(data)));
    }

    await showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          becorrect ?
                            Icon(Icons.check, size: 32, color: colorScheme.brightness == Brightness.light ? const Color( 0xFF009000 ) : const Color( 0xFF0FF000 ),) :
                            const Icon(Icons.close, size: 32, color: Color(0xFFFF0000),),
                          Text(becorrect ? ' ตอบถูก' : ' ตอบผิด', style: TextStyle(fontSize: 36, color: colorScheme.onSurface,),),
                        ],
                      ),
                      Visibility(
                        visible: data.isNotEmpty,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(width: 3.0, color: colorScheme.onSurface,),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Quill.QuillEditor.basic(
                                  controller: _choiceContentController,
                                  configurations: const Quill.QuillEditorConfigurations(),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
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
            );
          }
        );
      },
    );
  }

  Future<Widget> getCover(String bucketid, String? name) async {
    final BucketAPI bucketAPI = BucketAPI();
    final APIResult res = await bucketAPI.readOne(loginSession.token, bucketid);

    if(res.status == 1) {
      final bucket = res.result[0] as BucketModel;

      final Uint8List  mediaBytes = bucket.bucketdata.data;
      return ImageThumbnailWidget(image: Image.memory(mediaBytes), title: name);
    } else {
      return ImageThumbnailWidget(image: Image.asset('assets/images/default_picture.png',), title: name);
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