import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quill/flutter_quill.dart' as Quill;

import 'package:cai_gameengine/api/content.api.dart';
import 'package:cai_gameengine/api/module.api.dart';

import 'package:cai_gameengine/services/loading_dialog.service.dart';
import 'package:cai_gameengine/services/success_snackbar.service.dart';
import 'package:cai_gameengine/services/failure_dialog.service.dart';

import 'package:cai_gameengine/models/api_result.model.dart';
import 'package:cai_gameengine/models/login_session.model.dart';
import 'package:cai_gameengine/models/lesson.model.dart';
import 'package:cai_gameengine/models/create_content.model.dart';
import 'package:cai_gameengine/models/content.model.dart';

class LessonContentDialog extends StatefulWidget {
  const LessonContentDialog({super.key, required this.inLesson});

  final LessonModel inLesson;

  @override
  State<LessonContentDialog> createState() => _LessonContentDialogState();
}

class _LessonContentDialogState extends State<LessonContentDialog> {
  final Quill.QuillController _controller = Quill.QuillController.basic();

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

      final ContentAPI contentAPI = ContentAPI();
      APIResult resContent = await contentAPI.readOne(loginSession!.token, widget.inLesson.contentid);

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
                                const Text(' เนื้อหารายละเอียดสูตร', style: TextStyle(fontSize: 30,),),
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
                                if(_controller.document.length > 1) {
                                  contentSubmit();
                                } else {
                                  final FailureDialog failureDialog = FailureDialog();

                                  // ignore: use_build_context_synchronously
                                  failureDialog.showFailure(context, colorScheme, 'กรุณาเขียนเนื้อหา');
                                }
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
    APIResult resDelete = await contentAPI.deleteOne(loginSession!.token, widget.inLesson.contentid);

    Uint8List bytes = Uint8List.fromList(utf8.encode(jsonEncode(_controller.document.toDelta().toJson())));
    PlatformFile content = PlatformFile(name: 'r${widget.inLesson.id}-${DateFormat('yyyyMMddHHmmss').format(DateTime.now().subtract(DateTime.now().timeZoneOffset))}.txt', size: bytes.lengthInBytes, bytes: bytes);
    APIResult resCreate = await contentAPI.createOne(loginSession!.token, content);

    if(resCreate.status == 1) {
      final String contentid = (resCreate.result[0] as CreateContentModel).contentid;

      final ModuleAPI moduleAPI = ModuleAPI();
      // ignore: unused_local_variable
      APIResult resUpdateItem = await moduleAPI.updateLessonOne(loginSession!.token, widget.inLesson.id, widget.inLesson.lessoncode, widget.inLesson.module_id, widget.inLesson.lessonno, widget.inLesson.title, widget.inLesson.descr, widget.inLesson.coverid, contentid, widget.inLesson.mediaid, widget.inLesson.tags);
    
      // ignore: use_build_context_synchronously
      context.pop();
      // ignore: use_build_context_synchronously
      context.pop(contentid);

      SuccessSnackBar snackbar = SuccessSnackBar();

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(snackbar.showSuccess('บันทึกเนื้อหาเรียบร้อยแล้ว', globalConstraints, colorScheme));
    } else {
      // ignore: use_build_context_synchronously
      context.pop();

      final FailureDialog failureDialog = FailureDialog();

      // ignore: use_build_context_synchronously
      failureDialog.showFailure(context, colorScheme, resCreate.message);
    }
  }
}