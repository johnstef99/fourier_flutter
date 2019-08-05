import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  AnimationController controller;
  String buttonString = 'Start';
  int slidern = 1;
  bool clean = false;
  MyPainter myPainter;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
      value: 0,
      upperBound: 1,
      animationBehavior: AnimationBehavior.preserve,
    );
    myPainter = MyPainter(
      animation: controller,
      n: slidern,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              child: AnimatedBuilder(
                animation: controller,
                builder: (BuildContext context, Widget child) {
                  return CustomPaint(
                    painter: myPainter,
                  );
                },
              ),
            ),
            Column(
              children: <Widget>[
                Slider.adaptive(
                  min: 1,
                  max: 50,
                  divisions: 50,
                  onChanged: (double value) {
                    setState(() {
                      slidern = value.round();
                      myPainter = MyPainter(
                        animation: controller,
                        n: slidern,
                      );
                    });
                  },
                  value: slidern.toDouble(),
                  label: slidern.toString(),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                      child: Text('Reset'),
                      onPressed: () {
                        setState(() {
                          buttonString = 'Start';
                          controller.stop();
                          controller.value = 0;
                          myPainter = MyPainter(
                            animation: controller,
                            n: slidern,
                          );
                        });
                      },
                    ),
                    RaisedButton(
                      child: Text(buttonString),
                      onPressed: () {
                        if (controller.isAnimating) {
                          setState(() {
                            buttonString = 'Start';
                          });
                          controller.stop();
                        } else {
                          setState(() {
                            buttonString = 'Stop';
                          });
                          controller.repeat().orCancel;
                        }
                      },
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final Animation<double> animation;
  final int n;
  List<Offset> wave;

  MyPainter({this.animation, this.n: 1}) : super(repaint: animation) {
    wave = [];
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint myPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;
    double offx = 100;
    double x = 0;
    double y = 0;
    for (int i = 0; i != this.n; i++) {
      double prevx = x;
      double prevy = y;
      int n = i * 2 + 1;
      double r = (60) * (4 / (n * pi));
      double time = (1.0 - animation.value) * 2 * pi;
      x += (r * cos(n * time));
      y += (r * sin(n * time));
      myPaint.color = Colors.white.withOpacity(0.2);
      canvas.drawCircle(size.center(Offset(prevx - offx, prevy)), r, myPaint);
      myPaint.color = Colors.white.withOpacity(1);

      canvas.drawLine(size.center(Offset(prevx - offx, prevy)),
          size.center(Offset(x - offx, y)), myPaint);

      //myPaint.style = PaintingStyle.fill;
      //canvas.drawCircle(size.center(Offset(x - 0, y)), 3, myPaint);
      //myPaint.style = PaintingStyle.stroke;
    }
    wave.insert(0, size.center(Offset(0, y)));

    // Path path = Path();
    // path.moveTo(
    //   size.center(Offset(x - offx, y)).dx,
    //   size.center(Offset(x - offx, y)).dy,
    // );
    myPaint.style = PaintingStyle.stroke;
    double multi = 0.35;
    for (int i = 1; i != wave.length; i++) {
      //path.lineTo(20 + i / 2, wave[i].dy);
      if (!(wave[i - 1].dy == size.center(Offset.zero).dy &&
          wave[i].dy == size.center(Offset.zero).dy))
        canvas.drawLine(wave[i - 1].translate((i * multi - 1).toDouble(), 0),
            wave[i].translate(i * multi, 0), myPaint);
    }
    myPaint.color = Colors.white.withOpacity(0.2);

    canvas.drawLine(size.center(Offset(x - offx, y)), wave[0], myPaint);
    //canvas.drawPath(path, myPaint);
    if (wave.length > 600) wave.removeLast();
  }

  @override
  bool shouldRepaint(MyPainter old) {
    return animation.value != old.animation.value;
  }
}
