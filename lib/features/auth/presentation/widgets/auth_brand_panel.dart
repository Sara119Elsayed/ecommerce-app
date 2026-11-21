import 'package:flutter/material.dart';

class AuthBrandPanel extends StatelessWidget {
  const AuthBrandPanel({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final content = Column(
      mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
      crossAxisAlignment: compact
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            Icons.shopping_bag_outlined,
            color: colorScheme.primary,
            size: 28,
          ),
        ),
        SizedBox(height: compact ? 20 : 32),
        Text(
          'Everyday Shop',
          textAlign: compact ? TextAlign.center : TextAlign.start,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: const Color(0xFF1E3029),
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Good finds, made simple.',
          textAlign: compact ? TextAlign.center : TextAlign.start,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF68766F),
            height: 1.5,
          ),
        ),
      ],
    );

    if (compact) return content;

    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F0EA),
        borderRadius: BorderRadius.circular(32),
      ),
      child: content,
    );
  }
}
