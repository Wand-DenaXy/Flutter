// =============================================================================
// widget_test.dart — Teste mínimo (smoke test) da aplicação
// =============================================================================
//
// Garante que o widget raiz [App] constrói sem lançar exceção.
// Útil para verificar que a aplicação arranca correctamente.
//
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ipma_app/main.dart';

void main() {
  testWidgets('App constrói sem erro', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
