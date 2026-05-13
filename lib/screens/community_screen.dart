import 'package:flutter/material.dart';

import '../widgets/vihtal_app_bar.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: VihtalAppBar(),
      body: Center(
        child: Text(
          'Comunidad',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

