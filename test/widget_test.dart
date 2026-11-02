import 'package:flutter_test/flutter_test.dart';
import 'package:qippet_pets/main.dart';

void main() {
  testWidgets('shows the Qippet Pets starter screen', (tester) async {
    await tester.pumpWidget(const QippetPetsApp());

    expect(find.text('Qippet Pets'), findsOneWidget);
    expect(
      find.text('Your little companion is coming soon.'),
      findsOneWidget,
    );
    expect(
      find.text('Choose a pet and bring it to your Android home screen.'),
      findsOneWidget,
    );
  });
}
