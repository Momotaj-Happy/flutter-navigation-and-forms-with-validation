import 'package:flutter/material.dart';

class InterestsSelector extends StatelessWidget {
  final List<String> available;
  final List<String> selected;
  final VoidCallback onSelectionChanged;

  const InterestsSelector({
    Key? key,
    required this.available,
    required this.selected,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormField<List<String>>(
      validator: (v) => selected.isEmpty ? 'Select at least one interest' : null,
      builder: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Interests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: available.map((item) {
              final isChecked = selected.contains(item);
              return FilterChip(
                label: Text(item),
                selected: isChecked,
                onSelected: (val) {
                  val ? selected.add(item) : selected.remove(item);
                  onSelectionChanged();
                  state.didChange(selected);
                },
              );
            }).toList(),
          ),
          if (state.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 8),
              child: Text(
                state.errorText!,
                style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}