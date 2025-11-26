import 'package:flutter/material.dart';

class ExpandableTile extends StatefulWidget {
  final String title;
  final IconData icon;
  final Widget expandedContent;

  const ExpandableTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.expandedContent,
  }) : super(key: key);

  @override
  _ExpandableTileState createState() => _ExpandableTileState();
}

class _ExpandableTileState extends State<ExpandableTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.015),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(widget.icon,
                          size: screenWidth * 0.06, color: Colors.blue),
                      SizedBox(width: screenWidth * 0.03),
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    size: screenWidth * 0.06,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.015),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: widget.expandedContent,
            ),
        ],
      ),
    );
  }
}
