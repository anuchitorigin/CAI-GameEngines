import 'package:flutter/material.dart';

class MenuItem {
  bool? checkLock;
  String text;
  IconData icon;
  String? path;
  String permission;
  List<MenuItem>? submenu;

  MenuItem({
    this.checkLock,
    required this.text,
    required this.icon,
    this.path,
    required this.permission,
    this.submenu,
  });
}

final List<MenuItem> menuList = [
  MenuItem( text: 'แดชบอร์ด', icon: Icons.dashboard, path: '/dashboard', permission: 'dashboard',),
  MenuItem( checkLock: true, text: 'เกี่ยวกับ', icon: Icons.contact_support_rounded, path: '/about', permission: 'about',),
  MenuItem( checkLock: true, text: 'เนื้อหา', icon: Icons.menu_book, path: '/lesson', permission: 'lesson',),
  MenuItem( text: 'แบบทดสอบ', icon: Icons.question_answer_outlined, path: '/exam', permission: 'exam',),
  MenuItem( checkLock: true, text: 'คะแนน', icon: Icons.school_rounded, path: '/score', permission: 'score',),
  MenuItem( text: 'ฐานข้อมูล', icon: Icons.schema_outlined, permission: 'data', submenu: [
    MenuItem( text: 'เนื้อหา', icon: Icons.view_module, path: '/dat-module', permission: 'dat-module', ),
    MenuItem( text: 'แบบทดสอบ', icon: Icons.quiz, path: '/dat-exam', permission: 'dat-exam', ),
  ] ),
  // MenuItem( text: 'ระบบ', icon: Icons.settings_applications, permission: 'system', submenu: [
  //   MenuItem( text: 'ตัวแปรระบบ', icon: Icons.miscellaneous_services, path: '/sys-var', permission: 'sys-var', ),
  //   MenuItem( text: 'บันทึกเหตุการณ์ระบบ', icon: Icons.sticky_note_2, path: '/log-sys', permission: 'log-sys', ),
  //   MenuItem( text: 'บันทึกเหตุการณ์ผู้ใช้', icon: Icons.co_present_outlined, path: '/log-user', permission: 'log-user', ),
  //   MenuItem( text: 'ผู้ใช้', icon: Icons.people, path: '/sys-user', permission: 'sys-user', ),
  // ] ),
];