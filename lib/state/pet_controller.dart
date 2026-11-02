import 'package:flutter/foundation.dart';

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
    notifyListeners();
  }

  Future<void> setSleepTime(String value) async {
    await repository.saveSleepTime(value);
    preferences = preferences.copyWith(sleepTime: value);
    notifyListeners();
  }

  Future<void> setWakeTime(String value) async {
    await repository.saveWakeTime(value);
    preferences = preferences.copyWith(wakeTime: value);
    notifyListeners();
  }
}
