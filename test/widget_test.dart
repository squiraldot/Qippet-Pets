import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qippet_pets/data/pet_repository.dart';
import 'package:qippet_pets/main.dart';

class FakePetStorage implements PetStorage {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }
}

void main() {
  testWidgets('picker renders all pets and the add-to-home action', (tester) async {
    final storage = FakePetStorage();
    await tester.pumpWidget(
      QippetPetsApp(repository: PetRepository(storage)),
    );
    await tester.pump();

    expect(find.text('Your tiny companion'), findsOneWidget);
    expect(find.text('Mochi'), findsNWidgets(2));
    expect(find.text('Biscuit'), findsOneWidget);
    expect(find.text('Clover'), findsOneWidget);
    expect(find.text('Add to Home screen'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('selecting a pet persists its id and updates the preview', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final storage = FakePetStorage();
    await tester.pumpWidget(
      QippetPetsApp(repository: PetRepository(storage)),
    );
    await tester.pump();

    await tester.tap(find.text('Biscuit'));
    await tester.pump();

    expect(storage.values[PetRepository.selectedPetIdKey], 'dog');
    expect(find.text('Your loyal happy pup'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('settings screen exposes sleep and wake time controls', (tester) async {
    final storage = FakePetStorage();
    await tester.pumpWidget(
      QippetPetsApp(repository: PetRepository(storage)),
    );
    await tester.pump();
    await tester.tap(find.text('Settings'));
    await tester.pump();

    expect(find.text('Sleep time'), findsOneWidget);
    expect(find.text('Wake time'), findsOneWidget);
    expect(find.text('22:00'), findsOneWidget);
    expect(find.text('07:00'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('unsupported launcher shows manual widget setup instructions', (tester) async {
    const channel = MethodChannel('com.squiraldot.qippet_pets/platform');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (call) async => false,
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null),
    );

    await tester.pumpWidget(
      QippetPetsApp(repository: PetRepository(FakePetStorage())),
    );
    await tester.pump();

    await tester.tap(find.text('Add to Home screen'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Add Qippet Pets manually'), findsOneWidget);
    expect(find.text('Choose Widgets (or Add widgets).'), findsOneWidget);
    expect(find.textContaining('drag it onto your home screen'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('device health screen explains Xiaomi battery and autostart setup', (tester) async {
    await tester.pumpWidget(
      QippetPetsApp(repository: PetRepository(FakePetStorage())),
    );
    await tester.pump();
    await tester.tap(find.text('Settings'));
    await tester.pump();

    expect(find.text('Device health & routine'), findsOneWidget);
    expect(find.text('Open Autostart settings'), findsOneWidget);
    expect(find.text('Open battery settings'), findsOneWidget);
    expect(find.textContaining('No restrictions'), findsOneWidget);
    expect(find.text('Allow exact alarms'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
