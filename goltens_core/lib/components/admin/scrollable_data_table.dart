import 'package:flutter/material.dart';

class ScrollableDataTable extends StatefulWidget {
  final Widget child;

  const ScrollableDataTable({
    super.key,
    required this.child,
  });

  @override
  State<ScrollableDataTable> createState() => _ScrollableDataTableState();
}

class _ScrollableDataTableState extends State<ScrollableDataTable> {
  @override
  Widget build(BuildContext context) {
    final verticalScrollController = ScrollController();
    final horizontalScrollController = ScrollController();

    return Scrollbar(
      controller: verticalScrollController,
      thumbVisibility: true,
      trackVisibility: true,
      child: Scrollbar(
        controller: horizontalScrollController,
        thumbVisibility: true,
        trackVisibility: true,
        notificationPredicate: (notif) => notif.depth == 1,
        child: SingleChildScrollView(
          controller: verticalScrollController,
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            controller: horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
