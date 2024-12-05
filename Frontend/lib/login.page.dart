import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:cai_gameengine/models/login_session.model.dart';

import 'package:cai_gameengine/api/authen.api.dart';

import 'package:cai_gameengine/services/loading_dialog.service.dart';
import 'package:cai_gameengine/services/failure_dialog.service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

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
                Text("บทเรียนคอมพิวเตอร์ช่วยสอน (CAI)", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                const SizedBox(
                  width: double.infinity,
                  height: 50,
                ),
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
                          Text("เข้าสู่ระบบ", style: TextStyle(fontSize: 22, color: colorScheme.onPrimaryContainer)),
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
                                    loginSubmit();
                                  },
                                  textInputAction: TextInputAction.none,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: TextFormField(
                                  controller: passwordController,
                                  autocorrect: false,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: 'รหัสผ่าน',
                                    counterText: ' ',
                                    border: OutlineInputBorder(),
                                    floatingLabelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    errorStyle: TextStyle(fontSize: 14, height: 0.8),
                                  ),
                                  validator: (value) => value!.length >= 4 ? null : 'รหัสผ่านต้องมีความยาวอย่างน้อย 4 ตัวอักษร',
                                  onFieldSubmitted: (value) {
                                    loginSubmit();
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
                                      onPressed: !isFormValid ? null : () { loginSubmit(); },
                                      style: ElevatedButton.styleFrom(
                                        fixedSize: const Size.fromWidth(160),
                                        backgroundColor: colorScheme.secondary,
                                        padding: const EdgeInsets.all(15),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.login, color: colorScheme.onSecondary),
                                          Text(' เข้าใช้งาน', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSecondary),),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        context.go('/signup');
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                                        child: Row(
                                          children: [
                                            Icon(Icons.person_add, size: 18, color: colorScheme.onPrimaryContainer),
                                            Text(' ลงทะเบียนสำหรับผู้ใช้ใหม่', style: TextStyle(color: colorScheme.onPrimaryContainer, fontSize: 16,)),
                                          ],
                                        ),
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

  Future<void> loginSubmit() async {
    if(isFormValid) {
      LoadingDialogService loading = LoadingDialogService();
      loading.presentLoading(context);

      var res = await authenAPI.localLogin(usernameController.text, passwordController.text);

      if(res.status == 1) {
        // ignore: use_build_context_synchronously
        LoginSessionModel session = Provider.of<LoginSessionModel>(context, listen: false);

        session.token = res.result[0].token;

        // ignore: use_build_context_synchronously
        context.pop();

        // ignore: use_build_context_synchronously
        context.go('/dashboard');
      } else {
        // ignore: use_build_context_synchronously
        context.pop();

        final FailureDialog failureDialog = FailureDialog();

        // ignore: use_build_context_synchronously
        failureDialog.showFailure(context, colorScheme, res.message);
      }
    }
  }
}