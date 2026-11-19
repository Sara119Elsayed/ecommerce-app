import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.title,
    this.hintText,
    required this.controller,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
  });

  final String title;
  final String? hintText;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: title.replaceAll('*', ''),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                if (title.contains('*'))
                  TextSpan(
                    text: ' *',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            style: Theme.of(context).textTheme.labelSmall,
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              final cleanTitle = title.replaceAll('*', '').trim().toLowerCase();
            },
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textInputAction: TextInputAction.next,
          ),
        ],
      ),
    );
  }
}
