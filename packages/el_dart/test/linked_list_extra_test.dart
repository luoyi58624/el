import 'package:el_dart/src/ext/linked_list.dart';
import 'package:test/test.dart';

final class _Node with ElLinkedNode<_Node> {
  _Node(this.label);
  final String label;

  @override
  String get debugLabel => label;
}

final class _TinyPrintList extends ElLinkedList<_Node> {
  @override
  int get maxPrintLength => 1;
}

void main() {
  group('ElLinkedList extra coverage', () {
    test('initNode invariants and addFirst path', () {
      final list = ElLinkedList<_Node>();
      list.addFirst(_Node('a')); // addFirst -> initNode
      expect(list.first.debugLabel, 'a');
      expect(list.last.debugLabel, 'a');
      expect(list.isEmpty, false);
    });

    test('find and elementAt reverse scan branch', () {
      final list = ElLinkedList<_Node>();
      list.addAll([_Node('a'), _Node('b'), _Node('c'), _Node('d')]);
      expect(list.find((e) => e.debugLabel == 'c')?.debugLabel, 'c');
      expect(list.find((e) => e.debugLabel == 'x'), null);

      // index > length/2 triggers reverse scan from last
      expect(list.elementAt(3).debugLabel, 'd');
    });

    test('addAllFirst inserts to front in order', () {
      final list = ElLinkedList<_Node>();
      list.addAll([_Node('c'), _Node('d')]);
      list.addAllFirst([_Node('b'), _Node('a')]);
      expect(list.map((e) => e.debugLabel).toList(), ['a', 'b', 'c', 'd']);
    });

    test('remove last node resets first/last', () {
      final list = ElLinkedList<_Node>();
      final n = _Node('a');
      list.add(n);
      expect(list.length, 1);
      list.remove(n);
      expect(list.length, 0);
      expect(list.firstOrNull, null);
      expect(list.lastOrNull, null);
    });

    test('toString uses maxPrintLength truncation branch', () {
      final list = _TinyPrintList();
      list.add(_Node('a'));
      list.add(_Node('b'));
      list.add(_Node('c'));
      final s = list.toString();
      expect(s.contains('...'), true);
      expect(s.contains('c'), true);
    });

    test('toString uses non-truncation branch', () {
      final list = ElLinkedList<_Node>();
      list.addAll([_Node('a'), _Node('b')]);
      final s = list.toString();
      expect(s.contains('a'), true);
      expect(s.contains('b'), true);
      expect(s.contains('...'), false);
    });

    test('iterator throws on concurrent modification', () {
      final list = ElLinkedList<_Node>();
      list.add(_Node('a'));
      list.add(_Node('b'));

      final it = list.iterator;
      expect(it.moveNext(), true);

      // modify during iteration
      list.add(_Node('c'));
      expect(() => it.moveNext(), throwsA(isA<ConcurrentModificationError>()));
    });

    test('node default debugLabel and node toString formatting', () {
      final list = ElLinkedList<_Node2>();
      final a = _Node2();
      final b = _Node2();
      list.addAll([a, b]);
      final s = a.toString();
      expect(s.contains('<-'), true);
      expect(s.contains('->'), true);
    });
  });
}

final class _Node2 with ElLinkedNode<_Node2> {}

