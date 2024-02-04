import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final int maxCollapsedLines;

  const ExpandableText({
    Key? key,
    required this.text,
    this.style,
    this.maxCollapsedLines = 4,
  }) : super(key: key);

  @override
  ExpandableTextState createState() => ExpandableTextState();
}

class ExpandableTextState extends State<ExpandableText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightFactor;
  bool isExpandable = false;
  bool isExpanded = false;
  double initialHeightFactor = 0;
  GlobalKey textKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _heightFactor = Tween<double>(begin: initialHeightFactor, end: 1.0)
        .animate(_controller);

    WidgetsBinding.instance.addPostFrameCallback((_) => calculateHeights());
  }

  void calculateHeights() {
    final RenderBox renderBox =
        textKey.currentContext!.findRenderObject() as RenderBox;
    final double fullHeight = renderBox.size.height;

    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: widget.maxCollapsedLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: renderBox.size.width);

    final double collapsedHeight = textPainter.size.height;

    setState(() {
      initialHeightFactor = collapsedHeight / fullHeight;
      _heightFactor = Tween<double>(
        begin: initialHeightFactor,
        end: 1.0,
      ).animate(_controller);
      _controller.value = 0.0;
      isExpandable =
          fullHeight > collapsedHeight; // Check if text is overflowing
    });
  }

  void toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
      isExpanded ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleExpanded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _heightFactor.value,
                  child: child,
                ),
              );
            },
            child: Text(
              widget.text,
              key: textKey,
              style: widget.style,
              softWrap: true,
              overflow: TextOverflow.fade,
            ),
          ),
          if (isExpandable)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Icon(
                  isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
