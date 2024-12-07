import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  late ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    setState(() {
      colorScheme = Theme.of(context).colorScheme;
    });

    return SingleChildScrollView(
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final isMoreThanSM = constraints.maxWidth > 576;

            final double h1Size = isMoreThanSM ? 36 : 24;
            final double h2Size = isMoreThanSM ? 30 : 22;
            final double h2SubSize = isMoreThanSM ? 26 : 18;
            final double contentSize = isMoreThanSM ? 20 : 14;

            final double padding = isMoreThanSM ? 120 : 10;

            return Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: padding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ยินดีต้อนรับสู่วิชา เกมคอมพิวเตอร์\nหน่วยการเรียนรู้เสริม: ความรู้ทั่วไปเกี่ยวกับ Game Engines', textAlign: TextAlign.start, style: TextStyle(fontSize: h1Size, fontWeight: FontWeight.bold,),),
                  const SizedBox(
                    height: 30,
                  ),
                  Text('บทนำ', textAlign: TextAlign.start, style: TextStyle(fontSize: h2Size, fontWeight: FontWeight.bold,),),
                  Text('Introduction', textAlign: TextAlign.start, style: TextStyle(fontSize: h2SubSize, color: Colors.grey,),),
                  const SizedBox(
                    height: 15,
                  ),
                  Text('บทเรียนคอมพิวเตอร์ช่วยสอน (Computer Assisted Instruction - CAI) นี้จัดทำขึ้นเพื่อใช้เป็นสื่อประกอบการสอนรายวิชา เกมคอมพิวเตอร์ สำหรับนักศึกษาปริญญาบัณฑิต คณะครุศาสตร์ จุฬาลงกรณ์มหาวิทยาลัย โดยมีสาระเนื้อหาดังนี้', textAlign: TextAlign.start, style: TextStyle(fontSize: contentSize,),),
                  const SizedBox(
                    height: 15,
                  ),
                  Text('1. ความหมายและความสำคัญของเกมเอนจิน (Game Engines)', textAlign: TextAlign.start, style: TextStyle(fontSize: contentSize,),),
                  Text('2. เกมเอนจิน (Game Engines) ที่นิยมในปัจจุบันและลักษณะเฉพาะ', textAlign: TextAlign.start, style: TextStyle(fontSize: contentSize,),),
                  const SizedBox(
                    height: 30,
                  ),
                  Text('วัตถุประสงค์การเรียนรู้', textAlign: TextAlign.start, style: TextStyle(fontSize: h2Size, fontWeight: FontWeight.bold,),),
                  Text('Learning Objectives', textAlign: TextAlign.start, style: TextStyle(fontSize: h2SubSize, color: Colors.grey,),),
                  const SizedBox(
                    height: 15,
                  ),
                  Text('เพื่อให้ผลลัพธ์การเรียนรู้ผ่านบทเรียนคอมพิวเตอร์ช่วยสอน (CAI) ตรงตามวัตถุประสงค์ ดังนั้นขอให้ผู้เรียนทำความเข้าใจในวัตถุประสงค์แต่ละข้อดังนี้', textAlign: TextAlign.start, style: TextStyle(fontSize: contentSize,),),
                  const SizedBox(
                    height: 15,
                  ),
                  Text('1. ผู้เรียนสามารถบรรยายความรู้ทั่วไปที่เกี่ยวกับเกมเอนจินได้', textAlign: TextAlign.start, style: TextStyle(fontSize: contentSize,),),
                  Text('2. ผู้เรียนสามารถระบุเกมเอนจินในธุรกิจเกมได้', textAlign: TextAlign.start, style: TextStyle(fontSize: contentSize,),),
                  Text('3. ผู้เรียนสามารถระบุคุณลักษณะเฉพาะของเกมเอนจินได้', textAlign: TextAlign.start, style: TextStyle(fontSize: contentSize,),),
                  Text('4. ผู้เรียนสามารถเปรียบเทียบเกมเอนจินได้', textAlign: TextAlign.start, style: TextStyle(fontSize: contentSize,),),
                ]
              ),
            );
          }
      ),
    );
  }
}