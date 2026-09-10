import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_add_button.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../infra/testable_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  SingleChildScrollView tableScrollView(WidgetTester tester) =>
      tester.widget<SingleChildScrollView>(
        find.descendant(
          of: find.byType(TableBlockComponentWidget),
          matching: find.byType(SingleChildScrollView),
        ),
      );

  group('table style', () {
    testWidgets('renders the add buttons and the default padding by default',
        (tester) async {
      final tableNode = TableNode.fromList([
        ['a', 'b'],
        ['c', 'd'],
      ]);
      final editor = tester.editor..addNode(tableNode.node);

      await editor.startTesting();
      await tester.pumpAndSettle();

      // one add-column button and one add-row button.
      expect(find.byType(TableActionButton), findsNWidgets(2));
      expect(tableScrollView(tester).padding, TableDefaults.contentPadding);

      // the 28dp add-row strip sits below the rows.
      expect(
        tester.getSize(find.byType(TableView)).height,
        tableNode.colsHeight + 28,
      );

      await editor.dispose();
    });

    testWidgets('reserves no chrome when the add buttons are hidden',
        (tester) async {
      final tableNode = TableNode.fromList([
        ['a', 'b'],
        ['c', 'd'],
      ]);
      final editor = tester.editor..addNode(tableNode.node);

      await editor.startTesting(
        blockComponentBuilders: {
          ...standardBlockComponentBuilderMap,
          TableBlockKeys.type: TableBlockComponentBuilder(
            tableStyle: const TableStyle(
              showAddButtons: false,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        },
      );
      await tester.pumpAndSettle();

      expect(find.byType(TableActionButton), findsNothing);
      expect(tableScrollView(tester).padding, EdgeInsets.zero);

      // no trailing add-row strip: the table is exactly as tall as its rows.
      expect(
        tester.getSize(find.byType(TableView)).height,
        tableNode.colsHeight,
      );

      await editor.dispose();
    });

    testWidgets('row height extra defaults to 8 and is configurable',
        (tester) async {
      final tableNode = TableNode.fromList([
        ['', ''],
        ['', ''],
      ]);
      final editor = tester.editor..addNode(tableNode.node);

      await editor.startTesting();
      await tester.pumpAndSettle();

      expect(TableNode(node: tableNode.node).rowHeightExtra, 8);

      final zeroExtra = TableNode(node: tableNode.node, rowHeightExtra: 0);
      expect(zeroExtra.rowHeightExtra, 0);

      final cellHeight = tableNode.getCell(0, 0).children.first.rect.height;

      final transaction = editor.editorState.transaction;
      zeroExtra.updateRowHeight(0, transaction: transaction);
      await editor.editorState.apply(transaction);

      expect(zeroExtra.getRowHeight(0), cellHeight);

      await editor.dispose();
    });

    testWidgets('the builder passes the style row height extra to the node',
        (tester) async {
      final tableNode = TableNode.fromList([
        ['', ''],
        ['', ''],
      ]);
      final editor = tester.editor..addNode(tableNode.node);

      await editor.startTesting(
        blockComponentBuilders: {
          ...standardBlockComponentBuilderMap,
          TableBlockKeys.type: TableBlockComponentBuilder(
            tableStyle: const TableStyle(rowHeightExtra: 0),
          ),
        },
      );
      await tester.pumpAndSettle();

      final widget = tester.widget<TableBlockComponentWidget>(
        find.byType(TableBlockComponentWidget),
      );
      expect(widget.tableNode.rowHeightExtra, 0);
      expect(widget.tableStyle.rowHeightExtra, 0);

      await editor.dispose();
    });
  });
}
