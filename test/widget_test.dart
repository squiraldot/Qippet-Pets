import 'package:flutter/material.dart';
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
  testWidgets('picker renders all pets and the add-to-home placeholder', (tester) async {
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
    final storage = FakePetStorage();
    await tester.pumpWidget(
      QippetPetsApp(repository: PetRepository(storage)),
    );
    await tester.pump();

    final biscuitCard = find.text('Biscuit');
    await tester.ensureVisible(biscuitCard);
    await tester.pump();
    await tester.tap(biscuitCard);
    await tester.pump();

    expect(storage.values[PetRepository.selectedPetIdKey], 'dog');
    expect(find.text('Your loyal happy pup'), findsNWidgets(2));

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
}
