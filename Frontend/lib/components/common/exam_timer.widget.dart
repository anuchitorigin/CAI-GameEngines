import 'package:flutter/material.dart';

import 'package:pausable_timer/pausable_timer.dart';

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
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          const Icon(Icons.access_time,),
          Text(examTimer != null ? '${(examTime / 60).floor().toString().padLeft(2, '0')}:${(examTime % 60).toString().padLeft(2, '0')}' : '--:--', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),),
          Text(examTimer != null ? 'เวลาคงเหลือ' : 'ไม่กำหนดเวลา', style: const TextStyle(fontSize: 12,),),
        ],
      ),
    );
  }
}