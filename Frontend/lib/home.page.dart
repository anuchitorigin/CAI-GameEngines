import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    setState(() {
      colorScheme = Theme.of(context).colorScheme;
    });

    return Scaffold(
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final isSm = constraints.maxWidth > 576;

            final double fontSzie = isSm ? 40 : 26;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('ยินดีต้อนรับเข้าสู่บทเรียนคอมพิวเตอร์ช่วยสอน (CAI)\nหน่วยการเรียนรู้\nIntroduction to Game Engines', textAlign: TextAlign.center, style: TextStyle(fontSize: fontSzie,),),
                  ],
                ),
              ]
            );
          }
      ),
    );
  }
}