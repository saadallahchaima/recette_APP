import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/theme.dart';
import '../../../recipes/data/models/data.dart';
import '../../../recipes/presentation/controllers/app_state.dart';

class PantryCategorySection extends StatelessWidget {
  final Cat category;
  final Color chipColor;

  const PantryCategorySection({
    super.key,
    required this.category,
    required this.chipColor,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    final items =
        state.pantry.where((item) => item.cat == category.name).toList();
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(category.image, width: 24, height: 24),
              const SizedBox(width: 7),
              Text(category.name, style: ts(14, w: FontWeight.w800, h: 1.35)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final item in items)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                  decoration: BoxDecoration(
                    color: chipColor,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(item.label, style: ts(14, h: 1.35)),
                      const SizedBox(width: 7),
                      GestureDetector(
                        onTap: () => state.removePantry(item),
                        child: const Icon(Icons.close_rounded,
                            size: 13, color: Pal.inkSoft),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
