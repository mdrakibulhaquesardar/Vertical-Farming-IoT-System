import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../dashboard/views/dashboard_view.dart';
import '../../control/views/control_view.dart';
import '../../scanner/views/scanner_view.dart';
import '../../graphs/views/graphs_view.dart';
import '../../notifications/views/notifications_view.dart';
import '../../../controllers/main_controller.dart';

class MainNavView extends GetView<MainController> {
  const MainNavView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final PersistentTabController tabController = PersistentTabController(
      initialIndex: 0,
    );
    return PersistentTabView(
      tabs: [
        PersistentTabConfig(
          screen: const DashboardView(),
          item: ItemConfig(
            icon: const Icon(MaterialCommunityIcons.view_dashboard_outline),
            title: "Dashboard",
          ),
        ),
        PersistentTabConfig(
          screen: const ControlView(),
          item: ItemConfig(
            icon: const Icon(MaterialCommunityIcons.tune),
            title: "Control",
          ),
        ),
        PersistentTabConfig(
          screen: const ScannerView(),
          item: ItemConfig(
            icon: const Icon(MaterialCommunityIcons.camera_outline),
            title: "Scanner",
          ),
        ),
        PersistentTabConfig(
          screen: const GraphsView(),
          item: ItemConfig(
            icon: const Icon(MaterialCommunityIcons.chart_line),
            title: "Graphs",
          ),
        ),
      ],
      navBarBuilder: (navBarConfig) =>
          Style2BottomNavBar(navBarConfig: navBarConfig, height: 60),
      controller: tabController,
      backgroundColor: theme.colorScheme.background,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      margin: const EdgeInsets.all(0),
    );
  }
}
