import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import 'package:cai_gameengine/constansts/maturity_rating.const.dart';

import 'package:cai_gameengine/components/common/image_thumbnail.widget.dart';

import 'package:cai_gameengine/api/module.api.dart';
import 'package:cai_gameengine/api/bucket.api.dart';

import 'package:cai_gameengine/services/loading_dialog.service.dart';
import 'package:cai_gameengine/services/success_snackbar.service.dart';
import 'package:cai_gameengine/services/failure_dialog.service.dart';

import 'package:cai_gameengine/models/api_result.model.dart';
import 'package:cai_gameengine/models/login_session.model.dart';
import 'package:cai_gameengine/models/module.model.dart';
import 'package:cai_gameengine/models/bucket.model.dart';
import 'package:cai_gameengine/models/create_bucket.model.dart';

class ModuleDialog extends StatefulWidget {
  const ModuleDialog({super.key, required this.inModuleID});

  final int? inModuleID;

  @override
  State<ModuleDialog> createState() => _ModuleDialogState();
}

class _ModuleDialogState extends State<ModuleDialog> {
  ModuleModel? editModule;

  final formKey = GlobalKey<FormState>();
  TextEditingController modulecodeController = TextEditingController();
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

      if(widget.inModuleID != null) {
        await initializeEditData();
      }
    });
  }

  initializeEditData() async {
    final LoadingDialogService loading = LoadingDialogService();
    // ignore: use_build_context_synchronously
    loading.presentLoading(context);

    bool valid = true;

    await getModule(widget.inModuleID!);

    modulecodeController.text = editModule!.modulecode;
    titleController.text = editModule!.title;
    captionController.text = editModule!.caption;
    descrController.text = editModule!.descr ?? '';
    maturityratingSearchSelection = editModule!.maturityrating;
    tagsController.text = editModule!.tags.join(',');

    if(editModule!.coverid != null && editModule!.coverid!.isNotEmpty) {
      await getCover(editModule!.coverid!);
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

  Future<void> getModule(int moduleID) async {
    final ModuleAPI moduleAPI = ModuleAPI();
    final APIResult res = await moduleAPI.readOne(loginSession!.token, moduleID);

    if(res.status == 1) {
      setState(() {
        editModule = res.result[0] as ModuleModel;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      colorScheme = Theme.of(context).colorScheme;
    });

    final isEdit = editModule != null;
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
                                Text(' ${isEdit ? 'แก้ไข' : 'เพิ่ม'}โมดูล', style: const TextStyle(fontSize: 30,),),
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
                              validateModuleForm();
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: TextFormField(
                                    controller: modulecodeController,
                                    autocorrect: false,
                                    maxLength: 40,
                                    decoration: const InputDecoration(
                                      labelText: 'รหัสโมดูล',
                                      counterText: ' ',
                                      border: OutlineInputBorder(),
                                      floatingLabelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      errorStyle: TextStyle(fontSize: 14, height: 0.8),
                                    ),
                                    validator: (value) => value!.isNotEmpty ? null : 'กรุณาระบุรหัสโมดูล',
                                    onFieldSubmitted: (value) {
                                      if(isFormValid) {
                                        moduleSubmit();
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
                                        moduleSubmit();
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
                                        moduleSubmit();
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
                                        moduleSubmit();
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
                                        moduleSubmit();
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
                                        moduleSubmit();
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
                                  moduleSubmit();
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

  validateModuleForm() {
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

  moduleSubmit() async {
    final LoadingDialogService loading = LoadingDialogService();
    loading.presentLoading(context);

    String? coverid;
    if(editModule != null) {
      if(mediaBytes == null && originalMediaBytes != null) {
        final BucketAPI bucketAPI = BucketAPI();

        await bucketAPI.deleteOne(loginSession!.token, editModule!.coverid!);

        coverid = null;
      } else if(mediaBytes != null && mediaBytes.toString() != originalMediaBytes.toString()) {
        final BucketAPI bucketAPI = BucketAPI();
        APIResult bucketRes = await bucketAPI.createOne(loginSession!.token, mediaFile!);

        if(bucketRes.status == 1) {
          coverid = (bucketRes.result[0] as CreateBucketModel).bucketid;

          if(editModule!.coverid != null && editModule!.coverid!.isNotEmpty) {
            await bucketAPI.deleteOne(loginSession!.token, editModule!.coverid!);
          }
        } else if(editModule!.coverid != null) {
          coverid = editModule!.coverid;
        }
      } else if(mediaBytes.toString() == originalMediaBytes.toString()) {
        coverid = editModule!.coverid;
      }
    } else if(mediaBytes != null) {
      final BucketAPI bucketAPI = BucketAPI();
      APIResult bucketRes = await bucketAPI.createOne(loginSession!.token, mediaFile!);

      if(bucketRes.status == 1) {
        coverid = (bucketRes.result[0] as CreateBucketModel).bucketid;
      }
    }
    
    final ModuleAPI moduleAPI = ModuleAPI();

    APIResult res;
    String message;
    if(widget.inModuleID == null) {
      res = await moduleAPI.createOne(loginSession!.token, modulecodeController.text, titleController.text, captionController.text, descrController.text, coverid, maturityratingSearchSelection, tagsController.text.split(','));
      message = 'เพิ่มโมดูลเรียบร้อยแล้ว';
    } else {
      res = await moduleAPI.updateOne(loginSession!.token, widget.inModuleID!, modulecodeController.text, titleController.text, captionController.text, descrController.text, coverid, maturityratingSearchSelection, tagsController.text.split(','));
      message = 'แก้ไขข้อมูลโมดูลเรียบร้อยแล้ว';
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