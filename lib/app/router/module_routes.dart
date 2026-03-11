import 'package:flutter/material.dart';

class ModuleRoutes {
  static const String smoking = '/modules/smoking';
  static const String bingeEating = '/modules/binge-eating';
  static const String diet = '/modules/diet';
  static const String spending = '/modules/spending';
  static const String focus = '/modules/focus';
  static const String adultContent = '/modules/adult-content';
  static const String moneySavingChallenge = '/modules/money-saving-challenge';
  static const String procrastination = '/modules/procrastination';
  static const String reading = '/modules/reading';

  static Map<String, Widget Function(BuildContext)> get routes => {
    smoking: (context) => throw UnimplementedError('Smoking module screen not implemented'),
    bingeEating: (context) => throw UnimplementedError('Binge eating module screen not implemented'),
    diet: (context) => throw UnimplementedError('Diet module screen not implemented'),
    spending: (context) => throw UnimplementedError('Spending module screen not implemented'),
    focus: (context) => throw UnimplementedError('Focus module screen not implemented'),
    adultContent: (context) => throw UnimplementedError('Adult content module screen not implemented'),
    moneySavingChallenge: (context) => throw UnimplementedError('Money saving challenge module screen not implemented'),
    procrastination: (context) => throw UnimplementedError('Procrastination module screen not implemented'),
    reading: (context) => throw UnimplementedError('Reading module screen not implemented'),
  };
}
