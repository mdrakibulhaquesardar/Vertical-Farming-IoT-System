import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ControlService extends GetxService {
  static ControlService get to => Get.find();

  final String baseUrl = 'http://192.168.0.134:8000/api/v1';
  var isControlling = false.obs;
  var isControllingLight = false.obs;
  var isControllingPump = false.obs;
  var isControllingMotor = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<bool> controlDevice(
    String deviceId,
    String target,
    String desiredState,
  ) async {
    try {
      isControlling.value = true;

      final url = Uri.parse('$baseUrl/control/$deviceId');
      print('Sending control command to: $url');

      final body = {'target': target, 'desired_state': desiredState};

      print('Control command body: $body');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        final data = json.decode(response.body);
        print('Control API response: $data');

        Fluttertoast.showToast(
          msg: '$target turned ${desiredState.toUpperCase()}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        return true;
      } else {
        print(
          'Failed to control device: ${response.statusCode} - ${response.body}',
        );

        Fluttertoast.showToast(
          msg: 'Failed to control $target: ${response.statusCode}',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );

        return false;
      }
    } catch (e) {
      print('Error controlling device: $e');

      Fluttertoast.showToast(
        msg: 'Failed to control $target: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );

      return false;
    } finally {
      isControlling.value = false;
    }
  }

  // Specific control methods
  Future<bool> controlLight(String deviceId, bool turnOn) async {
    try {
      isControllingLight.value = true;
      print(
        'Controlling light: ${turnOn ? 'ON' : 'OFF'} for device: $deviceId',
      );
      final result = await controlDevice(
        deviceId,
        'light',
        turnOn ? 'on' : 'off',
      );
      return result;
    } finally {
      isControllingLight.value = false;
    }
  }

  Future<bool> controlPump(String deviceId, bool turnOn) async {
    try {
      isControllingPump.value = true;
      print('Controlling pump: ${turnOn ? 'ON' : 'OFF'} for device: $deviceId');
      final result = await controlDevice(
        deviceId,
        'relay',
        turnOn ? 'on' : 'off',
      );
      return result;
    } finally {
      isControllingPump.value = false;
    }
  }

  Future<bool> controlVentilation(String deviceId, bool turnOn) async {
    print(
      'Controlling ventilation: ${turnOn ? 'ON' : 'OFF'} for device: $deviceId',
    );
    return await controlDevice(deviceId, 'ventilation', turnOn ? 'on' : 'off');
  }

  Future<bool> controlMotor(String deviceId, bool turnOn) async {
    try {
      isControllingMotor.value = true;
      print(
        'Controlling motor: ${turnOn ? 'ON' : 'OFF'} for device: $deviceId',
      );
      final result = await controlDevice(
        deviceId,
        'motor',
        turnOn ? 'on' : 'off',
      );
      return result;
    } finally {
      isControllingMotor.value = false;
    }
  }

  Future<bool> controlRelay(String deviceId, bool turnOn) async {
    print('Controlling relay: ${turnOn ? 'ON' : 'OFF'} for device: $deviceId');
    return await controlDevice(deviceId, 'relay', turnOn ? 'on' : 'off');
  }

  Future<bool> requestStatus(String deviceId) async {
    try {
      print('Requesting status for device: $deviceId');
      final result = await controlDevice(deviceId, 'status', 'request');
      return result;
    } catch (e) {
      print('Error requesting status: $e');
      return false;
    }
  }
}
