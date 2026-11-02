import 'package:flutter_test/flutter_test.dart';
import 'package:qippet_pets/data/pet_repository.dart';
import 'package:qippet_pets/models/pet.dart';

class MemoryPetStorage implements PetStorage {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }
}

void main() {
  late MemoryPetStorage storage;
  late PetRepository repository;

  setUp(() {
    storage = MemoryPetStorage();
    repository = PetRepository(storage);
  });

  test('loads defaults when no preferences have been saved', () async {
    expect(await repository.load(), PetPreferences.defaults);
  });

  test('persists and reloads pet selection and schedule values', () async {
    await repository.saveSelectedPet('bunny');
    await repository.saveSleepTime('21:45');
    await repository.saveWakeTime('06:30');

    final result = await repository.load();
    expect(result.selectedPetId, 'bunny');
    expect(result.sleepTime, '21:45');
    expect(result.wakeTime, '06:30');
  });

  test('falls back to defaults for invalid stored values', () async {
    storage.values[PetRepository.selectedPetIdKey] = 'dragon';
    storage.values[PetRepository.sleepTimeKey] = '25:90';

    final result = await repository.load();
    expect(result.selectedPetId, 'cat');
    expect(result.sleepTime, '22:00');
  });

  test('rejects unknown pets and malformed times', () async {
    await expectLater(repository.saveSelectedPet('dragon'), throwsArgumentError);
    await expectLater(repository.saveSleepTime('9pm'), throwsArgumentError);
    await expectLater(repository.saveWakeTime('24:00'), throwsArgumentError);
  });
}
