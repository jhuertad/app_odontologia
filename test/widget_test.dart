import 'package:flutter_test/flutter_test.dart';
import 'package:app_odontologia/app.dart';

void main() {
  testWidgets('DentalCare smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DentalCareApp());
    expect(find.textContaining('DentalCare'), findsWidgets);
  });
}
