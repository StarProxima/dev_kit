import 'package:app_logger/app_logger.dart';
import 'package:cr_json_widget/cr_json_recycler.dart';
import 'package:flutter/material.dart';

class JsonWidget extends StatefulWidget {
  const JsonWidget(
    this.jsonObj, {
    this.notRoot,
    this.caption,
    this.allExpandedNodes = false,
    this.uncovered = 1,
    super.key,
  });

  final dynamic jsonObj;
  final bool? notRoot;
  final Widget? caption;
  final bool allExpandedNodes;
  final int uncovered;

  @override
  JsonWidgetState createState() => JsonWidgetState();
}

class JsonWidgetState extends State<JsonWidget> {
  late final _jsonCtr = JsonRecyclerController(isExpanded: false);

  Map<String, dynamic>? _jsonWithHiddenParameters;

  @override
  void initState() {
    super.initState();
    _updateNodes();
  }

  @override
  Widget build(BuildContext context) {
    final jsonObj = widget.jsonObj;

    return jsonObj == null || jsonObj.isEmpty
        ? const SizedBox()
        : Padding(
            padding:
                EdgeInsets.only(left: (widget.notRoot ?? false) ? 14.0 : 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.caption != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: widget.caption,
                  ),
                if (jsonObj is List)
                  CustomScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    slivers: [
                      if (_jsonWithHiddenParameters != null)
                        CrJsonRecyclerSliver(
                          jsonController: _jsonCtr,
                          json: _jsonWithHiddenParameters,
                          rootExpanded: true,
                        )
                      else
                        SliverToBoxAdapter(
                          child: Text(jsonObj.toString()),
                        ),
                    ],
                  )
                else

                  /// JsonTreeView
                  CustomScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    slivers: [
                      if (jsonObj is Map<String, dynamic>)
                        CrJsonRecyclerSliver(
                          jsonController: _jsonCtr,
                          json: _jsonWithHiddenParameters,
                          rootExpanded: true,
                        ),
                      if (jsonObj is List)
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final element = jsonObj[index];
                              return Text(element.toString());
                            },
                            childCount: jsonObj.length,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          );
  }

  @override
  void didUpdateWidget(covariant JsonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateNodes();

    if (oldWidget.allExpandedNodes != widget.allExpandedNodes) {
      _jsonCtr.changeState();
    }
  }

  /// Create Nodes3 = {map entry} "Test3" -> "Hidden"4 = {map entry} "Test4" -3 = {map entry} "Test3" -> "Hidden"> [_InternalLinkedHashMap]
  Map<String, dynamic>? _toTreeJson(Map<String, dynamic> jsonObj) {
    for (final obj in jsonObj.keys) {
      final isHidden = AppLoggerInitializer.instance.hiddenFields.contains(obj);
      if (isHidden) {
        jsonObj[obj] = 'Hidden';
      }
    }

    return jsonObj;
  }

  void _updateNodes() {
    if (widget.jsonObj == null) return;
    if (widget.jsonObj is List && widget.jsonObj.isEmpty) return;

    if (widget.jsonObj is Map<String, dynamic>) {
      _jsonWithHiddenParameters = _toTreeJson(widget.jsonObj!);
    } else if (widget.jsonObj is List) {
      final resultMap = <String, dynamic>{};
      var index = 0;
      (widget.jsonObj as List).forEach(
        (element) => resultMap['${index++}'] = element,
      );
      _jsonWithHiddenParameters = resultMap;
    }
  }
}
