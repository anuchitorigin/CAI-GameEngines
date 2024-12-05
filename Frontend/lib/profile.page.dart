import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:cai_gameengine/api/authen.api.dart';
import 'package:cai_gameengine/api/user.api.dart';

import 'package:cai_gameengine/services/loading_dialog.service.dart';
import 'package:cai_gameengine/services/failure_dialog.service.dart';
import 'package:cai_gameengine/services/success_snackbar.service.dart';

import 'package:cai_gameengine/models/api_result.model.dart';
import 'package:cai_gameengine/models/login_session.model.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Consumer<LoginSessionModel>(
      builder: (context, loginSession, _) {
        return LayoutBuilder(
          builder: (context, BoxConstraints constraints) {
            final isLg = constraints.maxWidth > 992;
            final isMd = constraints.maxWidth > 768;
            final isSm = constraints.maxWidth > 576;

            final cardWidth = isLg ? constraints.maxWidth * 0.5 : (isMd ? constraints.maxWidth * 0.7 : (isSm ? constraints.maxWidth * 0.8 : constraints.maxWidth * 0.9));

            return IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: double.infinity,
                    height: 20,
                  ),
                  const Text('โปรไฟล์', style: TextStyle(fontSize: 36),),
                  const SizedBox(
                    width: double.infinity,
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          editProfileDialog(loginSession, context, constraints, colorScheme);
                        },
                        style: ElevatedButton.styleFrom(
                          maximumSize: const Size.fromWidth(140),
                          padding: const EdgeInsets.all(15),
                          backgroundColor: colorScheme.primary,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_square, color: colorScheme.onPrimary,),
                            Text(' แก้ไขข้อมูล', style: TextStyle(fontSize: 16, color: colorScheme.onPrimary,),),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          changePasswordDialog(loginSession, context, constraints, colorScheme);
                        },
                        style: ElevatedButton.styleFrom(
                          maximumSize: const Size.fromWidth(165),
                          padding: const EdgeInsets.all(15),
                          backgroundColor: colorScheme.tertiary,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.password, color: colorScheme.onTertiary,),
                            Text(' เปลี่ยนรหัสผ่าน', style: TextStyle(fontSize: 16, color: colorScheme.onTertiary,),),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: double.infinity,
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 60),
                    child: Container(
                      width: cardWidth,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: const BorderRadius.all(Radius.circular(5)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const SizedBox(
                                width: 130,
                                child: Text('รหัสผู้ใช้', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                              ),
                              Text(loginSession.user!.loginid, style: const TextStyle(fontSize: 20,),),
                            ],
                          ),
                          Divider(
                            thickness: 1,
                            color: colorScheme.onSurface,
                          ),
                          Row(
                            children: [
                              const SizedBox(
                                width: 130,
                                child: Text('รหัสพนักงาน', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                              ),
                              Text(loginSession.user!.employeeid != null ? loginSession.user!.employeeid! : '-', style: const TextStyle(fontSize: 20,),),
                            ],
                          ),
                          Divider(
                            thickness: 1,
                            color: colorScheme.onSurface,
                          ),
                          Row(
                            children: [
                              const SizedBox(
                                width: 130,
                                child: Text('ชื่อ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                              ),
                              Text(loginSession.user!.firstname, style: const TextStyle(fontSize: 20,),),
                            ],
                          ),
                          Divider(
                            thickness: 1,
                            color: colorScheme.onSurface,
                          ),
                          Row(
                            children: [
                              const SizedBox(
                                width: 130,
                                child: Text('นามสกุล', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                              ),
                              Text(loginSession.user!.lastname != null ? loginSession.user!.lastname! : '-', style: const TextStyle(fontSize: 20,),),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }

  editProfileDialog(LoginSessionModel loginSession, BuildContext context, BoxConstraints constraints, ColorScheme colorScheme) {
    final isLg = constraints.maxWidth > 992;
    final isMd = constraints.maxWidth > 768;
    final isSm = constraints.maxWidth > 576;

    final dialogWidth = isLg ? constraints.maxWidth * 0.4 : (isMd ? constraints.maxWidth * 0.5 : (isSm ? constraints.maxWidth * 0.8 : constraints.maxWidth * 0.9));

    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        final formKey = GlobalKey<FormState>();
        TextEditingController firstnameController = TextEditingController(text: loginSession.user!.firstname);
        TextEditingController lastnameController = TextEditingController(text: loginSession.user!.lastname);

        bool isFormValid = true;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              child: SizedBox(
                width: dialogWidth,
                height: 340,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_square, size: 30, color: colorScheme.primary,),
                        const Text(' แก้ไขข้อมูล', style: TextStyle(fontSize: 30,),),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 0, left: 10, bottom: 0, right: 10),
                      child: Form(
                        key: formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onChanged: () {
                          if(formKey.currentState!.validate()) {
                            setState(() {
                              isFormValid = true;
                            });
                          } else {
                            setState(() {
                              isFormValid = false;
                            });
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: TextFormField(
                                controller: firstnameController,
                                autocorrect: false,
                                decoration: const InputDecoration(
                                  labelText: 'ชื่อ',
                                  counterText: ' ',
                                  border: OutlineInputBorder(),
                                  floatingLabelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  errorStyle: TextStyle(fontSize: 14, height: 0.8),
                                ),
                                validator: (value) => value!.length >= 2 ? null : 'ชื่อต้องมีความยาวอย่างน้อย 2 ตัวอักษร',
                                onFieldSubmitted: (value) {
                                  if(isFormValid) {
                                    editProfileSubmit(context, constraints, colorScheme, loginSession, firstnameController.value.text, lastnameController.value.text);
                                  }
                                },
                                textInputAction: TextInputAction.none,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: TextFormField(
                                controller: lastnameController,
                                autocorrect: false,
                                decoration: const InputDecoration(
                                  labelText: 'นามสกุล',
                                  counterText: ' ',
                                  border: OutlineInputBorder(),
                                  floatingLabelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  errorStyle: TextStyle(fontSize: 14, height: 0.8),
                                ),
                                onFieldSubmitted: (value) {
                                  if(isFormValid) {
                                    editProfileSubmit(context, constraints, colorScheme, loginSession, firstnameController.value.text, lastnameController.value.text);
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
                      width: double.infinity,
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
                          onPressed: !isFormValid ? null : () { editProfileSubmit(context, constraints, colorScheme, loginSession, firstnameController.value.text, lastnameController.value.text); },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_square, size: 22, color: colorScheme.onPrimary,),
                              Text(' แก้ไข', style: TextStyle(fontSize: 20, color: colorScheme.onPrimary,),),
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
                            formKey.currentState!.reset();

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
            );
          }
        );
      },
    );
  }

  Future<void> editProfileSubmit(BuildContext context, BoxConstraints constraints, ColorScheme colorScheme, LoginSessionModel loginSession, String firstname, String? lastname) async {
    LoadingDialogService loading = LoadingDialogService();
    loading.presentLoading(context);

    final UserAPI userAPI = UserAPI();
    APIResult res = await userAPI.updateUser(loginSession.token, loginSession.user!.userid!, jsonEncode(loginSession.user!.roleparam), firstname, lastname, loginSession.user!.employeeid, loginSession.user!.remark);

    if(res.status == 1) {
      UserAPI userAPI = UserAPI();

      APIResult getProfile = await userAPI.readProfile(loginSession.token);
      if(getProfile.status == 0) {
        if(getProfile.message == 'Unauthorized') {
          loginSession.clearSession();
        }
      } else {
        loginSession.user = getProfile.result[0];
      }

      // ignore: use_build_context_synchronously
      context.pop();
      // ignore: use_build_context_synchronously
      context.pop();

      SuccessSnackBar snackbar = SuccessSnackBar();

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(snackbar.showSuccess('แก้ไขข้อมูลโปรไฟล์เรียบร้อยแล้ว', constraints, colorScheme));
    } else {
      // ignore: use_build_context_synchronously
      context.pop();

      final FailureDialog failureDialog = FailureDialog();

      // ignore: use_build_context_synchronously
      failureDialog.showFailure(context, colorScheme, res.message);
    }
  }

  changePasswordDialog(LoginSessionModel loginSession, BuildContext context, BoxConstraints constraints, ColorScheme colorScheme) {
    final isLg = constraints.maxWidth > 992;
    final isMd = constraints.maxWidth > 768;
    final isSm = constraints.maxWidth > 576;

    final dialogWidth = isLg ? constraints.maxWidth * 0.4 : (isMd ? constraints.maxWidth * 0.5 : (isSm ? constraints.maxWidth * 0.8 : constraints.maxWidth * 0.9));

    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        final formKey = GlobalKey<FormState>();
        TextEditingController oldPasswordController = TextEditingController();
        TextEditingController newPasswordController = TextEditingController();
        TextEditingController confirmPasswordController = TextEditingController();

        bool isFormValid = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              child: SizedBox(
                width: dialogWidth,
                height: 430,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.password, size: 30, color: colorScheme.tertiary,),
                        const Text(' เปลี่ยนรหัสผ่าน', style: TextStyle(fontSize: 30,),),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 0, left: 10, bottom: 0, right: 10),
                      child: Form(
                        key: formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onChanged: () {
                          if(formKey.currentState!.validate()) {
                            setState(() {
                              isFormValid = true;
                            });
                          } else {
                            setState(() {
                              isFormValid = false;
                            });
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: TextFormField(
                                controller: oldPasswordController,
                                autocorrect: false,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'รหัสผ่านเดิม',
                                  counterText: ' ',
                                  border: OutlineInputBorder(),
                                  floatingLabelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  errorStyle: TextStyle(fontSize: 14, height: 0.8),
                                ),
                                validator: (value) => value!.length >= 4 ? null : 'รหัสต้องมีความยาวอย่างน้อย 4 ตัวอักษร',
                                onFieldSubmitted: (value) {
                                  if(isFormValid) {
                                    changePasswordSubmit(context, constraints, colorScheme, loginSession, oldPasswordController.value.text, newPasswordController.value.text);
                                  }
                                },
                                textInputAction: TextInputAction.none,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: TextFormField(
                                controller: newPasswordController,
                                autocorrect: false,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'รหัสผ่านใหม่',
                                  counterText: ' ',
                                  border: OutlineInputBorder(),
                                  floatingLabelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  errorStyle: TextStyle(fontSize: 14, height: 0.8),
                                ),
                                validator: (value) => value!.length >= 4 ? null : 'รหัสต้องมีความยาวอย่างน้อย 4 ตัวอักษร',
                                onFieldSubmitted: (value) {
                                  if(isFormValid) {
                                    changePasswordSubmit(context, constraints, colorScheme, loginSession, oldPasswordController.value.text, newPasswordController.value.text);
                                  }
                                },
                                textInputAction: TextInputAction.none,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: TextFormField(
                                controller: confirmPasswordController,
                                autocorrect: false,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'ยืนยันรหัสผ่านใหม่',
                                  counterText: ' ',
                                  border: OutlineInputBorder(),
                                  floatingLabelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  errorStyle: TextStyle(fontSize: 14, height: 0.8),
                                ),
                                validator: (value) => value == newPasswordController.value.text ? null : 'การยืนยันรหัสผ่านไม่ถูกต้อง',
                                onFieldSubmitted: (value) {
                                  if(isFormValid) {
                                    changePasswordSubmit(context, constraints, colorScheme, loginSession, oldPasswordController.value.text, newPasswordController.value.text);
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
                      width: double.infinity,
                      height: 25,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.tertiary,
                            padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
                          ),
                          onPressed: !isFormValid ? null : () { changePasswordSubmit(context, constraints, colorScheme, loginSession, oldPasswordController.value.text, newPasswordController.value.text); },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.password, size: 22, color: colorScheme.onTertiary,),
                              Text(' เปลี่ยนรหัสผ่าน', style: TextStyle(fontSize: 20, color: colorScheme.onTertiary,),),
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
                            formKey.currentState!.reset();

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
            );
          }
        );
      },
    );
  }

  changePasswordSubmit(BuildContext context, BoxConstraints constraints, ColorScheme colorScheme, LoginSessionModel loginSession, String oldPassword, String newPassword) async {
    LoadingDialogService loading = LoadingDialogService();
    loading.presentLoading(context);

    final AuthenAPI authenAPI = AuthenAPI();
    APIResult res = await authenAPI.changePassword(loginSession.token, oldPassword, newPassword);

    if(res.status == 1) {
      // ignore: use_build_context_synchronously
      context.pop();
      // ignore: use_build_context_synchronously
      context.pop();

      SuccessSnackBar snackbar = SuccessSnackBar();

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(snackbar.showSuccess('เปลี่ยนรหัสผ่านเรียบร้อยแล้ว', constraints, colorScheme));
    } else {
      // ignore: use_build_context_synchronously
      context.pop();

      final FailureDialog failureDialog = FailureDialog();

      // ignore: use_build_context_synchronously
      failureDialog.showFailure(context, colorScheme, res.message);
    }
  }
}