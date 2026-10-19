import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

void main() {
  group('StarryActionItem.matchesFilter', () {
    test('empty query matches every item', () {
      const item = StarryActionItem(id: 'a', title: 'Camera');
      expect(item.matchesFilter(''), isTrue);
      expect(item.matchesFilter('   '), isTrue);
    });

    test('matches title case-insensitively', () {
      const item = StarryActionItem(id: 'a', title: 'Web Search');
      expect(item.matchesFilter('web'), isTrue);
      expect(item.matchesFilter('SEARCH'), isTrue);
      expect(item.matchesFilter('file'), isFalse);
    });

    test('matches subtitle and keywords', () {
      const item = StarryActionItem(
        id: 'a',
        title: 'Model',
        subtitle: 'Pick connection',
        keywords: ['llm', 'provider'],
      );
      expect(item.matchesFilter('pick'), isTrue);
      expect(item.matchesFilter('LLM'), isTrue);
      expect(item.matchesFilter('provider'), isTrue);
      expect(item.matchesFilter('camera'), isFalse);
    });
  });

  group('groupStarryActionItems', () {
    test('ungrouped items render first under a null header', () {
      final groups = groupStarryActionItems(const [
        StarryActionItem(id: '1', title: 'New'),
        StarryActionItem(id: '2', title: 'Model', group: 'Runtime'),
        StarryActionItem(id: '3', title: 'Status'),
      ]);
      expect(groups, hasLength(2));
      expect(groups.first.title, isNull);
      expect(groups.first.items.map((i) => i.id), ['1', '3']);
      expect(groups.last.title, 'Runtime');
      expect(groups.last.items.single.id, '2');
    });

    test('groups appear in first-appearance order', () {
      final groups = groupStarryActionItems(const [
        StarryActionItem(id: '1', title: 'A', group: 'Second'),
        StarryActionItem(id: '2', title: 'B', group: 'First'),
      ]);
      expect(groups.map((g) => g.title), ['Second', 'First']);
    });
  });

  group('filterAndGroupStarryActionItems', () {
    test('drops groups emptied by the filter', () {
      final groups = filterAndGroupStarryActionItems(const [
        StarryActionItem(id: '1', title: 'New'),
        StarryActionItem(id: '2', title: 'Model', group: 'Runtime'),
        StarryActionItem(id: '3', title: 'Status', group: 'Runtime'),
      ], 'status');
      expect(groups, hasLength(1));
      expect(groups.single.title, 'Runtime');
      expect(groups.single.items.single.id, '3');
    });

    test('returns empty list when nothing matches', () {
      final groups = filterAndGroupStarryActionItems(const [
        StarryActionItem(id: '1', title: 'New'),
        StarryActionItem(id: '2', title: 'Model', group: 'Runtime'),
      ], 'zzz');
      expect(groups, isEmpty);
    });
  });
}
