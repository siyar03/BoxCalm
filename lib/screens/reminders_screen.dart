import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/reminder.dart';
import '../providers/reminders_provider.dart';
import '../widgets/common/aurora_background.dart';
import '../widgets/common/glass_card.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  Future<void> _editReminder(BuildContext context, [Reminder? reminder]) async {
    final provider = context.read<RemindersProvider>();
    var hour = reminder?.hour ?? 20;
    var minute = reminder?.minute ?? 30;
    var weekdays = reminder != null ? [...reminder.weekdays] : [0, 1, 2, 3, 4, 5, 6];
    var label = reminder?.label ?? 'Time to breathe';

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0D1A27),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reminder == null ? 'Add reminder' : 'Edit reminder',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 18),
              TextField(
                controller: TextEditingController(text: label),
                onChanged: (v) => label = v,
                decoration: const InputDecoration(labelText: 'Label'),
              ),
              const SizedBox(height: 18),
              Center(
                child: TextButton.icon(
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(hour: hour, minute: minute),
                    );
                    if (time != null) {
                      setState(() {
                        hour = time.hour;
                        minute = time.minute;
                      });
                    }
                  },
                  icon: const Icon(Icons.access_time_rounded),
                  label: Text(
                    TimeOfDay(hour: hour, minute: minute).format(context),
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text('Repeat on', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < 7; i++)
                    ChoiceChip(
                      label: Text(weekdayShort[i]),
                      selected: weekdays.contains(i),
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            weekdays.add(i);
                          } else {
                            weekdays.remove(i);
                          }
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  if (weekdays.isEmpty) return;
                  final item = Reminder(
                    id: reminder?.id ??
                        'reminder_${DateTime.now().millisecondsSinceEpoch}',
                    hour: hour,
                    minute: minute,
                    weekdays: weekdays,
                    label: label.isEmpty ? 'Time to breathe' : label,
                  );
                  if (reminder == null) {
                    provider.add(item);
                  } else {
                    provider.update(item);
                  }
                  Navigator.pop(context, true);
                },
                child: const Text('Save reminder'),
              ),
            ],
          ),
        ),
      ),
    );

    if (saved == true && context.mounted) {
      await provider.requestPermissions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RemindersProvider>();
    final list = provider.reminders;

    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editReminder(context),
        child: const Icon(Icons.add_rounded),
      ),
      body: AuroraBackground(
        child: SafeArea(
          child: list.isEmpty
              ? const Center(
                  child: EmptyState(
                    icon: Icons.notifications_off_outlined,
                    title: 'No reminders set',
                    message: 'Tap + to add a daily breathing reminder.',
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final r = list[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r.formattedTime,
                                    style: const TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    r.daysLabel,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: r.enabled,
                              onChanged: (val) => provider.toggle(r, val),
                            ),
                            IconButton(
                              onPressed: () => _editReminder(context, r),
                              icon: const Icon(Icons.edit_outlined, size: 20),
                            ),
                            IconButton(
                              onPressed: () => provider.delete(r),
                              icon: const Icon(Icons.delete_outline_rounded, size: 20),
                              color: Colors.red.shade300,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
