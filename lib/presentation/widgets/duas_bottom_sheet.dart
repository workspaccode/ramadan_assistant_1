import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ramadan_assistant/core/di/service_locator.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/services/dua_service.dart';
import 'package:ramadan_assistant/data/models/dua_model.dart';

class DuasBottomSheet extends StatelessWidget {
  const DuasBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.ramadanTheme;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.textDim.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.auto_stories_rounded, color: theme.primary),
                const SizedBox(width: 12),
                Text(
                  'browse_100_duas'.tr(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: theme.textDim),
                ),
              ],
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                final categories = sl<DuaService>().hundredDuas;
                
                if (categories.isEmpty) {
                  return Center(
                    child: Text(
                      'no_duas_found'.tr(),
                      style: TextStyle(color: theme.textSecondary),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            category.category.tr(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.primary,
                            ),
                          ),
                        ),
                        ...category.duas.map((dua) => _DuaListItem(dua: dua)),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DuaListItem extends StatelessWidget {
  final Dua dua;

  const _DuaListItem({required this.dua});

  @override
  Widget build(BuildContext context) {
    final theme = context.ramadanTheme;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.textDim.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SelectableText(
            dua.arabic,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 17,
              height: 1.6,
              fontFamily: 'Amiri', // Assuming Amiri is available for Arabic
              color: theme.textPrimary,
            ),
          ),
          if (dua.source != null) ...[
            const SizedBox(height: 8),
            Text(
              dua.source!,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 12,
                color: theme.textDim,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
