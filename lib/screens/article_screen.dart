import 'package:flutter/material.dart';

import '../models/education_content.dart';
import '../theme.dart';
import '../widgets/vihtal_app_bar.dart';

/// Lectura de un artículo educativo (sub-proyecto D).
class ArticleScreen extends StatelessWidget {
  const ArticleScreen({super.key, required this.topic});

  final EduTopic topic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: VihtalAppBar(
        showDonateAction: false,
        leading: BackButton(
          color: AppColors.primary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.surfaceSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(topic.icon, color: AppColors.primary, size: 30),
          ),
          const SizedBox(height: 16),
          Text(topic.title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.schedule_rounded,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${topic.readMinutes} min de lectura',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 20),
          for (final paragraph in topic.body) ...[
            Text(
              paragraph,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.info_outline_rounded,
                    size: 18, color: AppColors.accent),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    EduTopic.disclaimer,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.accent,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
