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
                GestureDetector(
                  onTap: () => _editItem(context, state, item),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 11, vertical: 9),
                    decoration: BoxDecoration(
                      color: chipColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.expiry == null
                              ? item.label
                              : '${item.label} · ${item.expiry!.day}/${item.expiry!.month}',
                          style: ts(14, h: 1.35),
                        ),
                        const SizedBox(width: 7),
                        GestureDetector(
                          onTap: () => state.removePantry(item),
                          child: const Icon(Icons.close_rounded,
                              size: 13, color: Pal.inkSoft),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _editItem(
      BuildContext context, AppState state, Pantry item) async {
    final qty = TextEditingController(text: item.qty);
    DateTime? expiry = item.expiry;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(item.name, style: ts(18, w: FontWeight.w800)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: qty,
              decoration: const InputDecoration(labelText: 'Quantité'),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(expiry == null
                  ? 'Date de péremption facultative'
                  : 'À utiliser avant le ${expiry!.day}/${expiry!.month}'),
              trailing: const Icon(Icons.calendar_today_rounded, size: 18),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 730)),
                  initialDate: expiry ?? DateTime.now(),
                );
                if (picked != null) setDialogState(() => expiry = picked);
              },
            ),
          ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler')),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Enregistrer')),
          ],
        ),
      ),
    );
    final quantity = qty.text;
    qty.dispose();
    if (saved == true) {
      state.updatePantry(item, qty: quantity, expiry: expiry);
    }
  }
}
