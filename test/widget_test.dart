import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/app.dart';

void main() {
  testWidgets('FitOn splash screen initial render test', (WidgetTester tester) async {
    await tester.pumpWidget(const FitOnApp());
    expect(find.text('FitOn'), findsOneWidget);
    expect(find.text('Your fitness journey starts here.'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });
}
