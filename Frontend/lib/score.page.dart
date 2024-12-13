import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:sizer/sizer.dart';

import 'package:cai_gameengine/api/assessment.api.dart';
import 'package:cai_gameengine/api/module.api.dart';

import 'package:cai_gameengine/services/loading_dialog.service.dart';

import 'package:cai_gameengine/models/api_result.model.dart';
import 'package:cai_gameengine/models/recordcount.model.dart';
import 'package:cai_gameengine/models/login_session.model.dart';
import 'package:cai_gameengine/models/assessment.model.dart';
import 'package:cai_gameengine/models/module.model.dart';

class ScorePage extends StatefulWidget {
  const ScorePage({super.key});

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  List<AssessmentModel> assessments = [];

  ModuleModel? module;

  bool isLoading = false;

  int currentPage = 0;
  int totalAssessments = 0;

  final formatter = NumberFormat("#,##0.00", "en_US");

  late double cardWidth;

  LoginSessionModel? loginSession;
  late BoxConstraints globalConstraints;
  late ColorScheme colorScheme;

  @override
  void initState() {
    super.initState();

    final LoadingDialogService loading = LoadingDialogService();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      loading.presentLoading(context);

      loginSession = context.read<LoginSessionModel>();

      await loadModule();

      await getTotalAssessmentCount();
      await loadAssessments();

      // ignore: use_build_context_synchronously
      context.pop();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  loadModule() async {
    if(loginSession != null && loginSession!.token.isNotEmpty) {
      final ModuleAPI moduleAPI = ModuleAPI();

      APIResult resModuleCount = await moduleAPI.readCount(loginSession!.token, null, null, null, null, null, null, null, null, []);
      if(resModuleCount.status == 1 && (resModuleCount.result[0] as RecordCountModel).RecordCount > 0) {
        int i = 0;
        do {
          i++;

          APIResult resModule = await moduleAPI.readOne(loginSession!.token, i);
          if(resModule.status == 1) {
            module = resModule.result[0] as ModuleModel;
          }
        } while(module == null);
      }
    }
  }

  getTotalAssessmentCount() async {
    if(loginSession != null && loginSession!.token.isNotEmpty && module != null) {
      final AssessmentAPI assessmentAPI = AssessmentAPI();

      APIResult resCount = await assessmentAPI.readCount(loginSession!.token, null, null, null, null, loginSession!.user!.userid, null, module!.id, 0);
      if(resCount.status == 1 && resCount.result[0].RecordCount > 0) {
        totalAssessments = resCount.result[0].RecordCount;
      } else {
        if(mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  loadAssessments() async {
    if(loginSession != null && loginSession!.token.isNotEmpty && totalAssessments > 0) {
      final AssessmentAPI assessmentAPI = AssessmentAPI();

      currentPage++;
      APIResult resFilter = await assessmentAPI.readFilter(loginSession!.token, 10, currentPage, "", null, null, null, null, loginSession!.user!.userid, null, module!.id, 0);
      if(resFilter.status == 1) {
        assessments.addAll(resFilter.result as List<AssessmentModel>);

        if(assessments.every((e) => e.finishminute == 0)) {
          loadAssessments();
        }
      }

      if(mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } else if(mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    setState(() {
      colorScheme = Theme.of(context).colorScheme;
    });

    return SingleChildScrollView(
      child: LayoutBuilder(
        builder: (context, BoxConstraints constraints) {
          globalConstraints = constraints;

          final isLg = globalConstraints.maxWidth > 992;
          final isMd = globalConstraints.maxWidth > 768;
          final isSm = globalConstraints.maxWidth > 576;

          final cardWidth = isLg ? globalConstraints.maxWidth * 0.5 : (isMd ? globalConstraints.maxWidth * 0.7 : (isSm ? globalConstraints.maxWidth * 0.8 : globalConstraints.maxWidth * 0.9));

          if(loginSession != null) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20.0,
                ),
                Text('${loginSession!.user!.firstname} ${loginSession!.user!.lastname}', style: TextStyle(fontSize: 20.sp),),
                const SizedBox(
                  height: 5.0,
                ),
                Text(loginSession!.user!.loginid, style: TextStyle(fontSize: 16.sp, color: Colors.grey,),),
                const SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Builder(
                        builder: (BuildContext context) {
                          if(assessments.isNotEmpty) {
                            return Flex(
                              direction: Axis.vertical,
                              children: buildAssessmentList(assessments, cardWidth),
                            );
                          } else if(!isLoading) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: cardWidth,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: colorScheme.secondaryContainer,
                                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('ไม่พบผลการทำแบบทดสอบ', style: TextStyle(color: colorScheme.onSecondaryContainer, fontSize: 15.sp))
                                    ],
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                      Visibility(
                        visible: isLoading,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                          ],
                        ),
                      ),
                      Builder(
                        builder: (BuildContext context) {
                          if(totalAssessments > 0 && assessments.length < totalAssessments) {
                            return VisibilityDetector(
                              key: const Key('AssessmentInfiniteScroll'),
                              onVisibilityChanged: (visibilityInfo) {
                                var visiblePercentage = visibilityInfo.visibleFraction * 100;

                                if(visiblePercentage > 50) {
                                  setState(() {
                                    isLoading = true;
                                  });

                                  loadAssessments();
                                }
                              },
                              child: const SizedBox(width: 100, height: 50,),
                            );
                          } else {
                            return Container();
                          }
                        }
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20.0,
                ),
                Container(
                  width: cardWidth,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                    ],
                  ),
                ),
              ],
            );
          }
        }
      ),
    );
  }

  List<Widget> buildAssessmentList(List<AssessmentModel> assessmentList, double cardWidth) {
    List<Widget> assessmentWidgetList = [];

    final showList = assessmentList.where((e) => e.finishminute > 0).toList();

    final int length = showList.length;
    for(int i = 0; i < length; i++) {
      assessmentWidgetList.addAll([
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 10, bottom: 0, right: 10),
          child: SizedBox(
            width: cardWidth,
            child: ExpansionTile(
              maintainState: true,
              backgroundColor: colorScheme.primaryContainer,
              collapsedBackgroundColor: colorScheme.surfaceContainer,
              onExpansionChanged: (newState) {},
              childrenPadding: const EdgeInsets.all(0),
              title: Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 5,),
                child: Row(
                  children: [
                    Text(i > 0 ? 'ผลการทดสอบ "หลัง" เรียน ครั้งที่ $i' : 'ผลการทดสอบ "ก่อน" เรียน', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: colorScheme.onPrimaryContainer)),
                  ],
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('คะแนน: ${showList[i].finishscore.toString()}/${showList[i].maxscore.toString()}', style: TextStyle(fontSize: 14.sp, color: colorScheme.onPrimaryContainer)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('เวลา: ${showList[i].finishminute.toString()}.00 นาที', style: TextStyle(fontSize: 14.sp, color: colorScheme.onPrimaryContainer)),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
      ]);
    }

    return assessmentWidgetList;
  }

}