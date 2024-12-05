import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import 'package:cai_gameengine/constansts/maturity_rating.const.dart';

import 'package:cai_gameengine/components/selectors/lesson.selector.dart';
import 'package:cai_gameengine/components/selectors/module.selector.dart';
import 'package:cai_gameengine/components/common/image_thumbnail.widget.dart';

import 'package:cai_gameengine/api/exam.api.dart';
import 'package:cai_gameengine/api/module.api.dart';
import 'package:cai_gameengine/api/bucket.api.dart';

import 'package:cai_gameengine/services/loading_dialog.service.dart';
import 'package:cai_gameengine/services/success_snackbar.service.dart';
import 'package:cai_gameengine/services/failure_dialog.service.dart';

import 'package:cai_gameengine/models/api_result.model.dart';
import 'package:cai_gameengine/models/login_session.model.dart';
import 'package:cai_gameengine/models/exam.model.dart';
import 'package:cai_gameengine/models/module.model.dart';
import 'package:cai_gameengine/models/lesson.model.dart';
import 'package:cai_gameengine/models/bucket.model.dart';
import 'package:cai_gameengine/models/create_bucket.model.dart';

class ExamDialog extends StatefulWidget {
  const ExamDialog({super.key, required this.inExamID});

  final int? inExamID;

  @override
  State<ExamDialog> createState() => _ExamDialogState();
}

class _ExamDialogState extends State<ExamDialog> {
  ExamModel? editExam;

  final formKey = GlobalKey<FormState>();
  TextEditingController examcodeController = TextEditingController();

  int? moduleIDSelection;
  TextEditingController moduleController = TextEditingController();
  int? lessonIDSelection;
  TextEditingController lessonController = TextEditingController();

  TextEditingController maxscoreController = TextEditingController();
  TextEditingController examminuteController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController captionController = TextEditingController();
  TextEditingController descrController = TextEditingController();
  int maturityratingSearchSelection = 0;
  TextEditingController tagsController = TextEditingController();

  Uint8List? originalMediaBytes;

  TextEditingController mediafileController = TextEditingController();
  PlatformFile? mediaFile;
  Uint8List? mediaBytes;
  Widget? media;

  bool isFormValid = false;

  LoginSessionModel? loginSession;
  late BoxConstraints globalConstraints;
  late ColorScheme colorScheme;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      loginSession = context.read<LoginSessionModel>();

      if(widget.inExamID != null) {
        await initializeEditData();
      }
    });
  }

  initializeEditData() async {
    final LoadingDialogService loading = LoadingDialogService();
    // ignore: use_build_context_synchronously
    loading.presentLoading(context);

    bool valid = true;

    await getExam(widget.inExamID!);

    examcodeController.text = editExam!.examcode;

    if(editExam!.module_id != 0) {
      final ModuleAPI moduleAPI = ModuleAPI();
      APIResult resModule = await moduleAPI.readOne(loginSession!.token, editExam!.module_id);

      if(resModule.status == 1) {
        moduleIDSelection = (resModule.result[0] as ModuleModel).id;
        moduleController.text = (resModule.result[0] as ModuleModel).modulecode;
      }
    }

    if(editExam!.lesson_id != 0) {
      final ModuleAPI moduleAPI = ModuleAPI();
      APIResult resLesson = await moduleAPI.readLessonOne(loginSession!.token, editExam!.lesson_id);

      if(resLesson.status == 1) {
        lessonIDSelection = (resLesson.result[0] as LessonModel).id;
        lessonController.text = (resLesson.result[0] as LessonModel).lessoncode;
      }
    }
    
    maxscoreController.text = editExam!.maxscore.toString();
    examminuteController.text = editExam!.examminute.toString();
    titleController.text = editExam!.title;
    captionController.text = editExam!.caption;
    descrController.text = editExam!.descr ?? '';
    maturityratingSearchSelection = editExam!.maturityrating;
    tagsController.text = editExam!.tags.join(',');

    if(editExam!.coverid != null && editExam!.coverid!.isNotEmpty) {
      await getCover(editExam!.coverid!);
    }

    setState(() {
      isFormValid = valid;
    });

    // ignore: use_build_context_synchronously
    context.pop();
  }

  getCover(String bucketid) async {
    final BucketAPI bucketAPI = BucketAPI();
    final APIResult res = await bucketAPI.readOne(loginSession!.token, bucketid);

    if(res.status == 1) {
      setState(() {
        final bucket = res.result[0] as BucketModel;

        originalMediaBytes = bucket.bucketdata.data;

        mediafileController.text = bucket.bucketname;
        mediaBytes = originalMediaBytes;

        media = ImageThumbnailWidget(image: Image.memory(mediaBytes!));
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getExam(int examID) async {
    final ExamAPI examAPI = ExamAPI();
    final APIResult res = await examAPI.readOne(loginSession!.token, examID);

    if(res.status == 1) {
      setState(() {
        editExam = res.result[0] as ExamModel;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      colorScheme = Theme.of(context).colorScheme;
    });

    final isEdit = editExam != null;
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
                                Text(' ${isEdit ? 'แก้ไข' : 'เพิ่ม'}แบบทดสอบ', style: const TextStyle(fontSize: 30,),),
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
                              validateExamForm();
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: TextFormField(
                                    controller: examcodeController,
                                    autocorrect: false,
                                    maxLength: 40,
                                    decoration: const InputDecoration(
                                      labelText: 'รหัสแบบทดสอบ',
                                      counterText: ' ',
                                      border: OutlineInputBorder(),
                                      floatingLabelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      errorStyle: TextStyle(fontSize: 14, height: 0.8),
                                    ),
                                    validator: (value) => value!.isNotEmpty ? null : 'กรุณาระบุรหัสแบบทดสอบ',
                                    onFieldSubmitted: (value) {
                                      if(isFormValid) {
                                        examSubmit();
                                      }
                                    },
                                    textInputAction: TextInputAction.none,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: TextFormField(
                                    controller: moduleController,
                                    autocorrect: false,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: 'โมดูล',
                                      counterText: ' ',
                                      border: const OutlineInputBorder(),
                                      floatingLabelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      errorStyle: const TextStyle(fontSize: 14, height: 0.8),
                                      icon: IconButton(
                                        onPressed: () async {
                                          final ModuleModel? module = await showDialog<ModuleModel>(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (BuildContext context) {
                                              return const ModuleSelector();
                                            },
                                          ).then((value) => value);

                                          if(module != null) {
                                            setState(() {
                                              moduleIDSelection = module.id;
                                              moduleController.text = module.modulecode;
                                            });
                                          }
                                        },
                                        color: colorScheme.primary,
                                        icon: const Icon(Icons.view_module),
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: moduleIDSelection == null ?
                                          null :
                                          () {
                                            setState(() {
                                              moduleIDSelection = null;
                                              moduleController.text = '';

                                              lessonIDSelection = null;
                                              lessonController.text = '';
                                            });
                                          },
                                        icon: const Icon(Icons.clear),
                                      ),
                                    ),
                                    validator: (value) => moduleIDSelection == null ? 'กรุณาระบุโมดูลของแบบทดสอบ' : null,
                                    onFieldSubmitted: (value) {
                                      if(isFormValid) {
                                        examSubmit();
                                      }
                                    },
                                    textInputAction: TextInputAction.none,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: TextFormField(
                                    controller: lessonController,
                                    autocorrect: false,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: 'บทเรียน',
                                      counterText: ' ',
                                      border: const OutlineInputBorder(),
                                      floatingLabelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      errorStyle: const TextStyle(fontSize: 14, height: 0.8),
                                      icon: IconButton(
                                        tooltip: moduleIDSelection == null ? 'กรุณาเลือกโมดูลก่อนเลือกบทเรียน' : null,
                                        onPressed: moduleIDSelection == null ? null : () async {
                                          final LessonModel? lesson = await showDialog<LessonModel>(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (BuildContext context) {
                                              return LessonSelector(inModuleID: moduleIDSelection!);
                                            },
                                          ).then((value) => value);

                                          if(lesson != null) {
                                            setState(() {
                                              lessonIDSelection = lesson.id;
                                              lessonController.text = lesson.lessoncode;
                                            });
                                          }
                                        },
                                        color: colorScheme.primary,
                                        icon: const Icon(Icons.quiz),
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: lessonIDSelection == null ?
                                          null :
                                          () {
                                            setState(() {
                                              lessonIDSelection = null;
                                              lessonController.text = '';
                                            });
                                          },
                                        icon: const Icon(Icons.clear),
                                      ),
                                    ),
                                    onFieldSubmitted: (value) {
                                      if(isFormValid) {
                                        examSubmit();
                                      }
                                    },
                                    textInputAction: TextInputAction.none,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: TextFormField(
                                    controller: maxscoreController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'(^\d+)'),)],
                                    autocorrect: false,
                                    decoration: const InputDecoration(
                                      labelText: 'คะแนนเต็ม',
                                      counterText: ' ',
                                      border: OutlineInputBorder(),
                                      floatingLabelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      errorStyle: TextStyle(fontSize: 14, height: 0.8),
                                    ),
                                    validator: (value) => value!.isNotEmpty && RegExp(r'(^\d+$)').hasMatch(value) && int.parse(value) > 0 ? null : 'กรุณาระบุคะแนนเต็ม',
                                    onFieldSubmitted: (value) {
                                      if(isFormValid) {
                                        examSubmit();
                                      }
                                    },
                                    textInputAction: TextInputAction.none,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: TextFormField(
                                    controller: examminuteController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'(^\d+)'),)],
                                    autocorrect: false,
                                    decoration: const InputDecoration(
                                      labelText: 'เวลาสอบ (นาที)',
                                      counterText: ' ',
                                      border: OutlineInputBorder(),
                                      floatingLabelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      errorStyle: TextStyle(fontSize: 14, height: 0.8),
                                    ),
                                    validator: (value) => value!.isNotEmpty && RegExp(r'(^\d+$)').hasMatch(value) && int.parse(value) >= 0 ? null : 'กรุณาระบุคะแนนเต็ม',
                                    onFieldSubmitted: (value) {
                                      if(isFormValid) {
                                        examSubmit();
                                      }
                                    },
                                    textInputAction: TextInputAction.none,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: TextFormField(
                                    controller: titleController,
                                    autocorrect: false,
                                    maxLength: 120,
                                    decoration: const InputDecoration(
                                      labelText: 'ชื่อเรื่อง',
                                      counterText: ' ',
                                      border: OutlineInputBorder(),
                                      floatingLabelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      errorStyle: TextStyle(fontSize: 14, height: 0.8),
                                    ),
                                    validator: (value) => value!.isNotEmpty ? null : 'กรุณาระบุชื่อเรื่อง',
                                    onFieldSubmitted: (value) {
                                      if(isFormValid) {
                                        examSubmit();
                                      }
                                    },
                                    textInputAction: TextInputAction.none,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: TextFormField(
                                    controller: captionController,
                                    autocorrect: false,
                                    maxLength: 250,
                                    decoration: const InputDecoration(
                                      labelText: 'คำชี้แจง',
                                      counterText: ' ',
                                      border: OutlineInputBorder(),
                                      floatingLabelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      errorStyle: TextStyle(fontSize: 14, height: 0.8),
                                    ),
                                    onFieldSubmitted: (value) {
                                      if(isFormValid) {
                                        examSubmit();
                                      }
                                    },
                                    textInputAction: TextInputAction.none,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: TextFormField(
                                    controller: descrController,
                                    autocorrect: false,
                                    minLines: 3,
                                    maxLines: 3,
                                    maxLength: 1000,
                                    decoration: const InputDecoration(
                                      labelText: 'รายละเอียด',
                                      counterText: ' ',
                                      border: OutlineInputBorder(),
                                      floatingLabelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      errorStyle: TextStyle(fontSize: 14, height: 0.8),
                                    ),
                                    onFieldSubmitted: (value) {
                                      if(isFormValid) {
                                        examSubmit();
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
                                      labelText: 'ภาพปก',
                                      counterText: ' ',
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

                                            if(mimeType!.startsWith('image/')) {
                                              mediafileController.text = result.files[0].name;
                                              mediaFile = result.files[0];
                                              mediaBytes = result.files[0].bytes!;

                                              media = ImageThumbnailWidget(image: Image.memory(mediaBytes!));
                                            } else {
                                              final FailureDialog failureDialog = FailureDialog();

                                              // ignore: use_build_context_synchronously
                                              failureDialog.showFailure(context, colorScheme, 'ไม่ใช่ไฟล์ภาพที่ถูกต้อง');
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
                                        examSubmit();
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
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: DropdownButtonFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'ระดับวัยที่เหมาะสม',
                                      counterText: ' ',
                                      border: OutlineInputBorder(),
                                      floatingLabelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      errorStyle: TextStyle(fontSize: 14, height: 0.8),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        maturityratingSearchSelection = value!;
                                      });
                                    },
                                    value: maturityratingSearchSelection,
                                    items: [
                                      ...MaturityRating.entries.map((docStatus) {
                                        return DropdownMenuItem(
                                          value: docStatus.key,
                                          child: Text(docStatus.value),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: TextFormField(
                                    controller: tagsController,
                                    autocorrect: false,
                                    decoration: const InputDecoration(
                                      labelText: 'ป้ายกำกับ',
                                      counterText: ' ',
                                      border: OutlineInputBorder(),
                                      floatingLabelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      errorStyle: TextStyle(fontSize: 14, height: 0.8),
                                    ),
                                    onFieldSubmitted: (value) {
                                      if(isFormValid) {
                                        examSubmit();
                                      }
                                    },
                                    textInputAction: TextInputAction.none,
                                  ),
                                ),
                              ],
                            ),
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
                              onPressed: !isFormValid ?
                                null :
                                () {
                                  examSubmit();
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

  validateExamForm() {
    if(formKey.currentState!.validate()) {
      setState(() {
        isFormValid = true;
      });
    } else {
      setState(() {
        isFormValid = false;
      });
    }
  }

  examSubmit() async {
    final LoadingDialogService loading = LoadingDialogService();
    loading.presentLoading(context);

    String? coverid;
    if(editExam != null) {
      if(mediaBytes == null && originalMediaBytes != null) {
        final BucketAPI bucketAPI = BucketAPI();

        await bucketAPI.deleteOne(loginSession!.token, editExam!.coverid!);

        coverid = null;
      } else if(mediaBytes != null && mediaBytes.toString() != originalMediaBytes.toString()) {
        final BucketAPI bucketAPI = BucketAPI();
        APIResult bucketRes = await bucketAPI.createOne(loginSession!.token, mediaFile!);

        if(bucketRes.status == 1) {
          coverid = (bucketRes.result[0] as CreateBucketModel).bucketid;

          if(editExam!.coverid != null && editExam!.coverid!.isNotEmpty) {
            await bucketAPI.deleteOne(loginSession!.token, editExam!.coverid!);
          }
        } else if(editExam!.coverid != null) {
          coverid = editExam!.coverid;
        }
      } else if(mediaBytes.toString() == originalMediaBytes.toString()) {
        coverid = editExam!.coverid;
      }
    } else if(mediaBytes != null) {
      final BucketAPI bucketAPI = BucketAPI();
      APIResult bucketRes = await bucketAPI.createOne(loginSession!.token, mediaFile!);

      if(bucketRes.status == 1) {
        coverid = (bucketRes.result[0] as CreateBucketModel).bucketid;
      }
    }
    
    final ExamAPI examAPI = ExamAPI();

    APIResult res;
    String message;
    if(widget.inExamID == null) {
      res = await examAPI.createOne(loginSession!.token, examcodeController.text, moduleIDSelection ?? 0, lessonIDSelection ?? 0, int.tryParse(maxscoreController.text) ?? 0, double.tryParse(examminuteController.text) ?? 0, titleController.text, captionController.text, descrController.text, coverid, maturityratingSearchSelection, tagsController.text.split(','));
      message = 'เพิ่มแบบทดสอบเรียบร้อยแล้ว';
    } else {
      res = await examAPI.updateOne(loginSession!.token, widget.inExamID!, examcodeController.text, moduleIDSelection ?? 0, lessonIDSelection ?? 0, int.tryParse(maxscoreController.text) ?? 0, double.tryParse(examminuteController.text) ?? 0, titleController.text, captionController.text, descrController.text, coverid, maturityratingSearchSelection, tagsController.text.split(','));
      message = 'แก้ไขข้อมูลแบบทดสอบเรียบร้อยแล้ว';
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