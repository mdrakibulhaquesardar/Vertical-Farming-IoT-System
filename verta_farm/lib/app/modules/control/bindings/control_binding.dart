import 'package:get/get.dart';
import '../controllers/control_controller.dart';

class ControlBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ControlController>(() => ControlController());
  }
}
