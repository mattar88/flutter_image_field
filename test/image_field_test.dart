import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_field/image_field.dart';

void main() {
  testWidgets('ImageField shows upload button when no image is selected', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ImageField(
            onSave: (imageAndCaptionList) {},
            thumbnailWidth: 100,
            thumbnailHeight: 100,
          ),
        ),
      ),
    );

    // Verify that upload button is shown
    expect(find.text('Upload'), findsOneWidget);
  });

  testWidgets('ImageField shows upload icon', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ImageField(
            onSave: (imageAndCaptionList) {},
            thumbnailWidth: 100,
            thumbnailHeight: 100,
          ),
        ),
      ),
    );

    // Verify that upload icon is present
    expect(find.byIcon(Icons.upload), findsOneWidget);
  });
}
