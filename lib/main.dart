import 'dart:async';

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

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

class _PetHomePageState extends State<PetHomePage> with WidgetsBindingObserver {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.controller.load();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.controller.refreshScheduleStatus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
                  onAddWidget: widget.controller.requestPinWidget,
                ),
                PetSettingsScreen(
                  sleepTime: preferences.sleepTime,
                  wakeTime: preferences.wakeTime,
                  onSleepChanged: widget.controller.setSleepTime,
                  onWakeChanged: widget.controller.setWakeTime,
                  alarmStatus: widget.controller.alarmStatus,
                  onRequestExactAlarm: widget.controller.requestExactAlarmPermission,
                  onOpenAutostart: widget.controller.openMiuiAutostartSettings,
                  onOpenBatterySettings: widget.controller.openBatterySettings,
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
    required this.onAddWidget,
  });

  final String selectedPetId;
  final String sleepTime;
  final String wakeTime;
  final ValueChanged<String> onSelect;
  final Future<bool> Function() onAddWidget;

  Future<void> _addWidget(BuildContext context) async {
    final pinned = await onAddWidget();
    if (!context.mounted || pinned) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ManualWidgetHelpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = Pet.byId(selectedPetId);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        Text('Your tiny companion', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        const Text('Pick a friend. They will keep you company at home.'),
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
                onPressed: () => _addWidget(context),
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
    required this.alarmStatus,
    required this.onRequestExactAlarm,
    required this.onOpenAutostart,
    required this.onOpenBatterySettings,
  });

  final String sleepTime;
  final String wakeTime;
  final ValueChanged<String> onSleepChanged;
  final ValueChanged<String> onWakeChanged;
  final String? alarmStatus;
  final VoidCallback onRequestExactAlarm;
  final VoidCallback onOpenAutostart;
  final VoidCallback onOpenBatterySettings;

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
        Text('Device health & routine', style: Theme.of(context).textTheme.headlineSmall),
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
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      alarmStatus == 'exact'
                          ? Icons.alarm_on
                          : alarmStatus == 'inexact'
                              ? Icons.alarm
                              : Icons.info_outline,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        alarmStatus == 'exact'
                            ? 'Precise schedule is active'
                            : alarmStatus == 'inexact'
                                ? 'Precise alarm access is unavailable'
                                : alarmStatus == 'disabled'
                                    ? 'Automatic transitions are disabled'
                                    : 'Schedule status unavailable',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  alarmStatus == 'exact'
                      ? 'Your pet will transition at the scheduled sleep and wake times.'
                      : alarmStatus == 'inexact'
                          ? 'Android is using battery-friendly inexact alarms, so transitions may happen later than selected.'
                          : alarmStatus == 'disabled'
                              ? 'Choose different sleep and wake times to enable automatic transitions.'
                              : 'Open this screen again to refresh alarm availability.',
                ),
                if (alarmStatus != 'disabled') ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: onRequestExactAlarm,
                    icon: const Icon(Icons.settings),
                    label: Text(alarmStatus == 'exact'
                        ? 'Manage exact-alarm access'
                        : 'Allow exact alarms'),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Keep Qippet Pets running', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                const Text(
                  'On Xiaomi, Redmi and POCO devices running MIUI or HyperOS, enable Autostart for Qippet Pets and set Battery saver to No restrictions. Menu names can vary by system version.',
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: onOpenAutostart,
                  icon: const Icon(Icons.autorenew),
                  label: const Text('Open Autostart settings'),
                ),
                OutlinedButton.icon(
                  onPressed: onOpenBatterySettings,
                  icon: const Icon(Icons.battery_full),
                  label: const Text('Open battery settings'),
                ),
                const SizedBox(height: 4),
                const Text(
                  'If the device opens App info, choose Autostart and enable it. Then open Battery saver and select No restrictions.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'The home-screen pet widget refreshes whenever you change your pet or sleep schedule.',
        ),
      ],
    );
  }
}


class ManualWidgetHelpScreen extends StatelessWidget {
  const ManualWidgetHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add your pet widget')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          Icon(Icons.widgets_outlined, size: 64),
          SizedBox(height: 20),
          Text('Add Qippet Pets manually', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('Your launcher does not support the one-tap widget pin request. You can still add the widget from the home screen:'),
          SizedBox(height: 16),
          ListTile(leading: CircleAvatar(child: Text('1')), title: Text('Touch and hold an empty area on your home screen.')),
          ListTile(leading: CircleAvatar(child: Text('2')), title: Text('Choose Widgets (or Add widgets).')),
          ListTile(leading: CircleAvatar(child: Text('3')), title: Text('Find Qippet Pets in the widget list.')),
          ListTile(leading: CircleAvatar(child: Text('4')), title: Text('Touch and hold the pet widget, then drag it onto your home screen.')),
          SizedBox(height: 12),
          Text('If Qippet Pets is not listed, reopen the app once and check the Widgets list again.'),
        ],
      ),
    );
  }
}
