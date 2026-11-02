import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

import '../data/pet_repository.dart';
import '../models/pet.dart';

class PetController extends ChangeNotifier {
  PetController(this.repository);

  static const MethodChannel _scheduleChannel =
      MethodChannel('com.squiraldot.qippet_pets/schedule');

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

  Future<void> _syncSchedule() async {
    try {
      alarmStatus = await _scheduleChannel.invokeMethod<String>('schedulePetAlarms');
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
