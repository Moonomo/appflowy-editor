import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../infra/testable_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('quote_block_component.dart', () {
    testWidgets('renders a quote without children', (tester) async {
      final editor = tester.editor
        ..addNode(quoteNode(delta: Delta()..insert('quoted')));

      await editor.startTesting();
      await tester.pumpAndSettle();

      expect(find.byType(QuoteBlockComponentWidget), findsOneWidget);
      expect(find.text('quoted', findRichText: true), findsOneWidget);

      await editor.dispose();
    });

    testWidgets('renders the children nested inside the quote', (tester) async {
      final quote = quoteNode(
        delta: Delta()..insert('quoted'),
        children: [
          bulletedListNode(text: 'first'),
          bulletedListNode(text: 'second'),
        ],
      );
      final editor = tester.editor..addNode(quote);

      await editor.startTesting();
      await tester.pumpAndSettle();

      expect(find.byType(QuoteBlockComponentWidget), findsOneWidget);
      expect(find.text('quoted', findRichText: true), findsOneWidget);
      expect(find.text('first', findRichText: true), findsOneWidget);
      expect(find.text('second', findRichText: true), findsOneWidget);

      // the children render inside the quote, so the bar spans them.
      expect(
        find.descendant(
          of: find.byType(QuoteBlockComponentWidget),
          matching: find.byType(BulletedListBlockComponentWidget),
        ),
        findsNWidgets(2),
      );

      await editor.dispose();
    });

    testWidgets('a quote with children is taller than one without',
        (tester) async {
      final plain = quoteNode(delta: Delta()..insert('quoted'));
      final withChildren = quoteNode(
        delta: Delta()..insert('quoted'),
        children: [bulletedListNode(text: 'child')],
      );
      final editor = tester.editor
        ..addNode(plain)
        ..addNode(withChildren);

      await editor.startTesting();
      await tester.pumpAndSettle();

      final sizes = tester
          .widgetList<QuoteBlockComponentWidget>(
            find.byType(QuoteBlockComponentWidget),
          )
          .map((w) => tester.getSize(find.byWidget(w)))
          .toList();

      expect(sizes.length, 2);
      expect(sizes[1].height > sizes[0].height, true);

      await editor.dispose();
    });
  });
}
