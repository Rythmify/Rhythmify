import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/player/presentation/widgets/waveform/waveform_painter.dart';

void main() {
  group('WaveformPainter', () {
    test('shouldRepaint returns true when properties change', () {
      final painter1 = WaveformPainter(
        amplitudes: [0.1, 0.5],
        duration: const Duration(seconds: 100),
        activePosition: const Duration(seconds: 10),
        actualPosition: const Duration(seconds: 10),
        heightMultiplier: 1.0,
      );

      final painter2 = WaveformPainter(
        amplitudes: [0.1, 0.5],
        duration: const Duration(seconds: 100),
        activePosition: const Duration(seconds: 20),
        actualPosition: const Duration(seconds: 10),
        heightMultiplier: 1.0,
      );

      expect(painter1.shouldRepaint(painter2), true);
    });

    test('shouldRepaint returns false when properties are same', () {
      final painter1 = WaveformPainter(
        amplitudes: [0.1, 0.5],
        duration: const Duration(seconds: 100),
        activePosition: const Duration(seconds: 10),
        actualPosition: const Duration(seconds: 10),
        heightMultiplier: 1.0,
      );

      final painter2 = WaveformPainter(
        amplitudes: [0.1, 0.5],
        duration: const Duration(seconds: 100),
        activePosition: const Duration(seconds: 10),
        actualPosition: const Duration(seconds: 10),
        heightMultiplier: 1.0,
      );

      expect(painter1.shouldRepaint(painter2), false);
    });

    testWidgets('paints correctly (sanity check)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(200, 100),
              painter: WaveformPainter(
                amplitudes: [0.1, 0.5, 0.2, 0.8],
                duration: const Duration(seconds: 100),
                activePosition: const Duration(seconds: 50),
                actualPosition: const Duration(seconds: 50),
                heightMultiplier: 1.0,
              ),
            ),
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint && widget.painter is WaveformPainter,
        ),
        findsOneWidget,
      );
    });
  });
}
