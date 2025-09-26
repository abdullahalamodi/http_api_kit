// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class SimpleEmptyWidget extends StatelessWidget {
  const SimpleEmptyWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Text(
        'No Data Found  :)',
      ),
    );
  }
}
