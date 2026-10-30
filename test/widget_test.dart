import 'package:flutter_test/flutter_test.dart';
import 'package:medicare_app/main.dart';

void main() {
  testWidgets('MediCare app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const MediCareApp());

    expect(find.text('MediCare'), findsWidgets);
  });
}
