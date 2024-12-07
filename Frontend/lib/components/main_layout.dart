import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:cai_gameengine/components/topbar.dart';
import 'package:cai_gameengine/components/side_menu.dart';

import 'package:cai_gameengine/api/user.api.dart';

import 'package:cai_gameengine/models/login_session.model.dart';


class MainLayout extends StatefulWidget {
  const MainLayout({super.key, required this.child});

  final Widget child;

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginSessionModel>(
      builder: (context, loginSession, child) {
        if(!loginSession.sessionActive) {
          context.go('/login');
        } else {
          if(loginSession.sessionActive && !loginSession.complete) {
            UserAPI userAPI = UserAPI();

            userAPI.readProfile(loginSession.token).then((getProfile) {
              if(getProfile.status == 0) {
                if(getProfile.message == 'Unauthorized') {
                  loginSession.clearSession();
                }
              } else {
                loginSession.user = getProfile.result[0];
              }
            });
          }
        }

        return SelectionArea(
          child: LayoutBuilder(
            builder: (context, BoxConstraints constraints) {
              bool isMd = constraints.maxWidth > 768;

              if(isMd) {
                try {
                  _scaffoldKey.currentState!.closeDrawer();
                // ignore: empty_catches
                } catch(err) {
                  
                }
              }

              return Scaffold(
                key: _scaffoldKey,
                appBar: PreferredSize(
                  preferredSize: const Size(double.infinity, 60),
                  child: TopBar(title: 'บทเรียนคอมพิวเตอร์ช่วยสอน (CAI)', constraints: constraints, loginSession: loginSession, scaffoldKey: _scaffoldKey),
                ),
                drawer: isMd ? null : SideMenu(constraints: constraints, scaffoldKey: _scaffoldKey),
                body: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Visibility(
                      visible: isMd,
                      child: SizedBox(
                        width: 280,
                        height: double.infinity,
                        child: SideMenu(constraints: constraints, scaffoldKey: _scaffoldKey),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: widget.child,
                    ),
                  ]
                ),
              );
            }
          )
        );
      }
    );
  }
}