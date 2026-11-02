import 'dart:async';

import 'package:flutter/material.dart';

import 'data/pet_repository.dart';
import 'models/pet.dart';
import 'state/pet_controller.dart';

void main() => runApp(const QippetPetsApp());

class QippetPetsApp extends StatelessWidget {
  const QippetPetsApp({super.key, this.repository});

  final PetRepository? repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qippet Pets',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF79C94B),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: PetHomePage(
        controller: PetController(
          repository ?? PetRepository(const HomeWidgetPetStorage()),
        ),
      ),
    );
  }
}

class PetHomePage extends StatefulWidget {
  const PetHomePage({super.key, required this.controller});

  final PetController controller;

  @override
  State<PetHomePage> createState() => _PetHomePageState();
}

class _PetHomePageState extends State<PetHomePage> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final preferences = widget.controller.preferences;
        return Scaffold(
          appBar: AppBar(title: const Text('Qippet Pets'), centerTitle: false),
          body: SafeArea(
            child: IndexedStack(
              index: _tab,
              children: [
                PetPickerScreen(
                  selectedPetId: preferences.selectedPetId,
                  sleepTime: preferences.sleepTime,
                  wakeTime: preferences.wakeTime,
                  onSelect: widget.controller.selectPet,
                ),
                PetSettingsScreen(
                  sleepTime: preferences.sleepTime,
                  wakeTime: preferences.wakeTime,
                  onSleepChanged: widget.controller.setSleepTime,
                  onWakeChanged: widget.controller.setWakeTime,
                ),
              ],
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (value) => setState(() => _tab = value),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.pets_outlined),
                selectedIcon: Icon(Icons.pets),
                label: 'My pet',
              ),
              NavigationDestination(
                icon: Icon(Icons.schedule_outlined),
                selectedIcon: Icon(Icons.schedule),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}

class PetPickerScreen extends StatelessWidget {
  const PetPickerScreen({
    super.key,
    required this.selectedPetId,
    required this.sleepTime,
    required this.wakeTime,
    required this.onSelect,
  });

  final String selectedPetId;
  final String sleepTime;
  final String wakeTime;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final selected = Pet.byId(selectedPetId);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        Text('Your tiny companion', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text('Pick a friend. They will keep you company at home.'),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [
              PetAnimationPlayer(
                key: ValueKey(selected.id),
                pet: selected,
                sleepTime: sleepTime,
                wakeTime: wakeTime,
              ),
              const SizedBox(height: 8),
              Text(selected.name, style: Theme.of(context).textTheme.titleLarge),
              Text(selected.description),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Home screen widget setup is coming soon.')),
                ),
                icon: const Icon(Icons.add_to_home_screen),
                label: const Text('Add to Home screen'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('Choose your pet', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: Pet.catalog.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.08,
          ),
          itemBuilder: (context, index) {
            final pet = Pet.catalog[index];
            final isSelected = pet.id == selectedPetId;
            return Semantics(
              button: true,
              selected: isSelected,
              label: 'Choose ${pet.name}',
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => onSelect(pet.id),
                child: Ink(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.secondaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(22),
                    border: isSelected
                        ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 88,
                        child: PetAnimationPlayer(
                          key: ValueKey('catalog-${pet.id}'),
                          pet: pet,
                          compact: true,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(pet.name, style: Theme.of(context).textTheme.titleMedium),
                      Text(pet.description, textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall),
                      if (isSelected)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Icon(Icons.check_circle, size: 18),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class PetAnimationPlayer extends StatefulWidget {
  const PetAnimationPlayer({
    super.key,
    required this.pet,
    this.compact = false,
    this.sleepTime,
    this.wakeTime,
  });

  final Pet pet;
  final bool compact;
  final String? sleepTime;
  final String? wakeTime;

  @override
  State<PetAnimationPlayer> createState() => _PetAnimationPlayerState();
}

class _PetAnimationPlayerState extends State<PetAnimationPlayer> {
  PetAnimationState _state = PetAnimationState.idle;
  int _frame = 1;
  int _tapCount = 0;
  bool _scheduledSleep = false;
  Timer? _timer;

  bool get _hasSchedule => widget.sleepTime != null && widget.wakeTime != null;

  bool _isScheduledSleep() => _hasSchedule && PetSchedule.isSleepingAt(
        DateTime.now(),
        sleepTime: widget.sleepTime!,
        wakeTime: widget.wakeTime!,
      );

  @override
  void initState() {
    super.initState();
    _scheduledSleep = _isScheduledSleep();
    if (_scheduledSleep) _state = PetAnimationState.sleeping;
    _scheduleFrame();
  }

  void _scheduleFrame() {
    _timer?.cancel();
    _timer = Timer(
      Duration(milliseconds: 1000 ~/ _state.framesPerSecond),
      () {
        if (!mounted) return;
        setState(() {
          final scheduledSleep = _isScheduledSleep();
          if (scheduledSleep != _scheduledSleep) {
            _scheduledSleep = scheduledSleep;
            _state = scheduledSleep
                ? PetAnimationState.sleepStart
                : PetAnimationState.wakeUp;
            _frame = 1;
          } else if (_frame == 5 && !_state.loops) {
            _state = switch (_state) {
              PetAnimationState.sleepStart => PetAnimationState.sleeping,
              PetAnimationState.wakeUp => PetAnimationState.idle,
              _ => _scheduledSleep
                  ? PetAnimationState.sleeping
                  : PetAnimationState.idle,
            };
            _frame = 1;
          } else {
            _frame = _frame == 5 ? 1 : _frame + 1;
          }
        });
        _scheduleFrame();
      },
    );
  }

  void _playTap() {
    setState(() {
      _tapCount++;
      _state = _tapCount.isEven
          ? PetAnimationState.tapSpin
          : PetAnimationState.tapHappy;
      _frame = 1;
    });
    _scheduleFrame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _playTap,
      child: Image.asset(
        widget.pet.frameAsset(_state, _frame),
        width: widget.compact ? 82 : 176,
        height: widget.compact ? 82 : 176,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => Icon(
          Icons.pets,
          size: widget.compact ? 56 : 112,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class PetSettingsScreen extends StatelessWidget {
  const PetSettingsScreen({
    super.key,
    required this.sleepTime,
    required this.wakeTime,
    required this.onSleepChanged,
    required this.onWakeChanged,
  });

  final String sleepTime;
  final String wakeTime;
  final ValueChanged<String> onSleepChanged;
  final ValueChanged<String> onWakeChanged;

  TimeOfDay _parse(String value) {
    final parts = value.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> _pick(BuildContext context, String value, ValueChanged<String> save) async {
    final picked = await showTimePicker(context: context, initialTime: _parse(value));
    if (picked != null) {
      save('${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Daily routine', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text('Choose when your pet should wind down and wake up.'),
        const SizedBox(height: 20),
        Card(
          child: ListTile(
            leading: const Icon(Icons.bedtime_outlined),
            title: const Text('Sleep time'),
            subtitle: const Text('Your pet goes to sleep'),
            trailing: TextButton(
              onPressed: () => _pick(context, sleepTime, onSleepChanged),
              child: Text(sleepTime),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.wb_sunny_outlined),
            title: const Text('Wake time'),
            subtitle: const Text('Your pet wakes up'),
            trailing: TextButton(
              onPressed: () => _pick(context, wakeTime, onWakeChanged),
              child: Text(wakeTime),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Schedule-based sleep and wake animations will be connected to the home-screen widget in a later step.',
        ),
      ],
    );
  }
}
