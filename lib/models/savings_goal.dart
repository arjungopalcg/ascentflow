import 'package:flutter/material.dart';

class SavingsGoal {
  final String id;
  String title;
  double current;
  double target;
  Color color;
  String currency;
  String currencySymbol;

  SavingsGoal({
    required this.id,
    required this.title,
    required this.current,
    required this.target,
    required this.color,
    this.currency = 'USD',
    this.currencySymbol = '\$',
  });
}
