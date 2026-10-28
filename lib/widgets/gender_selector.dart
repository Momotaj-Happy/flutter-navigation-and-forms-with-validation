import 'package:flutter/material.dart';

class GenderSelector extends StatelessWidget {
  final String? selectedGender;
  final ValueChanged<String?> onChanged;

  const GenderSelector({
    Key? key,
    required this.selectedGender,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: (v) => selectedGender == null ? 'Please select your gender' : null,
      builder: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Gender', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Row(
            children: ['Male', 'Female', 'Other'].map((gender) {
              return Expanded(
                child: Row(
                  children: [
                    Radio<String>(
                      value: gender,
                      groupValue: selectedGender,
                      onChanged: (val) {
                        onChanged(val);
                        state.didChange(val);
                      },
                    ),
                    Text(gender),
                  ],
                ),
              );
            }).toList(),
          ),
          if (state.hasError)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
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