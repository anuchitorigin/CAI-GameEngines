import 'package:flutter/material.dart';

import 'package:pausable_timer/pausable_timer.dart';
import 'package:sizer/sizer.dart';

class ExamTimerWidget extends StatefulWidget {
  const ExamTimerWidget({super.key, required this.isStop, required this.remainingSeconds, required this.onCount});

  final bool isStop;
  final int remainingSeconds;
  final Function(int) onCount;

  @override
  State<ExamTimerWidget> createState() => _ExamTimerWidgetState();
}

class _ExamTimerWidgetState extends State<ExamTimerWidget> {
  int examTime = 0;
  PausableTimer? examTimer;

  @override
  void initState() {
    super.initState();

    examTime = widget.remainingSeconds;

    if(!widget.isStop && examTime > 0) {
      examTimer = PausableTimer(const Duration(seconds: 1), timerCallback);
      examTimer?.start();
    } else {
      examTimer = null;
    }
  }

  @override
  void didUpdateWidget(ExamTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if(examTimer != null) {
      if(!widget.isStop && examTime > 0) {
        examTimer?.start();
      } else {
        examTimer?.pause();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();

    examTimer?.cancel();
  }

  void timerCallback() {
    setState(() {
      examTime--;

      if(examTime > 0) {
        examTimer?.reset();
        examTimer?.start();
      }
    });

    widget.onCount(examTime);

    if(examTime <= 0) {
      examTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.symmetric(vertical: 2.sp),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: Column(
        children: [
          Icon(Icons.access_time, size: 16.sp,),
          Text(examTimer != null ? '${(examTime / 60).floor().toString().padLeft(2, '0')}:${(examTime % 60).toString().padLeft(2, '0')}' : '--:--', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold,),),
          Text(examTimer != null ? 'เวลาคงเหลือ' : 'ไม่กำหนดเวลา', style: TextStyle(fontSize: 11.sp,),),
        ],
      ),
    );
  }
}