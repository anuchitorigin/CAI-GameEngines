import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';

import 'package:cai_gameengine/components/common/image_thumbnail.widget.dart';

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
import 'package:cai_gameengine/models/create_bucket.model.dart';
import 'package:cai_gameengine/models/create_content.model.dart';
import 'package:cai_gameengine/models/bucket.model.dart';

class LessonDialog extends StatefulWidget {
  const LessonDialog({super.key,required this.inModuleID, required this.inID});

  final int inModuleID;
  final int? inID;

  @override
  State<LessonDialog> createState() => _LessonDialogState();
}

class _LessonDialogState extends State<LessonDialog> {
  LessonModel? editLesson;

  final formKey = GlobalKey<FormState>();
  TextEditingController lessoncodeController = TextEditingController();
  TextEditingController lessonnoController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descrController = TextEditingController();
  TextEditingController tagsController = TextEditingController();

  String? contentid;

  Uint8List? originalCoverBytes;
  TextEditingController coverfileController = TextEditingController();
  PlatformFile? coverFile;
  Uint8List? coverBytes;
  Widget? cover;

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

      if(widget.inID != null) {
        await initializeEditData();
      }
    });
  }

  initializeEditData() async {
    final LoadingDialogService loading = LoadingDialogService();
    // ignore: use_build_context_synchronously
    loading.presentLoading(context);

    bool valid = true;

    await getLesson(widget.inID!);

    lessoncodeController.text = editLesson!.lessoncode;
    lessonnoController.text = editLesson!.lessonno.toString();
    titleController.text = editLesson!.title;
    descrController.text = editLesson!.descr ?? '';
    tagsController.text = editLesson!.tags.join(',');

    contentid = editLesson!.contentid;

    if(editLesson!.coverid != null && editLesson!.coverid!.isNotEmpty) {
      final bucket = await getMedia(editLesson!.coverid!);

      if(bucket != null) {
        originalCoverBytes = bucket.bucketdata.data;

        coverfileController.text = bucket.bucketname;
        coverBytes = originalCoverBytes;

        final mimeType = lookupMimeType(bucket.bucketname);
        if(mimeType!.startsWith('image/')) {
          cover = ImageThumbnailWidget(image: Image.memory(coverBytes!));
        }
      }
    }

    if(editLesson!.mediaid != null && editLesson!.mediaid!.isNotEmpty) {
      final bucket = await getMedia(editLesson!.mediaid!);

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

  Future<void> getLesson(int id) async {
    final ModuleAPI moduleAPI = ModuleAPI();
    final APIResult res = await moduleAPI.readLessonOne(loginSession!.token, id);

    if(res.status == 1) {
      setState(() {
        editLesson = res.result[0] as LessonModel;
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

    final isEdit = editLesson != null;
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
                                Text(' ${isEdit ? 'แก้ไข' : 'เพิ่ม'}บทเรียน', style: const TextStyle(fontSize: 30,),),
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
                              validateLessonForm();
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: TextFormField(
                                    controller: lessoncodeController,
                                    autocorrect: false,
                                    maxLength: 40,
                                    decoration: const InputDecoration(
                                      labelText: 'รหัสบทเรียน',
                                      counterText: ' ',
                                      border: OutlineInputBorder(),
                                      floatingLabelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      errorStyle: TextStyle(fontSize: 14, height: 0.8),
                                    ),
                                    validator: (value) => value!.length >= 2 ? null : 'รหัสบทเรียนต้องมีความยาวอย่างน้อย 2 ตัวอักษร',
                                    onFieldSubmitted: (value) {
                                      if(isFormValid) {
                                        lessonSubmit();
                                      }
                                    },
                                    textInputAction: TextInputAction.none,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: TextFormField(
                                    controller: lessonnoController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'(^\d+)'),)],
                                    autocorrect: false,
                                    decoration: const InputDecoration(
                                      labelText: 'ลำดับ',
                                      counterText: ' ',
                                      border: OutlineInputBorder(),
                                      floatingLabelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      errorStyle: TextStyle(fontSize: 14, height: 0.8),
                                    ),
                                    validator: (value) => value!.isNotEmpty && RegExp(r'(^\d+$)').hasMatch(value) && int.parse(value) > 0 ? null : 'กรุณาระบุลำดับ',
                                    onFieldSubmitted: (value) {
                                      if(isFormValid) {
                                        lessonSubmit();
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
                                    validator: (value) => value!.length >= 2 ? null : 'ชื่อเรื่องต้องมีความยาวอย่างน้อย 2 ตัวอักษร',
                                    onFieldSubmitted: (value) {
                                      if(isFormValid) {
                                        lessonSubmit();
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
                                        lessonSubmit();
                                      }
                                    },
                                    textInputAction: TextInputAction.none,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: TextFormField(
                                    controller: coverfileController,
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
                                              coverfileController.text = result.files[0].name;
                                              coverFile = result.files[0];
                                              coverBytes = result.files[0].bytes!;

                                              cover = ImageThumbnailWidget(image: Image.memory(coverBytes!));
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
                                        onPressed: coverfileController.text.isEmpty ?
                                          null :
                                          () {
                                            setState(() {
                                              coverfileController.text = '';
                                              coverFile = null;
                                              coverBytes = null;
                                              cover = null;
                                            });
                                          },
                                        icon: const Icon(Icons.clear),
                                      ),
                                    ),
                                    onFieldSubmitted: (value) {
                                      if(isFormValid) {
                                        lessonSubmit();
                                      }
                                    },
                                    textInputAction: TextInputAction.none,
                                  ),
                                ),
                                Visibility(
                                  visible: cover != null,
                                  child: SizedBox(
                                    width: double.maxFinite,
                                    height: 125,
                                    child: cover ?? Container(),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: TextFormField(
                                    controller: mediafileController,
                                    autocorrect: false,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: 'สื่อประกอบการสอน (ภาพ, เสียง, วิดีโอ, PDF)',
                                      counterText: ' ',
                                      border: const OutlineInputBorder(),
                                      floatingLabelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      icon: IconButton(
                                        onPressed: () async {
                                          FilePickerResult? result = await FilePicker.platform.pickFiles(
                                            type: FileType.custom,
                                            allowedExtensions: ['jpg', 'jpeg', 'png', 'bmp', 'gif', 'wav', 'm4a', 'mp3', 'mp4', 'mpeg', 'mov', 'avi', 'doc', 'docx', 'xls', 'xlsm', 'xlsx', 'ppt', 'pptx', 'pdf']
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
                                        lessonSubmit();
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
                                        lessonSubmit();
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
                                  lessonSubmit();
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

  validateLessonForm() {
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

  lessonSubmit() async {
    final LoadingDialogService loading = LoadingDialogService();
    loading.presentLoading(context);

    String? coverid;
    if(editLesson != null) {
      if(coverBytes == null && originalCoverBytes != null) {
        final BucketAPI bucketAPI = BucketAPI();

        await bucketAPI.deleteOne(loginSession!.token, editLesson!.coverid!);

        coverid = null;
      } else if(coverBytes != null && coverBytes.toString() != originalCoverBytes.toString()) {
        final BucketAPI bucketAPI = BucketAPI();
        APIResult bucketRes = await bucketAPI.createOne(loginSession!.token, coverFile!);

        if(bucketRes.status == 1) {
          coverid = (bucketRes.result[0] as CreateBucketModel).bucketid;

          if(editLesson!.coverid != null && editLesson!.coverid!.isNotEmpty) {
            await bucketAPI.deleteOne(loginSession!.token, editLesson!.coverid!);
          }
        } else if(editLesson!.coverid != null) {
          coverid = editLesson!.coverid;
        }
      } else if(coverBytes.toString() == originalCoverBytes.toString()) {
        coverid = editLesson!.coverid;
      }
    } else if(coverBytes != null) {
      final BucketAPI bucketAPI = BucketAPI();
      APIResult bucketRes = await bucketAPI.createOne(loginSession!.token, coverFile!);

      if(bucketRes.status == 1) {
        coverid = (bucketRes.result[0] as CreateBucketModel).bucketid;
      }
    }

    String? mediaid;
    if(editLesson != null) {
      if(mediaBytes == null && originalMediaBytes != null) {
        final BucketAPI bucketAPI = BucketAPI();

        await bucketAPI.deleteOne(loginSession!.token, editLesson!.mediaid!);

        mediaid = null;
      } else if(mediaBytes != null && mediaBytes.toString() != originalMediaBytes.toString()) {
        final BucketAPI bucketAPI = BucketAPI();
        APIResult bucketRes = await bucketAPI.createOne(loginSession!.token, mediaFile!);

        if(bucketRes.status == 1) {
          mediaid = (bucketRes.result[0] as CreateBucketModel).bucketid;

          if(editLesson!.mediaid != null && editLesson!.mediaid!.isNotEmpty) {
            await bucketAPI.deleteOne(loginSession!.token, editLesson!.mediaid!);
          }
        } else if(editLesson!.mediaid != null) {
          mediaid = editLesson!.mediaid;
        }
      } else if(mediaBytes.toString() == originalMediaBytes.toString()) {
        mediaid = editLesson!.mediaid;
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
      PlatformFile content = PlatformFile(name: 'm${widget.inModuleID}-${DateFormat('yyyyMMddHHmmss').format(DateTime.now().subtract(DateTime.now().timeZoneOffset))}.txt', size: bytes.lengthInBytes, bytes: bytes);
      APIResult resCreate = await contentAPI.createOne(loginSession!.token, content);

      contentid = (resCreate.result[0] as CreateContentModel).contentid;
    }
    
    final ModuleAPI moduleAPI = ModuleAPI();

    APIResult res;
    String message;
    if(widget.inID == null) {
      res = await moduleAPI.createLessonOne(loginSession!.token, lessoncodeController.value.text, widget.inModuleID, int.parse(lessonnoController.value.text), titleController.value.text, descrController.value.text, coverid, contentid, mediaid, tagsController.text.split(','));
      message = 'เพิ่มบทเรียนเรียบร้อยแล้ว';
    } else {
      res = await moduleAPI.updateLessonOne(loginSession!.token, widget.inID!, lessoncodeController.value.text, widget.inModuleID, int.parse(lessonnoController.value.text), titleController.value.text, descrController.value.text, coverid, contentid, mediaid, tagsController.text.split(','));
      message = 'แก้ไขข้อมูลบทเรียนเรียบร้อยแล้ว';
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