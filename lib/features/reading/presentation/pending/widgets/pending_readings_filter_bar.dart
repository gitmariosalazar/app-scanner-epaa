// lib/features/reading/presentation/pending/widgets/pending_readings_filter_bar.dart
import 'package:flutter/material.dart';

class PendingReadingsFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedMonth;
  final int? selectedSector;
  final List<int> availableSectors;
  final int totalCount;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onSelectMonth;
  final ValueChanged<int?> onSelectSector;

  const PendingReadingsFilterBar({
    super.key,
    required this.searchController,
    required this.selectedMonth,
    required this.selectedSector,
    required this.availableSectors,
    required this.totalCount,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onSelectMonth,
    required this.onSelectSector,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Fila de Buscador + Botón Selector de Mes ──
          Row(
            children: [
              // Campo de búsqueda
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: TextField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Buscar por clave, cliente, medidor...',
                      hintStyle: TextStyle(
                        fontSize: 12.5,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: cs.onSurfaceVariant,
                      ),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: onClearSearch,
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      filled: true,
                      fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Botón selector de mes
              InkWell(
                onTap: onSelectMonth,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        size: 18,
                        color: cs.onPrimaryContainer,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        selectedMonth,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Fila de Chips de Sectores & Contador ──
          Row(
            children: [
              // Lista horizontal de sectores
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // Chip 'Todos'
                      _FilterChipItem(
                        label: 'Todos',
                        isSelected: selectedSector == null,
                        onTap: () => onSelectSector(null),
                      ),
                      const SizedBox(width: 6),
                      // Chips de sectores disponibles (o por defecto 1..10 si aún no hay)
                      ..._buildSectorChips(),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Badge de total
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.errorContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$totalCount pend.',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: cs.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSectorChips() {
    final sectors = availableSectors.isNotEmpty
        ? availableSectors
        : List.generate(10, (i) => i + 1);

    return sectors.map((sec) {
      final isSelected = selectedSector == sec;
      return Padding(
        padding: const EdgeInsets.only(right: 6),
        child: _FilterChipItem(
          label: 'Sec $sec',
          isSelected: isSelected,
          onTap: () => onSelectSector(sec),
        ),
      );
    }).toList();
  }
}

class _FilterChipItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChipItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.primary
              : cs.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : cs.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
