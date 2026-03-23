import 'package:flutter/material.dart';

class SampleListWidget extends StatelessWidget {
  const SampleListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      dense: true,
      title: Text(
        'Dummy Title',
        style: TextStyle(
          fontSize: 12,
        ),
      ),
      subtitle: Text(
        'Dummy substitle',
        style: TextStyle(
          fontSize: 10,
        ),
      ),
    );
  }
}
