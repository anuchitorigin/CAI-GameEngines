import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:cai_gameengine/models/login_session.model.dart';

import 'package:cai_gameengine/api/authen.api.dart';

import 'package:cai_gameengine/services/loading_dialog.service.dart';
import 'package:cai_gameengine/services/failure_dialog.service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();

  late bool isFormValid;

  final AuthenAPI authenAPI = AuthenAPI();

  late ColorScheme colorScheme;

  @override
  void initState() {
    isFormValid = false;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    colorScheme = Theme.of(context).colorScheme;

    return Consumer<LoginSessionModel>(
      builder: (context, loginSession, child) {
        if(loginSession.sessionActive) {
          Future.delayed(const Duration(seconds: 3)).then((value) {
            // ignore: use_build_context_synchronously
            context.go('/dashboard');
          },);

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(color: colorScheme.brightness == Brightness.light ? const Color(0xFF000000) : const Color(0xFFFFFFFF),),
                  ),
                ],
              ),
            ],
          );
        } else {
          return createContent();
        }
      }
    );
  }

  createContent() {
    // AppLocalizations translate = AppLocalizations.of(context);

    return Builder(
      builder: (context) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                Card(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("ลงทะเบียนผู้ใช้ใหม่", style: TextStyle(fontSize: 22, color: colorScheme.onPrimaryContainer)),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5, left: 10, bottom: 10, right: 10),
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
                                  padding: const EdgeInsets.only(top: 20),
                                  child: TextFormField(
                                    controller: usernameController,
                                    autocorrect: false,
                                    decoration: const InputDecoration(
                                      labelText: 'รหัสประจำตัวนิสิต',
                                      counterText: ' ',
                                      border: OutlineInputBorder(),
                                      floatingLabelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      errorStyle: TextStyle(fontSize: 14, height: 0.8),
                                    ),
                                    validator: (value) => value!.length >= 4 ? null : 'รหัสประจำตัวนิสิตต้องมีความยาวอย่างน้อย 4 ตัวอักษร',
                                    onFieldSubmitted: (value) {
                                      signupSubmit();
                                    },
                                    textInputAction: TextInputAction.none,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
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
                                      signupSubmit();
                                    },
                                    textInputAction: TextInputAction.none,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
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
                                    validator: (value) => value!.length >= 2 ? null : 'นามสกุลต้องมีความยาวอย่างน้อย 2 ตัวอักษร',
                                    onFieldSubmitted: (value) {
                                      signupSubmit();
                                    },
                                    textInputAction: TextInputAction.none,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        onPressed: !isFormValid ? null : () { signupSubmit(); },
                                        style: ElevatedButton.styleFrom(
                                          fixedSize: const Size.fromWidth(160),
                                          backgroundColor: colorScheme.secondary,
                                          padding: const EdgeInsets.all(15),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.save, color: colorScheme.onSecondary),
                                            Text(' บันทึก', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSecondary),),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 60,
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          context.go('/login');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          fixedSize: const Size.fromWidth(160),
                                          backgroundColor: colorScheme.tertiary,
                                          padding: const EdgeInsets.all(15),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.arrow_back_ios, color: colorScheme.onTertiary),
                                            Text(' ถอยกลับ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onTertiary),),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Spacer(),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> signupSubmit() async {
    if(isFormValid) {
      LoadingDialogService loading = LoadingDialogService();
      loading.presentLoading(context);

      var res = await authenAPI.localSignup(usernameController.text, firstnameController.text, lastnameController.text, 'AUTH_STUDENT');

      if(res.status == 1) {
        // ignore: use_build_context_synchronously
        context.pop();

        registerUserSuccessDialog(usernameController.text, res.result[0].passcode);
      } else {
        // ignore: use_build_context_synchronously
        context.pop();

        final FailureDialog failureDialog = FailureDialog();

        // ignore: use_build_context_synchronously
        failureDialog.showFailure(context, colorScheme, res.message);
      }
    }
  }

  registerUserSuccessDialog(String name, String password) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, size: 30, color: colorScheme.brightness == Brightness.light ? const Color( 0xFF0FF000 ) : const Color( 0xFF009000 ),),
            const Text(' ลงทะเบียนผู้ใช้ใหม่เรียบร้อยแล้ว', style: TextStyle(fontSize: 30,),),
          ],
        ),
        content: SelectionArea(
          child: Text('รหัสประจำตัวนิสิต: $name\nรหัสผ่าน: $password', style: const TextStyle(fontSize: 22,),),
        ),
        actions: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.secondary,
              padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
            ),
            onPressed: () {
              context.pop();
              context.go('/login');
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
    );
  }
}