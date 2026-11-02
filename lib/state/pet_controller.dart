import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

import '../data/pet_repository.dart';
import '../models/pet.dart';

class PetController extends ChangeNotifier {
  PetController(this.repository);

  final PetRepository repository;
  PetPreferences preferences = PetPreferences.defaults;
  bool isLoaded = false;

  Future<void> load() async {
    preferences = await repository.load();
    isLoaded = true;
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
    notifyListeners();
  }

  Future<void> setWakeTime(String value) async {
    await repository.saveWakeTime(value);
    preferences = preferences.copyWith(wakeTime: value);
    await _refreshWidget();
    notifyListeners();
  }

  Future<void> _refreshWidget() async {
    try {
      await HomeWidget.updateWidget(androidName: 'PetWidgetProvider');
    } on MissingPluginException {
      // Flutter unit/widget tests and non-Android targets have no native widget.
    }
  }
}
