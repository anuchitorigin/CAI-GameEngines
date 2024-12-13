import 'package:cai_gameengine/home.page.dart';
import 'package:cai_gameengine/profile.page.dart';
import 'package:cai_gameengine/about.page.dart';
import 'package:cai_gameengine/lesson.page.dart';
import 'package:cai_gameengine/exam.page.dart';
import 'package:cai_gameengine/score.page.dart';

import 'package:cai_gameengine/data/module/data_module.page.dart';
import 'package:cai_gameengine/data/exam/data_exam.page.dart';

final navigationList = [
  ( path: '/', widget: const HomePage() ),

  ( path: '/profile', widget: const ProfilePage() ),

  ( path: '/about', widget: const AboutPage() ),

  ( path: '/lesson', widget: const LessonPage() ),
  ( path: '/exam', widget: const ExamPage() ),
  ( path: '/score', widget: const ScorePage() ),

  //Data
  ( path: '/dat-module', widget: const DataModulePage() ),
  ( path: '/dat-exam', widget: const DataExamPage() ),

  //Production
  // ( path: '/prd-search', widget: const ProductionSearchPage() ),
  // ( path: '/prd-order', widget: const ProductionOrderPage() ),
  // ( path: '/prd-job', widget: const ProductionJobPage() ),
  // ( path: '/prd-delivery', widget: const ProductionDeliveryPage() ),
];