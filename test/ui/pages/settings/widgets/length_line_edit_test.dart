import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/ui/pages/settings/widgets/length_line_edit.dart';

void main() {
  testWidgets('reports only a complete positive length after debounce', (
    tester,
  ) async {
    final values = <double>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LengthLineEdit(
            lengthLabel: 'Split',
            length: 200,
            lengthUnit: 'm',
            onLengthChanged: values.add,
            onUnitChanged: (_) {},
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '0');
    await tester.pump(const Duration(milliseconds: 500));
    expect(values, isEmpty);

    await tester.enterText(find.byType(TextField), '250');
    await tester.pump(const Duration(milliseconds: 399));
    expect(values, isEmpty);
    await tester.pump(const Duration(milliseconds: 1));
    expect(values, [250]);
  });

  testWidgets('reports a selected common distance unit', (tester) async {
    String? selectedUnit;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LengthLineEdit(
            lengthLabel: 'Lap',
            length: 1000,
            lengthUnit: 'm',
            onLengthChanged: (_) {},
            onUnitChanged: (value) => selectedUnit = value,
          ),
        ),
      ),
    );

    final dropdown = tester.widget<DropdownButton<String>>(
      find.byType(DropdownButton<String>),
    );
    dropdown.onChanged!('yd');

    expect(selectedUnit, 'yd');
  });
}
