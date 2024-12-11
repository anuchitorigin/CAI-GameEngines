import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_content_placeholder/flutter_content_placeholder.dart';

import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

import 'package:cai_gameengine/services/domain.service.dart';

import 'package:cai_gameengine/api/module.api.dart';
import 'package:cai_gameengine/api/assessment.api.dart';

import 'package:cai_gameengine/constansts/menu.const.dart';
import 'package:cai_gameengine/constansts/system.const.dart';

import 'package:cai_gameengine/models/login_session.model.dart';
import 'package:cai_gameengine/models/api_result.model.dart';
import 'package:cai_gameengine/models/recordcount.model.dart';
import 'package:cai_gameengine/models/module.model.dart';
import 'package:cai_gameengine/models/assessment.model.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key, required this.constraints, required this.scaffoldKey});

  final BoxConstraints constraints;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  List<({Key key, ExpansionTileController controller})> keyControllerList = [];

  static final apiEndpoint = DomainService.authEndpoint;

  String? backendVersion;

  late LoginSessionModel loginSession;
  late BoxConstraints globalConstraints;
  late ColorScheme colorScheme;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      loginSession = context.read<LoginSessionModel>();

      await getPretestInfo();

      await getBackendVersion();
    });
  }

  getPretestInfo() async {
    if(loginSession.token.isNotEmpty) {
      final ModuleAPI moduleAPI = ModuleAPI();

      APIResult resModuleCount = await moduleAPI.readCount(loginSession.token, null, null, null, null, null, null, null, null, []);
      if(resModuleCount.status == 1) {
        if((resModuleCount.result[0] as RecordCountModel).RecordCount > 0) {
          ModuleModel? module;

          int i = 0;
          do {
            i++;

            APIResult resModule = await moduleAPI.readOne(loginSession.token, i);
            if(resModule.status == 1) {
              module = resModule.result[0] as ModuleModel;
            }
          } while(module == null);

          final AssessmentAPI assessmentAPI = AssessmentAPI();
          APIResult resAssessmentCount = await assessmentAPI.readCount(loginSession.token, null, null, null, null, loginSession.user!.userid, null, module.id, 0);
          if(resAssessmentCount.status == 1) {
            APIResult resAssessment = await assessmentAPI.readFilter(loginSession.token, (resAssessmentCount.result[0] as RecordCountModel).RecordCount, 1, "", null, null, null, null, loginSession.user!.userid, null, module.id, 0);
            if(resAssessment.status == 1) {
              final List<AssessmentModel> assessments = resAssessment.result as List<AssessmentModel>;

              if(assessments.any((e) => e.finishminute > 0)) {
                setState(() {
                  loginSession.pretestDone = true;
                });
              }
            }
          }
        }
      }
    }
  }

  getBackendVersion() async {
    if(loginSession.token.isNotEmpty) {
      try {
        http.Response res = await http.get(Uri.parse('$apiEndpoint/ping'), headers: { 'Authorization': 'Bearer ${loginSession.token}', 'responseType': 'text' });
      
        setState(() {
          backendVersion = res.body.substring(res.body.indexOf('v'), res.body.indexOf(')'));
        });
      } catch(err) {
        // Error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    colorScheme = Theme.of(context).colorScheme;

    bool isMd = widget.constraints.maxWidth > 768;

    for(final menuItem in menuList) {
      if(menuItem.submenu != null) {
        keyControllerList.add((key: Key(menuItem.text), controller: ExpansionTileController()));
      }
    }

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(0)),
      ),
      backgroundColor: colorScheme.surface,
      child: Consumer<LoginSessionModel>(
        builder: (context, loginSession, child) {
          return Column(
            children: [
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Column(
                    children: buildMenu(context, isMd, colorScheme, loginSession),
                  ),
                ),
              ),
              SizedBox(
                width: double.maxFinite,
                height: 30,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: InkWell(
                    onTap: () {
                      itemAppInfoDialog();
                    },
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: colorScheme.secondary,),
                        Text(' เกี่ยวกับ CAI', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.secondary))
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  List<Widget> buildMenu(BuildContext context, bool isMd, ColorScheme colorScheme, LoginSessionModel loginSession) {
    List<Widget> menu = [];

    if(loginSession.user != null) {
      for(final menuItem in menuList) {
        if((menuItem.permission.isEmpty || loginSession.user!.roleparam[menuItem.permission] > 0)) {
          if(menuItem.submenu != null) {
            final keyController = keyControllerList.firstWhere((element) => element.key == Key(menuItem.text));

            menu.add(
              Material(
                color: colorScheme.primaryContainer,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color( 0xFF000000 ),),),
                  ),
                  child: ExpansionTile(
                    key: keyController.key,
                    controller: keyController.controller,
                    onExpansionChanged: (state) {
                      if(state) {
                        for(final element in keyControllerList) {
                          try {
                            if(element.key != keyController.key && element.controller.isExpanded) {
                              element.controller.collapse();
                            }
                          } catch(err) {
                            // Error
                          }
                        }
                      }
                    },
                    childrenPadding: const EdgeInsets.all(0),
                    title: Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 5,),
                      child: Row(
                        children: [
                          Icon(menuItem.icon, size: 22, color: colorScheme.onPrimaryContainer,),
                          Text(' ${menuItem.text}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onPrimaryContainer)),
                        ],
                      ),
                    ),
                    children: buildSubMenu(context, isMd, colorScheme, loginSession, menuItem.submenu!),
                  ),
                ),
              )
            );
          } else {
            menu.add(
              Material(
                color: (menuItem.checkLock != null && menuItem.checkLock!) && !loginSession.pretestDone ? Colors.grey : colorScheme.primaryContainer,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color( 0xFF000000 ),),),
                  ),
                  child: InkWell(
                    onTap: (menuItem.checkLock != null && menuItem.checkLock!) && !loginSession.pretestDone ? null : () {
                      if(!isMd) {
                        widget.scaffoldKey.currentState?.closeDrawer();
                      }

                      context.go(menuItem.path!);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15, right: 10, bottom: 15, left: 10),
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Icon(menuItem.icon, size: 22, color: colorScheme.onPrimaryContainer,),
                          ),
                          Text(' ${menuItem.text}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onPrimaryContainer)),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            );
          }
        }
      }
    }

    return menu;
  }

  List<Widget> buildSubMenu(BuildContext context, bool isMd, ColorScheme colorScheme, LoginSessionModel loginSession, List<MenuItem> submenuItem) {
    List<Widget> menu = [];

    for(final submenu in submenuItem) {
      if(submenu.permission.isEmpty || loginSession.user!.roleparam[submenu.permission] > 0) {
        menu.add(
          Material(
            color: colorScheme.tertiaryContainer,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color( 0xFF000000 ),),),
              ),
              child: InkWell(
                onTap: () {
                  if(!isMd) {
                    widget.scaffoldKey.currentState?.closeDrawer();
                  }

                  context.go(submenu.path!);
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 15, right: 10, bottom: 15, left: 10),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Icon(submenu.icon, size: 22, color: colorScheme.onTertiaryContainer,),
                      ),
                      Text(' ${submenu.text}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onTertiaryContainer)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return menu;
  }

  itemAppInfoDialog() {
    showDialog<void>(
      barrierDismissible: false,
      // ignore: use_build_context_synchronously
      context: context,
      builder: (BuildContext context) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: SizedBox(
                  width: 450,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.info_outline, size: 30, color: colorScheme.secondary,),
                              Text(' เกี่ยวกับ CAI', style: TextStyle(fontSize: 30, color: colorScheme.secondary,),),
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
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Expanded(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Text('ซอฟต์แวร์', style: TextStyle(fontSize: 18,), textAlign: TextAlign.right,),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Text('บทเรียนคอมพิวเตอร์ช่วยสอน (CAI)', style: TextStyle(fontSize: 18, color: colorScheme.primary),),
                            ),
                          ),
                        ],
                      ),
                      // Divider(
                      //   thickness: 0.5,
                      //   color: colorScheme.onSurface,
                      // ),
                      // Row(
                      //   children: [
                      //     const Expanded(
                      //       flex: 1,
                      //       child: Padding(
                      //         padding: EdgeInsets.all(5),
                      //         child: Text('สิทธิ์การใช้', style: TextStyle(fontSize: 18,), textAlign: TextAlign.right,),
                      //       ),
                      //     ),
                      //     Expanded(
                      //       flex: 3,
                      //       child: Padding(
                      //         padding: const EdgeInsets.all(5),
                      //         child: Text('บริษัท ศัลยเวทย์ จำกัด', style: TextStyle(fontSize: 18, color: colorScheme.primary),),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      Divider(
                        thickness: 0.5,
                        color: colorScheme.onSurface,
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Text('พัฒนาโดย', style: TextStyle(fontSize: 18,), textAlign: TextAlign.right,),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Text('บริษัท ออริจิน ซอฟท์แวร์ แอนด์ โซลูชั่น จำกัด', style: TextStyle(fontSize: 18, color: colorScheme.primary),),
                                ),
                              ),
                            ],
                          ),
                          Image.asset('assets/images/Line ORIGIN Logo.png', width: 200, height: 200,),
                          const SizedBox(
                            height: 5,
                          ),
                          Text('LINE Official QR Code', style: TextStyle(fontSize: 12, color: colorScheme.primary),),
                        ],
                      ),
                      Divider(
                        thickness: 0.5,
                        color: colorScheme.onSurface,
                      ),
                      const Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Text('Build Version', style: TextStyle(fontSize: 18,), textAlign: TextAlign.center,),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Expanded(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Text('Frontend', style: TextStyle(fontSize: 18,), textAlign: TextAlign.right,),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Text(version, style: TextStyle(fontSize: 18, color: colorScheme.primary),),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Expanded(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Text('Backend', style: TextStyle(fontSize: 18,), textAlign: TextAlign.right,),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Builder(
                                builder: (context) {
                                  if(backendVersion != null) {
                                    return Text(backendVersion!, style: TextStyle(fontSize: 18, color: colorScheme.primary),);
                                  } else {
                                    return Shimmer.fromColors(
                                      baseColor: colorScheme.brightness == Brightness.light ? Colors.grey.shade400 : Colors.grey.shade600,
                                      highlightColor: colorScheme.brightness == Brightness.light ? Colors.grey.shade200 : Colors.grey.shade800,
                                      child: ContentPlaceholder.block(
                                        context: context,
                                        width: 96,
                                        height: 18,
                                        bottomSpacing: 0,
                                        borderRadius: 0,
                                      ),
                                    );
                                  }
                                }
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        thickness: 0.5,
                        color: colorScheme.onSurface,
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
}