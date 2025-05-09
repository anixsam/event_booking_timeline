import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class HorizontalListWheelScrollView extends StatelessWidget {
  /// All the properties are same as [ListWheelScrollView] except [scrollDirection] and [children].
  final Axis scrollDirection;
  final List<Widget>? children;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final double diameterRatio;
  final double perspective;
  final double offAxisFraction;
  final bool useMagnifier;
  final double magnification;
  final double overAndUnderCenterOpacity;
  final double itemExtent;
  final double squeeze;
  final ValueChanged<int>? onSelectedItemChanged;
  final bool renderChildrenOutsideViewport;
  final ListWheelChildDelegate? childDelegate;
  final Clip clipBehavior;

  /// Creates a [ListWheelScrollView] that scrolls items horizontally.
  const HorizontalListWheelScrollView({
    super.key,
    this.scrollDirection = Axis.vertical,
    this.controller,
    this.physics,
    this.diameterRatio = RenderListWheelViewport.defaultDiameterRatio,
    this.perspective = RenderListWheelViewport.defaultPerspective,
    this.offAxisFraction = 0.0,
    this.useMagnifier = false,
    this.magnification = 1.0,
    this.overAndUnderCenterOpacity = 1.0,
    required this.itemExtent,
    this.squeeze = 1.0,
    this.onSelectedItemChanged,
    this.renderChildrenOutsideViewport = false,
    this.clipBehavior = Clip.hardEdge,
    required this.children,
  })  : childDelegate = null;

  /// Creates a [ListWheelScrollView] that scrolls items horizontally.
  const HorizontalListWheelScrollView.useDelegate({
    super.key,
    this.scrollDirection = Axis.vertical,
    this.controller,
    this.physics,
    this.diameterRatio = RenderListWheelViewport.defaultDiameterRatio,
    this.perspective = RenderListWheelViewport.defaultPerspective,
    this.offAxisFraction = 0.0,
    this.useMagnifier = false,
    this.magnification = 1.0,
    this.overAndUnderCenterOpacity = 1.0,
    required this.itemExtent,
    this.squeeze = 1.0,
    this.onSelectedItemChanged,
    this.renderChildrenOutsideViewport = false,
    this.clipBehavior = Clip.hardEdge,
    required this.childDelegate,
  })  : children = null;

  @override
  Widget build(BuildContext context) {
    final customChildDelegate = children != null
        ? ListWheelChildListDelegate(
            children: children!.map((child) {
            return RotatedBox(
              quarterTurns: scrollDirection == Axis.horizontal ? 1 : 0,
              child: child,
            );
          }).toList())
        : ListWheelChildBuilderDelegate(
            builder: (context, index) {
              return RotatedBox(
                quarterTurns: scrollDirection == Axis.horizontal ? 1 : 0,
                child: childDelegate!.build(context, index),
              );
            },
          );

    /// RotatedBox is used to rotate the child by 90 degrees.
    return RotatedBox(
      quarterTurns: scrollDirection == Axis.horizontal ? 3 : 0,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        physics: const FixedExtentScrollPhysics(),
        diameterRatio: diameterRatio,
        perspective: perspective,
        offAxisFraction: offAxisFraction,
        useMagnifier: useMagnifier,
        magnification: magnification,
        overAndUnderCenterOpacity: overAndUnderCenterOpacity,
        itemExtent: itemExtent,
        squeeze: squeeze,
        onSelectedItemChanged: onSelectedItemChanged,
        renderChildrenOutsideViewport: renderChildrenOutsideViewport,
        clipBehavior: clipBehavior,
        childDelegate: customChildDelegate,
      ),
    );
  }
}
