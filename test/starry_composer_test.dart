import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starry_ui/starry_ui.dart';

Widget _host(Widget child, {double width = 390, double height = 420}) =>
    MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: Center(
          child: SizedBox(width: width, height: height, child: child),
        ),
      ),
    );

void main() {
  for (final scale in [1.0, 1.3]) {
    testWidgets('composer header stays close to body at text scale $scale', (
      tester,
    ) async {
      const titleKey = Key('title');
      const bodyKey = Key('body');
      await tester.pumpWidget(
        _host(
          MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: StarryTextArea.composer(
              header: const TextField(
                key: titleKey,
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: 'Optional title',
                ),
              ),
              fieldKey: bodyKey,
              hint: 'Body',
            ),
          ),
        ),
      );
      final title = tester.getRect(find.byKey(titleKey));
      final body = tester.getRect(find.byKey(bodyKey));
      expect(body.left, title.left);
      expect(body.top - title.bottom, closeTo(12, 0.1));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('composer scrolls text while keeping toolbar and count visible', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _host(
        StarryTextArea.composer(
          controller: controller,
          maxLength: 2000,
          toolbar: const Text('工具栏'),
        ),
      ),
    );
    final toolbarY = tester.getTopLeft(find.text('工具栏')).dy;
    await tester.enterText(find.byType(TextField), '你好👋');
    await tester.pump();
    expect(find.text('3 / 2000'), findsOneWidget);
    controller.text = List.filled(80, '一行正文').join('\n');
    await tester.pump();
    expect(tester.getTopLeft(find.text('工具栏')).dy, toolbarY);
    expect(tester.takeException(), isNull);
  });

  testWidgets('media picker adds, edits, removes and disables all actions', (
    tester,
  ) async {
    var adds = 0;
    var edits = 0;
    var removes = 0;
    Widget picker(int count, {bool enabled = true}) => _host(
      StarryMediaPicker(
        itemCount: count,
        enabled: enabled,
        addLabel: '添加图片',
        cameraLabel: '相机',
        galleryLabel: '相册',
        gridLabel: '宫格',
        removeLabel: '删除图片',
        editLabel: '裁剪图片',
        onAddFromCamera: () => adds++,
        onAddFromGallery: () => adds++,
        onRemove: (_) => removes++,
        onEdit: (_) => edits++,
        mediaBuilder: (_, index) => Text('图片 $index'),
      ),
    );
    await tester.pumpWidget(picker(0));
    await tester.tap(find.text('添加图片'));
    expect(adds, 1);
    await tester.pumpWidget(picker(1));
    // 默认停在宫格总览，先点缩略图进入单张预览才能看到删除/裁剪。
    await tester.tap(find.byKey(const ValueKey('StarryMediaPicker.thumb.0')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('StarryMediaPicker.edit.0')));
    await tester.tap(find.byKey(const ValueKey('StarryMediaPicker.remove.0')));
    expect(edits, 1);
    expect(removes, 1);
    await tester.pumpWidget(picker(1, enabled: false));
    await tester.tap(
      find.byKey(const ValueKey('StarryMediaPicker.galleryTile')),
    );
    await tester.tap(find.byKey(const ValueKey('StarryMediaPicker.edit.0')));
    await tester.tap(find.byKey(const ValueKey('StarryMediaPicker.remove.0')));
    expect((adds, edits, removes), (1, 1, 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('media picker defaults to grid and the grid tile returns to it', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        StarryMediaPicker(
          itemCount: 3,
          addLabel: '添加图片',
          cameraLabel: '相机',
          galleryLabel: '相册',
          gridLabel: '宫格',
          removeLabel: '删除图片',
          editLabel: '裁剪图片',
          onAddFromCamera: () {},
          onAddFromGallery: () {},
          onRemove: (_) {},
          onEdit: (_) {},
          mediaBuilder: (_, index) => Text('图片 $index'),
        ),
        width: 480,
        height: 320,
      ),
    );
    expect(
      find.byKey(const ValueKey('StarryMediaPicker.grid')),
      findsOneWidget,
    );

    // 横条顺序固定为相机、相册、宫格、媒体 1..N。
    final cameraX = tester
        .getTopLeft(find.byKey(const ValueKey('StarryMediaPicker.cameraTile')))
        .dx;
    final galleryX = tester
        .getTopLeft(find.byKey(const ValueKey('StarryMediaPicker.galleryTile')))
        .dx;
    final gridX = tester
        .getTopLeft(find.byKey(const ValueKey('StarryMediaPicker.gridTile')))
        .dx;
    final thumbX = tester
        .getTopLeft(find.byKey(const ValueKey('StarryMediaPicker.thumb.0')))
        .dx;
    expect(cameraX < galleryX, isTrue);
    expect(galleryX < gridX, isTrue);
    expect(gridX < thumbX, isTrue);

    await tester.tap(find.byKey(const ValueKey('StarryMediaPicker.thumb.0')));
    await tester.pump();
    expect(
      find.byKey(const ValueKey('StarryMediaPicker.preview')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('StarryMediaPicker.edit.0')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('StarryMediaPicker.gridTile')));
    await tester.pump();
    expect(
      find.byKey(const ValueKey('StarryMediaPicker.grid')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('advisory composer count preserves drafts beyond the limit', (
    tester,
  ) async {
    final controller = TextEditingController(text: '已有草稿内容');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _host(
        StarryTextArea.composer(
          controller: controller,
          maxLength: 4,
          maxLengthEnforcement: MaxLengthEnforcement.none,
        ),
      ),
    );
    expect(controller.text, '已有草稿内容');
    expect(find.text('6 / 4'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '继续编辑这份草稿');
    await tester.pump();
    expect(controller.text, '继续编辑这份草稿');
    expect(find.text('8 / 4'), findsOneWidget);
  });

  testWidgets('nine media items keep camera and gallery tiles disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        StarryMediaPicker(
          itemCount: 9,
          addLabel: '添加图片',
          cameraLabel: '相机',
          galleryLabel: '相册',
          gridLabel: '宫格',
          removeLabel: '删除图片',
          editLabel: '裁剪图片',
          onAddFromCamera: () {},
          onAddFromGallery: () {},
          onRemove: (_) {},
          mediaBuilder: (_, index) => Text('图片 $index'),
        ),
        width: 280,
        height: 240,
      ),
    );
    expect(find.text('添加图片'), findsNothing);
    expect(find.text('相机'), findsOneWidget);
    expect(find.text('相册'), findsOneWidget);
    await tester.drag(find.byType(GridView), const Offset(0, -240));
    await tester.pumpAndSettle();
    expect(find.text('图片 8'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
