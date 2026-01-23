import 'package:flutter/material.dart';

const String appName = "Librisys";

ValueNotifier<int> selectedPageNotifier = ValueNotifier<int>(0);

class KTextStyleTitle {
  static const TextStyle pageTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
}
