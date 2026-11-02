import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

import '../data/pet_repository.dart';
import '../models/pet.dart';

class PetController extends ChangeNotifier {
  PetController(this.repository);

  static const MethodChannel _scheduleChannel =
      MethodChannel('com.squiraldot.qippet_pets/schedule');
  static const MethodChannel _platformChannel =
      MethodChannel('com.squiraldot.qippet_pets/platform');

  final PetRepository repository;
  PetPreferences preferences = PetPreferences.defaults;
  bool isLoaded = false;
  String? alarmStatus;

  Future<void> load() async {
    preferences = await repository.load();
    isLoaded = true;
    await _syncSchedule();
    notifyListeners();
  }

  Future<void> selectPet(String petId) async {
    await repository.saveSelectedPet(petId);
    preferences = preferences.copyWith(selectedPetId: petId);
    await _refreshWidget();
    notifyListeners();
  }

  Future<void> setSleepTime(String value) async {
    await repository.saveSleepTime(value);
    preferences = preferences.copyWith(sleepTime: value);
    await _refreshWidget();
    await _syncSchedule();
    notifyListeners();
  }

  Future<void> setWakeTime(String value) async {
    await repository.saveWakeTime(value);
    preferences = preferences.copyWith(wakeTime: value);
    await _refreshWidget();
    await _syncSchedule();
    notifyListeners();
  }

  Future<void> refreshScheduleStatus() async {
    await _syncSchedule();
    notifyListeners();
  }

  Future<void> requestExactAlarmPermission() async {
    try {
      await _scheduleChannel.invokeMethod<void>('requestExactAlarmPermission');
    } on MissingPluginException {
      // Native Android scheduling is unavailable on non-Android targets.
    } on PlatformException {
      alarmStatus = 'inexact';
      notifyListeners();
    }
  }

  Future<bool> requestPinWidget() async {
    try {
      return await _platformChannel.invokeMethod<bool>('requestPinWidget') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  Future<void> openMiuiAutostartSettings() async {
    try {
      await _platformChannel.invokeMethod<bool>('openMiuiAutostartSettings');
    } on MissingPluginException {
      // Device-specific settings are only available on Android.
    } on PlatformException {
      // Keep the health screen usable if a vendor settings activity is missing.
    }
  }

  Future<void> openBatterySettings() async {
    try {
      await _platformChannel.invokeMethod<bool>('openBatterySettings');
    } on MissingPluginException {
      // Device settings are only available on Android.
    } on PlatformException {
      // Keep the health screen usable if the settings activity cannot be opened.
    }
  }

  Future<void> _syncSchedule() async {
    try {
      await _scheduleChannel.invokeMethod<String>('schedulePetAlarms');
      alarmStatus = await _scheduleChannel.invokeMethod<String>('getPetAlarmStatus');
    } on MissingPluginException {
      alarmStatus = null;
    } on PlatformException {
      alarmStatus = 'inexact';
    }
  }

  Future<void> _refreshWidget() async {
    try {
      await HomeWidget.updateWidget(androidName: 'PetWidgetProvider');
    } on MissingPluginException {
      // Flutter unit/widget tests and non-Android targets have no native widget.
    }
  }
}
