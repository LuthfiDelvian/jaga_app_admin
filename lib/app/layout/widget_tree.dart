import 'package:flutter/material.dart';
import 'package:jaga_app/app/layout/custom_app_bar.dart';
import 'package:jaga_app/app/layout/navigation_config.dart';
import 'package:jaga_app/app/widgets/bottom_navbar_widget.dart';
import 'package:jaga_app/core/notifiers/notifiers.dart';

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, _) {
        return Scaffold(
          appBar: buildCustomAppBar(context, selectedPage),
          body: appPages[selectedPage],
          bottomNavigationBar: const NavbarWidget(),
        );
      },
    );
  }
}