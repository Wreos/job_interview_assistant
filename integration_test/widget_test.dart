import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_interview_assistant/main.dart';

void main() {
  testWidgets('Interview List smoke test', (WidgetTester tester) async {
    // Create a FirebaseService instance
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    final firebaseService = FirebaseService();
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
        home: InterviewListWidget(firebaseService: firebaseService)
    ));

    // Verify that the 'Add Interview' button is present.
    expect(find.text('Add'), findsOneWidget);

    // Verify that the input fields are present.
    expect(find.byType(TextFormField), findsNWidgets(4));

    // Enter some text in the input fields
    await tester.enterText(find.byType(TextFormField).at(0), "John Doe");
    await tester.enterText(find.byType(TextFormField).at(1), "01/01/2022");
    await tester.enterText(find.byType(TextFormField).at(2), "New York");
    await tester.enterText(find.byType(TextFormField).at(3), "Completed");

    // Tap the 'Add Interview' button and trigger a frame.
    await tester.tap(find.text("Add"));
    await tester.pump();

    // Verify that the interview has been added to the list
    expect(find.byType(ListTile), findsOneWidget);
    expect(find.text("John Doe"), findsOneWidget);
    expect(find.text("01/01/2022"), findsOneWidget);
    expect(find.text("New York"), findsOneWidget);
    expect(find.text("Completed"), findsOneWidget);
  });
}