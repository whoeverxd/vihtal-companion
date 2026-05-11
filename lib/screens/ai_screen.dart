import 'package:flutter/material.dart';
import '../widgets/vihtal_app_bar.dart';

class AiScreen extends StatelessWidget {
  const AiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const VihtalAppBar(),
      body: const Center(
        child: Text(
          'IA',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
