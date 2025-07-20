import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:maxspeak/main.dart' as app;
import 'package:maxspeak/features/library/presentation/widgets/add_document_fab.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Complete PDF to TTS Workflow', () {
    testWidgets('App launches and shows library', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.text('Your Library'), findsOneWidget);
      expect(find.text('Your Library is Empty'), findsOneWidget);
      expect(find.byType(AddDocumentFab), findsOneWidget);
    });

    testWidgets('Add Document modal opens', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byType(AddDocumentFab));
      await tester.pumpAndSettle();

      expect(find.text('Add Document'), findsOneWidget);
      expect(find.text('Upload from Device'), findsOneWidget);
      expect(find.text('Import from Cloud'), findsOneWidget);
      expect(find.text('Scan Document'), findsOneWidget);
    });

    testWidgets('Navigation to settings works', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
    });
  });
}
