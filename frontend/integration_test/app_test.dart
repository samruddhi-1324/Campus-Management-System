import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:campus_care/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('End-to-End Screen Sequence Test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Loop through the 14 screens.
    for (int step = 1; step < 14; step++) {
      print('Currently on Step $step...');
      
      // Look for the "Next" button which has the Icons.arrow_forward
      final Finder nextButton = find.byIcon(Icons.arrow_forward);
      
      expect(nextButton, findsOneWidget, reason: 'Next button missing on Step $step');
      
      // Tap it
      await tester.tap(nextButton);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
    }
    
    print('Reached Step 14 successfully!');
    
    // On step 14, look for the "Prev" button just to ensure we arrived
    final Finder prevButton = find.byIcon(Icons.arrow_back);
    expect(prevButton, findsOneWidget, reason: 'Prev button missing on Step 14');
    
    print('Test completely successful. All screens integrated and navigable!');
  });
}
