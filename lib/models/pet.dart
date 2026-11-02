enum PetAnimationState {
  idle,
  tapHappy,
  tapSpin,
  sleepStart,
  sleeping,
  wakeUp;

  String get assetName => switch (this) {
        PetAnimationState.idle => 'idle',
        PetAnimationState.tapHappy => 'tap_happy',
        PetAnimationState.tapSpin => 'tap_spin',
        PetAnimationState.sleepStart => 'sleep_start',
        PetAnimationState.sleeping => 'sleeping',
        PetAnimationState.wakeUp => 'wake_up',
      };

  int get framesPerSecond => switch (this) {
        PetAnimationState.idle => 6,
        PetAnimationState.tapHappy => 10,
        PetAnimationState.tapSpin => 12,
        PetAnimationState.sleepStart => 8,
        PetAnimationState.sleeping => 3,
        PetAnimationState.wakeUp => 8,
      };

  bool get loops => this == PetAnimationState.idle ||
      this == PetAnimationState.sleeping;
}

class Pet {
  const Pet({required this.id, required this.name, required this.description});

  final String id;
  final String name;
  final String description;

  String frameAsset(PetAnimationState state, int frame) {
    if (frame < 1 || frame > 5) {
      throw RangeError.range(frame, 1, 5, 'frame');
    }
    return 'assets/pets/$id/${state.assetName}_${frame.toString().padLeft(2, '0')}.png';
  }

  static const catalog = <Pet>[
    Pet(id: 'cat', name: 'Mochi', description: 'A curious little cat'),
    Pet(id: 'dog', name: 'Biscuit', description: 'Your loyal happy pup'),
    Pet(id: 'bunny', name: 'Clover', description: 'A gentle fluffy bunny'),
  ];

  static Pet byId(String? id) =>
      catalog.firstWhere((pet) => pet.id == id, orElse: () => catalog.first);
}

class PetPreferences {
  const PetPreferences({
    required this.selectedPetId,
    required this.sleepTime,
    required this.wakeTime,
  });

  final String selectedPetId;
  final String sleepTime;
  final String wakeTime;

  Pet get selectedPet => Pet.byId(selectedPetId);

  PetPreferences copyWith({
    String? selectedPetId,
    String? sleepTime,
    String? wakeTime,
  }) =>
      PetPreferences(
        selectedPetId: selectedPetId ?? this.selectedPetId,
        sleepTime: sleepTime ?? this.sleepTime,
        wakeTime: wakeTime ?? this.wakeTime,
      );

  static const defaults = PetPreferences(
    selectedPetId: 'cat',
    sleepTime: '22:00',
    wakeTime: '07:00',
  );
}
