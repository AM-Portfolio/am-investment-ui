import 'package:flutter/material.dart';

/// A custom painter that creates a modern gradient background with abstract shapes
/// for the login screen.
class LoginBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Create gradient background
    final Rect rect = Offset.zero & size;
    final Paint paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF1A237E), // Deep indigo
          const Color(0xFF3949AB), // Indigo
          const Color(0xFF1E88E5), // Blue
        ],
      ).createShader(rect);

    canvas.drawRect(rect, paint);

    // Draw abstract shapes
    _drawAbstractShapes(canvas, size);
  }

  void _drawAbstractShapes(Canvas canvas, Size size) {
    // First blob - top right
    final Paint blobPaint1 = Paint()
      ..color = const Color(0x15FFFFFF)
      ..style = PaintingStyle.fill;
    
    final Path blob1 = Path()
      ..moveTo(size.width * 0.7, 0)
      ..quadraticBezierTo(
        size.width * 0.85, size.height * 0.15, 
        size.width, size.height * 0.1
      )
      ..lineTo(size.width, 0)
      ..close();
    
    canvas.drawPath(blob1, blobPaint1);

    // Second blob - middle right
    final Paint blobPaint2 = Paint()
      ..color = const Color(0x20FFFFFF)
      ..style = PaintingStyle.fill;
    
    final Path blob2 = Path()
      ..moveTo(size.width * 0.6, size.height * 0.35)
      ..quadraticBezierTo(
        size.width * 0.8, size.height * 0.3, 
        size.width, size.height * 0.5
      )
      ..quadraticBezierTo(
        size.width * 0.9, size.height * 0.6, 
        size.width * 0.7, size.height * 0.55
      )
      ..close();
    
    canvas.drawPath(blob2, blobPaint2);

    // Third blob - bottom left
    final Paint blobPaint3 = Paint()
      ..color = const Color(0x18FFFFFF)
      ..style = PaintingStyle.fill;
    
    final Path blob3 = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.2, size.height * 0.85, 
        size.width * 0.3, size.height
      )
      ..lineTo(0, size.height)
      ..close();
    
    canvas.drawPath(blob3, blobPaint3);

    // Small circles
    final Paint circlePaint = Paint()
      ..color = const Color(0x10FFFFFF)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.2), 
      size.width * 0.08, 
      circlePaint
    );
    
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.8), 
      size.width * 0.05, 
      circlePaint
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A widget that displays the login background with gradient and abstract shapes.
class LoginBackground extends StatelessWidget {
  final Widget child;

  const LoginBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background
        CustomPaint(
          painter: LoginBackgroundPainter(),
          size: Size.infinite,
          child: Container(),
        ),
        // Content
        child,
      ],
    );
  }
}
