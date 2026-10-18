import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_odontologia/app.dart';
import 'package:app_odontologia/features/appointments/data/appointments_repository.dart';
import 'package:app_odontologia/features/appointments/domain/models/appointment.dart';

void main() {
  testWidgets('Dashboard dynamically updates active patient when switched to inTreatment', (WidgetTester tester) async {
    final repo = AppointmentsRepository();

    // 1. Pump the app
    await tester.pumpWidget(const DentalCareApp());
    await tester.pumpAndSettle();

    // 2. Initial state: Camila Ramos Vega is active
    expect(find.text('Camila Ramos Vega'), findsOneWidget);
    expect(find.text('EN ATENCIÓN • SILLÓN 1'), findsOneWidget);
    expect(find.text('Abrir Odontograma de Camila'), findsOneWidget);

    // 3. Switch Lucía Benavides Rios (apt-5) to inTreatment
    repo.updateAppointmentStatus('apt-5', AppointmentStatus.inTreatment);
    await tester.pumpAndSettle();

    // 4. Verification: Lucía Benavides Rios is now active in Sillón 1
    expect(find.text('Lucía Benavides Rios'), findsOneWidget);
    expect(find.text('EN ATENCIÓN • SILLÓN 1'), findsOneWidget);
    expect(find.text('Abrir Odontograma de Lucía'), findsOneWidget);
    expect(find.text('Camila Ramos Vega'), findsNothing);

    // 5. Tap on "Abrir Odontograma de Lucía"
    await tester.tap(find.text('Abrir Odontograma de Lucía'));
    await tester.pumpAndSettle();

    // 6. Odontogram screen should display Lucía Benavides Rios in the header
    expect(find.text('Odontograma: Lucía Benavides Rios'), findsOneWidget);
  });
}
