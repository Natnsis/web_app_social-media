import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:faithconnect/core/utils/faith_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerIconGenerator {
  static const _tag = 'MarkerIconGenerator';

  static ui.Image? _assetIconImage;

  static Future<BitmapDescriptor> getChurchMarker(
    String name,
    String? url,
  ) async {
    // Load asset image once and cache it
    if (_assetIconImage == null) {
      try {
        final ByteData data = await rootBundle.load('assets/images/icon/icon.png');
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        final frameInfo = await codec.getNextFrame();
        _assetIconImage = frameInfo.image;
      } catch (e) {
        FaithLogger.w(_tag, 'Failed to load asset icon: $e');
      }
    }

    final scale = 3.0; // Scale up for crispness on high-DPR screens

    // Prepare text
    final textPainter = TextPainter(
      text: TextSpan(
        text: name,
        style: TextStyle(
          fontSize: 12 * scale,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    textPainter.layout();

    final textWidth = textPainter.width;
    final textHeight = textPainter.height;

    // Dimensions based on user snippet
    final paddingX = 8.0 * scale;
    final paddingY = 4.0 * scale;
    final gap = 4.0 * scale;
    final iconSize = 40.0 * scale;
    final radius = 20.0 * scale;
    
    final boxWidth = textWidth + paddingX * 2;
    final boxHeight = textHeight + paddingY * 2;

    final canvasWidth = math.max(boxWidth, iconSize) + 20 * scale; 
    final canvasHeight = 10 * scale + boxHeight + gap + iconSize; // Ends exactly at the bottom of the icon

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    final centerX = canvasWidth / 2;
    
    final boxRect = Rect.fromLTWH(
      centerX - boxWidth / 2,
      10 * scale, // top margin for shadow
      boxWidth,
      boxHeight,
    );

    // 1. Draw shadow for the box
    final boxPath = Path()
      ..addRRect(RRect.fromRectAndRadius(boxRect, Radius.circular(radius)));
      
    canvas.drawPath(
      boxPath,
      Paint()
        ..color = Colors.black26
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 * scale),
    );

    // 2. Draw the box background (White)
    canvas.drawPath(boxPath, Paint()..color = Colors.white);

    // 3. Draw text
    textPainter.paint(
      canvas,
      Offset(
        boxRect.left + paddingX,
        boxRect.top + paddingY,
      ),
    );

    // 4. Draw asset icon below the text box
    final iconRect = Rect.fromLTWH(
      centerX - iconSize / 2,
      boxRect.bottom + gap,
      iconSize,
      iconSize,
    );

    if (_assetIconImage != null) {
      paintImage(
        canvas: canvas,
        rect: iconRect,
        image: _assetIconImage!,
        fit: BoxFit.contain,
      );
    } else {
      // Fallback
      canvas.drawCircle(iconRect.center, iconSize / 2, Paint()..color = const Color(0xFF3366FF));
    }

    final img = await pictureRecorder.endRecording().toImage(canvasWidth.toInt(), canvasHeight.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  /// Downloads an image from [url] and converts it to a circular map marker.
  static Future<BitmapDescriptor> getMarkerFromUrl(
    String? url, {
    int size = 150,
  }) async {
    if (url == null || url.isEmpty) {
      return _createDefaultMarker(size);
    }

    try {
      final response = await Dio().get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      final bytes = Uint8List.fromList(response.data!);
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: size,
        targetHeight: size,
      );
      final frameInfo = await codec.getNextFrame();
      final image = frameInfo.image;

      return _createCircularMarkerFromImage(image, size);
    } catch (e) {
      FaithLogger.w(_tag, 'Failed to load marker from $url: $e');
      return _createDefaultMarker(size);
    }
  }

  static Future<BitmapDescriptor> _createCircularMarkerFromImage(
    ui.Image image,
    int size,
  ) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final width = size.toDouble();
    final height = size.toDouble();

    final center = Offset(width / 2, height / 2 - 15);
    final circleRadius = width / 2 - 15;
    final point = Offset(width / 2, height - 5);

    // Draw shadow under the pin
    final shadowPath = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(width / 2, height - 5),
        width: 50,
        height: 15,
      ));
    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Draw pin path (circle + triangle pointer)
    final pinPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: circleRadius))
      ..moveTo(center.dx - 22, center.dy + 20)
      ..lineTo(point.dx, point.dy)
      ..lineTo(center.dx + 22, center.dy + 20)
      ..close();

    // Draw white pin background
    canvas.drawPath(pinPath, Paint()..color = Colors.white);

    // Draw brand color border ring inside the white
    final ringPaint = Paint()
      ..color = const Color(0xFF3366FF).withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, circleRadius - 4, ringPaint);

    // Clip image to inner circle
    final innerCircleRadius = circleRadius - 8;
    final clipPath = Path()..addOval(Rect.fromCircle(center: center, radius: innerCircleRadius));
    canvas.save();
    canvas.clipPath(clipPath);

    paintImage(
      canvas: canvas,
      rect: Rect.fromCircle(center: center, radius: innerCircleRadius),
      image: image,
      fit: BoxFit.cover,
    );
    canvas.restore();

    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  static Future<BitmapDescriptor> _createDefaultMarker(int size) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final width = size.toDouble();
    final height = size.toDouble();

    final center = Offset(width / 2, height / 2 - 15);
    final circleRadius = width / 2 - 15;
    final point = Offset(width / 2, height - 5);

    // Draw shadow under the pin
    final shadowPath = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(width / 2, height - 5),
        width: 50,
        height: 15,
      ));
    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Draw pin path (circle + triangle pointer)
    final pinPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: circleRadius))
      ..moveTo(center.dx - 22, center.dy + 20)
      ..lineTo(point.dx, point.dy)
      ..lineTo(center.dx + 22, center.dy + 20)
      ..close();

    // Draw white pin background
    canvas.drawPath(pinPath, Paint()..color = Colors.white);

    // Draw inner blue circle
    final innerRadius = circleRadius - 6;
    final bgPaint = Paint()..color = const Color(0xFF3366FF); // Brand blue
    canvas.drawCircle(center, innerRadius, bgPaint);

    // Draw icon
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(Icons.church.codePoint),
      style: TextStyle(
        fontSize: innerRadius,
        fontFamily: Icons.church.fontFamily,
        color: Colors.white,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - (textPainter.width / 2),
        center.dy - (textPainter.height / 2),
      ),
    );

    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }
}
