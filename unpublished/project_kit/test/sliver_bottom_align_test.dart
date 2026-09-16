import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_kit/project_kit.dart';

const _viewport = Size(400, 600);

Future<void> _pump(
  WidgetTester tester,
  Widget sliver, {
  double preceding = 100,
  ScrollController? controller,
}) async {
  tester.view
    ..physicalSize = _viewport
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: CustomScrollView(
        controller: controller,
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: preceding)),
          sliver,
        ],
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('прижимает ребёнка к низу вьюпорта', (tester) async {
    await _pump(
      tester,
      const SliverBottomAlign(
        child: SizedBox(height: 50, width: 50, child: Placeholder()),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getRect(find.byType(Placeholder)).bottom, _viewport.height);
  });

  testWidgets('растёт, когда контент выше остатка вьюпорта', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await _pump(
      tester,
      const SliverBottomAlign(
        child: SizedBox(height: 800, width: 50, child: Placeholder()),
      ),
      controller: controller,
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(Placeholder)).height, 800);

    controller.jumpTo(300);
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(tester.getRect(find.byType(Placeholder)).top, 100 - 300);
  });

  testWidgets('не требует intrinsic-размеров от поддерева', (tester) async {
    await _pump(
      tester,
      SliverBottomAlign(
        child: LayoutBuilder(
          builder:
              (context, constraints) =>
                  SizedBox(height: 50, width: constraints.maxWidth),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(SizedBox).last).width, _viewport.width);
  });

  testWidgets('применяет padding и crossAxisAlignment', (tester) async {
    await _pump(
      tester,
      const SliverBottomAlign(
        padding: EdgeInsets.only(left: 20, bottom: 30),
        crossAxisAlignment: CrossAxisAlignment.start,
        child: SizedBox(height: 50, width: 50, child: Placeholder()),
      ),
    );

    final rect = tester.getRect(find.byType(Placeholder));
    expect(rect.left, 20);
    expect(rect.bottom, _viewport.height - 30);
  });

  testWidgets('скролл не перестраивает поддерево', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    var builds = 0;
    await _pump(
      tester,
      SliverBottomAlign(
        child: Builder(
          builder: (context) {
            builds++;

            return const SizedBox(height: 800, width: 50);
          },
        ),
      ),
      controller: controller,
    );
    expect(builds, 1);

    controller.jumpTo(120);
    await tester.pump();
    controller.jumpTo(240);
    await tester.pump();

    expect(builds, 1);
  });
}
