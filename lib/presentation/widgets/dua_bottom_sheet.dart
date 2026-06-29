
import 'package:flutter/material.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/services/dua_service.dart';
import 'package:ramadan_assistant/core/di/service_locator.dart';
import 'package:ramadan_assistant/data/models/dua_model.dart';
import 'package:ramadan_assistant/presentation/widgets/dua_widget.dart';

class DuaBottomSheet extends StatefulWidget {
  final String? initialCategory;

  const DuaBottomSheet({super.key, this.initialCategory});

  static Future<void> show(BuildContext context, {String? initialCategory}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DuaBottomSheet(initialCategory: initialCategory),
    );
  }

  @override
  State<DuaBottomSheet> createState() => _DuaBottomSheetState();
}

class _DuaBottomSheetState extends State<DuaBottomSheet> {
  late List<Dua> _filteredDuas;
  String _searchQuery = '';
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _updateDuas();
  }

  void _updateDuas() {
    final service = sl<DuaService>();
    if (_searchQuery.isNotEmpty) {
      _filteredDuas = service.search(_searchQuery);
    } else if (_selectedCategory != null) {
      _filteredDuas = service.getByCategory(_selectedCategory!);
    } else {
      _filteredDuas = service.allDuas;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.ramadanTheme;
    final categories = sl<DuaService>().categories;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'adhkar_title'.tr(),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.primary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'search_hint'.tr(),
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                          _updateDuas();
                        });
                      },
                    )
                  : null,
                filled: true,
                fillColor: theme.primary.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _updateDuas();
                });
              },
            ),
          ),

          // Categories Horizontal List
          if (_searchQuery.isEmpty)
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length + 1,
                itemBuilder: (context, index) {
                  final category = index == 0 ? null : categories[index - 1];
                  final label = index == 0 ? 'all'.tr() : category!;
                  final isSelected = _selectedCategory == category;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? category : null;
                          _updateDuas();
                        });
                      },
                      selectedColor: theme.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : theme.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: theme.primary.withValues(alpha: 0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide.none,
                      ),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 10),

          // Duas List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _filteredDuas.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final dua = _filteredDuas[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedCategory == null && _searchQuery.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, left: 4),
                        child: Text(
                          dua.category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.secondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    DuaWidget(
                      arabicText: dua.arabic,
                      translation: dua.translation ?? '',
                    ),
                    if (dua.source != null && dua.source!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 12),
                        child: Text(
                          dua.source!,
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.textSecondary.withValues(alpha: 0.7),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
