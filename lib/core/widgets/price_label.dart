import 'package:flutter/material.dart';

import '../utils/currency_formatter.dart';

class PriceLabel extends StatelessWidget {
  const PriceLabel(
    this.price, {
    super.key,
    this.style,
  });

  final double price;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      CurrencyFormatter.format(price),
      style: style ??
          theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
    );
  }
}
