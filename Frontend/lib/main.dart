import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:cai_gameengine/components/blank_layout.dart';
import 'package:cai_gameengine/components/main_layout.dart';

import 'package:cai_gameengine/models/login_session.model.dart';

import 'package:cai_gameengine/constansts/navigation.const.dart';

import 'package:cai_gameengine/services/theme_manager.service.dart';

import 'package:cai_gameengine/login.page.dart';
import 'package:cai_gameengine/signup.page.dart';
import 'package:cai_gameengine/lesson.page.dart';
import 'package:cai_gameengine/data/module/details/module_details.page.dart';
import 'package:cai_gameengine/data/exam/details/exam_details.page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final _route = GoRouter(
  initialLocation: '/',
  navigatorKey: _rootNavigatorKey,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      pageBuilder: (context, state, child) {
        return NoTransitionPage(
          child: BlankLayout(child: child),
        );
      },
      routes: [
        GoRoute(
          parentNavigatorKey: _shellNavigatorKey,
          path: '/login',
          pageBuilder: (context, state) {
            return const NoTransitionPage(
              child: LoginPage(),
            );
          },
        ),
        GoRoute(
          parentNavigatorKey: _shellNavigatorKey,
          path: '/signup',
          pageBuilder: (context, state) {
            return const NoTransitionPage(
              child: SignupPage(),
            );
          },
        ),
      ]
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      pageBuilder: (context, state, child) {
        return NoTransitionPage(
          child: MainLayout(child: child),
        );
      },
      routes: [
        GoRoute(
          parentNavigatorKey: _shellNavigatorKey,
          path: '/data/module/:id',
          pageBuilder: (context, state) {
            return NoTransitionPage(
              child: ModuleDetailsPage(
                moduleID: int.parse(state.pathParameters['id']!),
              ),
            );
          },
        ),
        GoRoute(
          parentNavigatorKey: _shellNavigatorKey,
          path: '/data/exam/:id',
          pageBuilder: (context, state) {
            return NoTransitionPage(
              child: ExamDetailsPage(
                examID: int.parse(state.pathParameters['id']!),
              ),
            );
          },
        ),
        for(final nav in navigationList)
          GoRoute(
            parentNavigatorKey: _shellNavigatorKey,
            path: nav.path,
            pageBuilder: (context, state) {
              return NoTransitionPage(
                child: nav.widget,
              );
            },
          ),
      ]
    ),
  ]
);

void main() {
  usePathUrlStrategy();

  return runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier(),),
        ChangeNotifierProvider(create: (_) => LoginSessionModel(),),
      ],
      child: const CAIGameEngineApp(),
    ),
  );
}

class CAIGameEngineApp extends StatelessWidget {
  const CAIGameEngineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, theme, _) {
        return MaterialApp.router(
          theme: theme.getTheme(),
          routerConfig: _route,
        );
      }
    );
  }
}