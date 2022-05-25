// ignore_for_file: unnecessary_getters_setters

library draggable_bottom_sheet_nullsafety;

import 'dart:ui';
import 'package:flutter/material.dart';

/// Partially visible bottom sheet that can be dragged into the screen.
/// Provides different views for expanded and collapsed states.
class DraggableBottomSheet extends StatefulWidget {
  /// This widget will hide behind the sheet when expanded.
  final Widget backgroundWidget;

  /// Child to be displayed when sheet is not expended.
  final Widget previewChild;

  /// Child of expended sheet.
  final Widget expandedChild;

  /// Alignment of the sheet.
  final Alignment alignment;

  /// Whether to blur the background while sheet expnasion (true: modal-sheet
  /// false: persistent-sheet)
  final bool blurBackground;

  /// Extent from the min-height to change from [previewChild] to
  /// [expandedChild].
  final double expansionExtent;

  /// Max-extent for sheet expansion.
  final double maxExtent;

  /// Min-extent for the sheet, also the original height of the sheet.
  final double minExtent;

  /// Scroll direction of the sheet.
  final Axis scrollDirection;

  /// draggable controller
  final DraggableSheetController controller;

  const DraggableBottomSheet({
    Key? key,
    required this.backgroundWidget,
    required this.previewChild,
    required this.expandedChild,
    required this.controller,
    this.alignment = Alignment.bottomLeft,
    this.blurBackground = true,
    this.expansionExtent = 10,
    this.maxExtent = double.infinity,
    this.minExtent = 10,
    this.scrollDirection = Axis.vertical,
  }) : super(key: key);

  @override
  _DraggableBottomSheetState createState() => _DraggableBottomSheetState();
}

class _DraggableBottomSheetState extends State<DraggableBottomSheet> {
  late double currentHeight;
  double? newHeight;

  @override
  void initState() {
    currentHeight = widget.minExtent;
    super.initState();
    widget.controller.addListener(() {
      if (widget.controller.close) {
        currentHeight = newHeight = widget.minExtent;
        setState(() {});
      } else if (widget.controller.open) {
        currentHeight = newHeight = widget.maxExtent;
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(covariant DraggableBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.maxExtent != oldWidget.maxExtent ||
        widget.minExtent != oldWidget.minExtent ||
        widget.alignment != oldWidget.alignment) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        widget.backgroundWidget,
        (currentHeight - widget.minExtent < 10 || !widget.blurBackground)
            ? const SizedBox()
            : Positioned.fill(
                child: GestureDetector(
                onTap: () => setState(() => currentHeight = widget.minExtent),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  ),
                ),
              )),
        Align(
          alignment: widget.alignment,
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              if (widget.scrollDirection == Axis.horizontal) return;
              newHeight = currentHeight - details.delta.dy;
              if (newHeight! > widget.minExtent &&
                  newHeight! < widget.maxExtent) {
                setState(() => currentHeight = newHeight!);
              }
            },
            onVerticalDragEnd: (details) {
              if (newHeight! > (widget.maxExtent / 2)) {
                currentHeight = newHeight = widget.maxExtent;
              } else {
                currentHeight = newHeight = widget.minExtent;
              }
              setState(() {});
            },
            onHorizontalDragUpdate: (details) {
              if (widget.scrollDirection == Axis.vertical) return;
              newHeight = currentHeight + details.delta.dx;
              if (newHeight! > widget.minExtent &&
                  newHeight! < widget.maxExtent) {
                setState(() => currentHeight = newHeight!);
              }
            },
            child: SizedBox(
              width: (widget.scrollDirection == Axis.vertical)
                  ? double.infinity
                  : currentHeight,
              height: (widget.scrollDirection == Axis.horizontal)
                  ? double.infinity
                  : currentHeight,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: (widget.scrollDirection == Axis.vertical)
                      ? double.infinity
                      : currentHeight,
                  maxHeight: (widget.scrollDirection == Axis.horizontal)
                      ? double.infinity
                      : currentHeight,
                ),
                child:
                    (currentHeight - widget.minExtent < widget.expansionExtent)
                        ? widget.previewChild
                        : widget.expandedChild,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DraggableSheetController extends ChangeNotifier {
  bool get close => _close;
  bool _close = false;
  set close(bool close) {
    _close = close;
    notifyListeners();
  }

  bool get open => _open;
  bool _open = true;
  set open(bool open) {
    _open = open;
    notifyListeners();
  }
}
