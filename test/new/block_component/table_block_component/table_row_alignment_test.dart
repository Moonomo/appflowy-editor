import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_config.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../infra/testable_editor.dart';

/// An imported table arrives with cell text but no stored row heights, so the
/// first layout is the only chance to line the columns up. These tests cover a
/// read-only view, where a transaction is dropped before it reaches the
/// document, as well as the editable view.
void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  /// A table whose first column wraps onto several lines at the column width
  /// while the other two columns stay on one line.
  TableNode buildWrappingTable() => TableNode.fromList(
        [
          [
            'Item',
            'Quartz worktop, 30 mm deep, honed finish',
            'Shaker doors, painted in eggshell',
            'Under-cabinet lights, warm white',
          ],
          ['Supplier', 'Stonewright', 'Fenmore', 'Halden'],
          ['Lead time', '3 weeks', '5 weeks', '2 weeks'],
        ],
        config: TableConfig(colDefaultWidth: 120),
      );

  Rect cellRect(WidgetTester tester, TableNode table, int col, int row) =>
      tester.getRect(find.byKey(table.getCell(col, row).key));

  void expectRowsAligned(WidgetTester tester, TableNode table) {
    for (var row = 0; row < table.rowsLen; row++) {
      final first = cellRect(tester, table, 0, row);
      for (var col = 1; col < table.colsLen; col++) {
        final other = cellRect(tester, table, col, row);
        expect(
          other.top,
          moreOrLessEquals(first.top, epsilon: 0.5),
          reason: 'row $row: cell $col top does not match cell 0',
        );
        expect(
          other.bottom,
          moreOrLessEquals(first.bottom, epsilon: 0.5),
          reason: 'row $row: cell $col bottom does not match cell 0',
        );
      }
    }
  }

  group('table row alignment across columns', () {
    testWidgets('an imported table lines its rows up in a read-only view',
        (tester) async {
      final tableNode = buildWrappingTable();
      final editor = tester.editor..addNode(tableNode.node);

      await editor.startTesting(editable: false);
      await tester.pumpAndSettle();

      expectRowsAligned(tester, tableNode);

      // the wrapping first column is what drives row 1's height.
      expect(
        tableNode.getRowHeight(1),
        greaterThan(tableNode.getRowHeight(0)),
      );
      expect(
        getCellNode(tableNode.node, 2, 1)!.cellHeight,
        tableNode.getRowHeight(1),
      );

      await editor.dispose();
    });

    testWidgets('an imported table lines its rows up in an editable view',
        (tester) async {
      final tableNode = buildWrappingTable();
      final editor = tester.editor..addNode(tableNode.node);

      await editor.startTesting();
      await tester.pumpAndSettle();

      expectRowsAligned(tester, tableNode);

      await editor.dispose();
    });
  });
}
