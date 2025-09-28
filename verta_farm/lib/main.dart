import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app/routes/app_pages.dart';
import 'app/controllers/main_controller.dart';
import 'app/modules/dashboard/controllers/dashboard_controller.dart';
import 'app/modules/control/controllers/control_controller.dart';
import 'app/modules/scanner/controllers/scanner_controller.dart';
import 'app/modules/graphs/controllers/graphs_controller.dart';
import 'app/core/theme.dart';

void main() {
  // Initialize all controllers
  Get.put(MainController());
  Get.put(DashboardController());
  Get.put(ControlController());
  Get.put(ScannerController());
  Get.put(GraphsController());

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Verta Farm",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: AppTheme.light,
    ),
  );
}
