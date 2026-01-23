import 'package:librisys/constants/constants.dart';
import 'package:librisys/pages/home_page.dart';
import 'package:librisys/pages/profile_page.dart';
import 'package:librisys/widgets/nav_bar.dart';
import 'package:flutter/material.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  List<Widget> pageList = [HomePage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appName)),
      body: ValueListenableBuilder(
        valueListenable: selectedPageNotifier,
        builder: (context, value, child) {
          return pageList[value];
        },
      ),
      bottomNavigationBar: NavBar(),
    );
  }
}
