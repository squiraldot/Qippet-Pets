import 'package:flutter_test/flutter_test.dart';
import 'package:qippet_pets/models/pet.dart';

void main() {
  test('catalog contains the three supported pets in stable order', () {
    expect(Pet.catalog.map((pet) => pet.id), ['cat', 'dog', 'bunny']);
  });

  test('frame paths use the canonical source-of-truth naming', () {
    expect(
      Pet.byId('bunny').frameAsset(PetAnimationState.tapHappy, 3),
      'assets/pets/bunny/tap_happy_03.png',
    );
  });

  test('animation metadata exposes the documented playback rates', () {
    expect(PetAnimationState.idle.framesPerSecond, 6);
    expect(PetAnimationState.tapSpin.framesPerSecond, 12);
    expect(PetAnimationState.sleeping.loops, isTrue);
    expect(PetAnimationState.wakeUp.loops, isFalse);
  });

  test('rejects frame numbers outside the five-frame sequence', () {
    expect(
      () => Pet.byId('cat').frameAsset(PetAnimationState.idle, 6),
      throwsRangeError,
    );
  });
}
