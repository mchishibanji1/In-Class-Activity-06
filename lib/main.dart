// In-Class Activity 06 — Drawing with Flutter
// Student: Marc Chishibanji
// Date: September 30, 2026

import 'package:flutter/material.dart';

import 'dart:math' show pi, Random;

void main() => runApp(const SmileyApp());

class SmileyApp extends StatelessWidget {
  const SmileyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smiley Painter Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const DrawingPlayground(),
    );
  }
}

enum FaceType { classic, sleepy, surprised }

class DrawingPlayground extends StatefulWidget {
  const DrawingPlayground({super.key});

  @override
  State<DrawingPlayground> createState() => _DrawingPlaygroundState();
}

class _DrawingPlaygroundState extends State<DrawingPlayground> {
  double mood = 0.8;
  FaceType faceType = FaceType.classic;
  final Random _random = Random();

  void _cycleFace() {
    final next = FaceType.values[(faceType.index + 1) % FaceType.values.length];
    setState(() => faceType = next);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('Switched to ${next.name.toUpperCase()}'),
          duration: const Duration(milliseconds: 800),
        ),
      );
  }

  void _randomizeMood() {
    final newMood = _random.nextDouble();
    setState(() => mood = newMood);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('Mood: ${newMood.toStringAsFixed(2)}'),
          duration: const Duration(milliseconds: 800),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CustomPainter Smiley Lab')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              // LEVEL 4: Gesture detection wraps the canvas
              child: GestureDetector(
                onTap: _cycleFace,
                onLongPress: _randomizeMood,
                child: CustomPaint(
                  size: const Size(300, 300),
                  painter: SmileyPainter(mood: mood, faceType: faceType),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Mood: ${mood.toStringAsFixed(2)}'),
                Slider(
                  value: mood,
                  onChanged: (double v) => setState(() => mood = v),
                ),
                const SizedBox(height: 8),
                DropdownButton<FaceType>(
                  value: faceType,
                  onChanged: (FaceType? v) {
                    if (v != null) setState(() => faceType = v);
                  },
                  items: FaceType.values.map((FaceType f) {
                    return DropdownMenuItem<FaceType>(
                      value: f,
                      child: Text(f.name.toUpperCase()),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap face to cycle · Long-press to randomize mood',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SmileyPainter extends CustomPainter {
  SmileyPainter({required this.mood, required this.faceType});
  final double mood;
  final FaceType faceType;

  Color get faceColor {
    if (mood < 0.35) return Colors.blue.shade200;
    if (mood <= 0.70) return Colors.yellow.shade600;
    return Colors.orange.shade400;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide * 0.40;

    // 1) Face fill
    canvas.drawCircle(c, r, Paint()..color = faceColor);

    // 2) Face border
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    final eyeY = c.dy - r * 0.18;
    final eyeDx = r * 0.35;
    final eyePaint = Paint()..color = Colors.black87;

    // 3) Eyes
    if (faceType == FaceType.sleepy) {
      final linePaint = Paint()
        ..color = Colors.black87
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(c.dx - eyeDx - 12, eyeY),
        Offset(c.dx - eyeDx + 12, eyeY),
        linePaint,
      );
      canvas.drawLine(
        Offset(c.dx + eyeDx - 12, eyeY),
        Offset(c.dx + eyeDx + 12, eyeY),
        linePaint,
      );
    } else if (faceType == FaceType.surprised) {
      canvas.drawCircle(Offset(c.dx - eyeDx, eyeY), 18, eyePaint);
      canvas.drawCircle(Offset(c.dx + eyeDx, eyeY), 18, eyePaint);
    } else {
      canvas.drawCircle(Offset(c.dx - eyeDx, eyeY), 14, eyePaint);
      canvas.drawCircle(Offset(c.dx + eyeDx, eyeY), 14, eyePaint);
    }

    // 4) Mouth
    if (faceType == FaceType.surprised) {
      final openMouth = Rect.fromCenter(
        center: Offset(c.dx, c.dy + r * 0.35),
        width: r * 0.45,
        height: r * 0.55,
      );
      canvas.drawOval(openMouth, Paint()..color = Colors.black87);
    } else {
      final mouthPaint = Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round;

      final mouthRect = Rect.fromCenter(
        center: Offset(c.dx, c.dy + r * 0.15),
        width: r * 1.0,
        height: r * (0.4 + mood * 0.5),
      );

      if (mood >= 0.5) {
        canvas.drawArc(mouthRect, 0.15 * pi, 0.70 * pi, false, mouthPaint);
      } else {
        final frownRect = mouthRect.translate(0, r * 0.25);
        canvas.drawArc(frownRect, 1.15 * pi, 0.70 * pi, false, mouthPaint);
      }
    }

    // 5) Hat
    canvas.drawRect(
      Rect.fromLTWH(c.dx - r * 0.5, c.dy - r * 1.1, r * 1.0, r * 0.3),
      Paint()..color = Colors.red,
    );
  }

  @override
  bool shouldRepaint(covariant SmileyPainter oldDelegate) {
    return oldDelegate.mood != mood || oldDelegate.faceType != faceType;
  }
}
