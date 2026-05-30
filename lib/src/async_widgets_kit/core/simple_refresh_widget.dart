import 'package:flutter/material.dart';

class SimpleRefreshWidget extends StatelessWidget {
  const SimpleRefreshWidget({
    super.key,
    required this.isRefreshing,
    required this.child,
  });

  final bool isRefreshing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isRefreshing)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: const LinearProgressIndicator(),
          ),
      ],
    );
  }
}
