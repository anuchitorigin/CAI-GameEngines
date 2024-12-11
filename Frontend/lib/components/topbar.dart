import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'package:cai_gameengine/services/loading_dialog.service.dart';
import 'package:cai_gameengine/services/theme_manager.service.dart';

import 'package:cai_gameengine/models/profile.model.dart';
import 'package:cai_gameengine/models/login_session.model.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key, required this.title, required this.constraints, required this.scaffoldKey, required this.loginSession});

  final String title;
  final BoxConstraints constraints;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final LoginSessionModel loginSession;
  
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    bool isMd = constraints.maxWidth > 1280;

    return Container(
      height: 60,
      decoration: BoxDecoration(color: colorScheme.primary),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          Visibility(
            visible: !isMd,
            child: IconButton(
              onPressed: () {
                if(scaffoldKey.currentState!.isDrawerOpen){
                  scaffoldKey.currentState!.closeDrawer();
                }else{
                  scaffoldKey.currentState!.openDrawer();
                }
              },
              iconSize: 20.sp,
              icon: Icon(Icons.menu, color: colorScheme.onPrimary,),
            ),
          ),
          const SizedBox(
            width: 5,
            height: double.infinity,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
            child: Text(title, style: TextStyle(color: colorScheme.onPrimary, fontSize: 15.sp, fontWeight: FontWeight.bold)),
          ),
          // Material(
          //   color: colorScheme.primary,
          //   child: InkWell(
          //     onTap: () {
          //       context.go('/');
          //     },
          //     child: Padding(
          //       padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
          //       child: Text(title, style: TextStyle(color: colorScheme.onPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
          //     ),
          //   ),
          // ),
          const Spacer(),
          MenuAnchor(
            builder: (BuildContext context, MenuController controller, Widget? child) {
              if(isMd) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.inversePrimary,
                    padding: EdgeInsets.all(11.sp),
                  ),
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person, size: 15.sp, color: colorScheme.onPrimaryContainer,),
                      FutureBuilder<ProfileModel>(
                        future: Future.delayed(const Duration(milliseconds: 1), () => Future.value(loginSession.user)),
                        builder: (BuildContext context, AsyncSnapshot<ProfileModel> user) {
                          if(user.hasData && user.data != null) {
                            return Text(' ${user.data!.firstname} ${user.data!.lastname}', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: colorScheme.onPrimaryContainer),);
                          } else {
                            return SizedBox(
                              width: 100,
                              height: 20,
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(color: colorScheme.onPrimaryContainer),
                              ),
                            );
                          }
                        }
                      ),
                    ],
                  ),
                );
              } else {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: colorScheme.inversePrimary,
                    padding: EdgeInsets.all(11.sp),
                  ),
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  child: Icon(Icons.person, size: 15.sp, color: colorScheme.onPrimaryContainer,),
                );
              }
            },
            menuChildren: [
              MenuItemButton(
                onPressed: () {
                  context.go('/profile');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(8),
                  backgroundColor: colorScheme.secondary,
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, size: 24, color: colorScheme.onSecondary,),
                    Text(' ข้อมูลโปรไฟล์', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSecondary,),),
                  ],
                ),
              ),
              MenuItemButton(
                onPressed: () {
                  confirmLogoutDialog(context, loginSession);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(8),
                  backgroundColor: colorScheme.secondary,
                ),
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 24, color: colorScheme.onSecondary,),
                    Text(' ออกจากระบบ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSecondary,),),
                  ],
                ),
              )
            ],
          ),
          Consumer<ThemeNotifier>(
            builder: (context, theme, _) {
              return ElevatedButton(
                onPressed: () {
                  isDarkMode
                  ? theme.setLightMode()
                  : theme.setDarkMode();
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: EdgeInsets.all(11.sp),
                ),
                child: isDarkMode ? Icon(Icons.light_mode, size: 15.sp, color: const Color(0xFFFFFFFF),) : Icon(Icons.dark_mode, size: 15.sp, color: const Color(0xFF000000),),
              );
            }
          ),
        ],
      ),
    );
  }

  confirmLogoutDialog(BuildContext context, LoginSessionModel loginSessionNotifier) {
    // AppLocalizations translate = AppLocalizations.of(context);
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.logout, size: 30, color: colorScheme.error,),
            const Text(' ออกจากระบบ', style: TextStyle(fontSize: 30,),),
          ],
        ),
        content: const Text('ต้องการออกจากระบบหรือไม่', style: TextStyle(fontSize: 22,),),
        actions: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
            ),
            onPressed: () async {
              LoadingDialogService loading = LoadingDialogService();
              loading.presentLoading(context);
              
              await Future.delayed(const Duration(seconds: 1));
              loginSessionNotifier.clearSession();

              // ignore: use_build_context_synchronously
              context.pop();
              // ignore: use_build_context_synchronously
              context.pop();
              // ignore: use_build_context_synchronously
              context.go('/login');
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.logout, size: 22, color: colorScheme.onError,),
                Text(' ยืนยัน', style: TextStyle(fontSize: 20, color: colorScheme.onError,),),
              ],
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.secondary,
              padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
            ),
            onPressed: () => context.pop(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_circle_right_outlined, size: 22, color: colorScheme.onSecondary,),
                Text(' ถอยกลับ', style: TextStyle(fontSize: 20, color: colorScheme.onSecondary,),),
              ],
            ),
          ),
        ],
      ),
    );
  }
}