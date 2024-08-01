import 'package:flutter/material.dart';

class SingleChildScrollableWithHints extends StatefulWidget {
  final Widget child;

  const SingleChildScrollableWithHints({super.key, required this.child});

  @override
  _MyScrollableWidgetState createState() => _MyScrollableWidgetState();
}

class _MyScrollableWidgetState extends State<SingleChildScrollableWithHints> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollUp = false;
  bool _showScrollDown = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void didUpdateWidget(SingleChildScrollableWithHints oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollHints());
  }

  void _scrollListener() {
    _updateScrollHints();
  }

  void _updateScrollHints() {
    if (!mounted) return;

    final bool isAtTop =
        _scrollController.position.pixels == _scrollController.position.minScrollExtent;
    final bool isAtBottom =
        _scrollController.position.pixels == _scrollController.position.maxScrollExtent;

    setState(() {
      _showScrollUp = !isAtTop;
      _showScrollDown = !isAtBottom;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (OverscrollIndicatorNotification overscroll) {
              overscroll.disallowIndicator();
              return true; // Return true to cancel the notification propagation.
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              child: widget.child,
            )),
        if (_showScrollUp)
          const Positioned(
              top: 0,
              right: 0,
              child: Center(
                child: Icon(
                  Icons.keyboard_arrow_up,
                  color: Colors.grey,
                  size: 48,
                ),
              )),
        if (_showScrollDown)
          const Positioned(
              bottom: 0,
              right: 0,
              child: Center(
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey,
                  size: 48,
                ),
              )),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }
}
