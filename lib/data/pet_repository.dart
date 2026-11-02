import 'package:home_widget/home_widget.dart';

import '../models/pet.dart';

abstract interface class PetStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

class HomeWidgetPetStorage implements PetStorage {
  const HomeWidgetPetStorage();

  @override
  Future<String?> read(String key) => HomeWidget.getWidgetData<String>(key);

  @override
  Future<void> write(String key, String value) =>
      HomeWidget.saveWidgetData<String>(key, value);
}

class PetRepository {
  PetRepository(this.storage);

  final PetStorage storage;

  static const selectedPetIdKey = 'selectedPetId';
  static const sleepTimeKey = 'sleepTime';
  static const wakeTimeKey = 'wakeTime';

  Future<PetPreferences> load() async {
    final selected = await storage.read(selectedPetIdKey);
    final sleep = await storage.read(sleepTimeKey);
    final wake = await storage.read(wakeTimeKey);
    final validPet = Pet.catalog.any((pet) => pet.id == selected);
    return PetPreferences(
      selectedPetId: validPet ? selected! : PetPreferences.defaults.selectedPetId,
      sleepTime: _validTime(sleep) ? sleep! : PetPreferences.defaults.sleepTime,
      wakeTime: _validTime(wake) ? wake! : PetPreferences.defaults.wakeTime,
    );
  }

  Future<void> saveSelectedPet(String petId) async {
    if (!Pet.catalog.any((pet) => pet.id == petId)) {
      throw ArgumentError.value(petId, 'petId', 'Unknown pet');
    }
    await storage.write(selectedPetIdKey, petId);
  }

  Future<void> saveSleepTime(String value) async {
    _requireTime(value);
    await storage.write(sleepTimeKey, value);
  }

  Future<void> saveWakeTime(String value) async {
    _requireTime(value);
    await storage.write(wakeTimeKey, value);
  }

  static bool _validTime(String? value) =>
      value != null && RegExp(r'^(?:[01]\d|2[0-3]):[0-5]\d$').hasMatch(value);

  static void _requireTime(String value) {
    if (!_validTime(value)) {
      throw ArgumentError.value(value, 'time', 'Expected HH:mm');
    }
  }
}
