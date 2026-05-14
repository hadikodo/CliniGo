import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart' as sf;
import '../../../core/constants/theme.dart';
import '../providers/appointment_provider.dart';
import '../../patient_management/providers/patient_provider.dart';
import '../../../shared/models/appointment.dart' as model;

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  sf.CalendarView _calendarView = sf.CalendarView.day;

  @override
  Widget build(BuildContext context) {
    final appointmentsAsync = ref.watch(appointmentsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAppointmentSheet(context, ref),
        backgroundColor: const Color(0xFF0F172A),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack),
      body: Column(
        children: [
          _DominoControlBar(appointments: appointmentsAsync.value ?? []),
          _ViewToggle(
            current: _calendarView,
            onChanged: (v) => setState(() => _calendarView = v),
          ),
          Expanded(
            child: appointmentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (appointments) => sf.SfCalendar(
                view: _calendarView,
                dataSource: _AppointmentDataSource(appointments),
                initialDisplayDate: DateTime.now(),
                headerHeight: 0,
                todayHighlightColor: CliniGoTheme.primaryColor,
                selectionDecoration: BoxDecoration(
                  color: CliniGoTheme.primaryColor.withValues(alpha: 0.05),
                  border: Border.all(color: CliniGoTheme.primaryColor, width: 1),
                ),
                timeSlotViewSettings: sf.TimeSlotViewSettings(
                  startHour: 7,
                  endHour: 21,
                  timeIntervalHeight: 70,
                  timeTextStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w700),
                  dayFormat: 'EEE',
                ),
                appointmentBuilder: (ctx, details) {
                  final appt = details.appointments.first as _CalendarEntry;
                  return _AppointmentCard(entry: appt).animate().fadeIn().scale(duration: 300.ms);
                },
                onTap: (details) {
                  if (details.appointments == null || details.appointments!.isEmpty) return;
                  final entry = details.appointments!.first as _CalendarEntry;
                  _showAppointmentActions(context, ref, entry.source);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAppointmentSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddAppointmentSheet(ref: ref),
    );
  }

  void _showAppointmentActions(BuildContext context, WidgetRef ref, model.Appointment appt) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _AppointmentActionsSheet(appointment: appt, ref: ref),
    );
  }
}

class _DominoControlBar extends ConsumerWidget {
  final List<model.Appointment> appointments;
  const _DominoControlBar({required this.appointments});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isProcessing = ref.watch(appointmentControllerProvider).isLoading;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: CliniGoTheme.accentColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 16),
              ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds, color: Colors.white30),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DOMINO ENGINE ACTIVE',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                  Text(
                    'Real-time latency orchestration',
                    style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const Spacer(),
              if (isProcessing)
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white38))
              else
                Text(
                  '${appointments.length} Slots',
                  style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w800),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _DominoActionChip(label: '+15m', icon: Icons.timer_outlined, onTap: () => _delay(context, ref, 15)),
                const SizedBox(width: 10),
                _DominoActionChip(label: '+30m', icon: Icons.timer_outlined, onTap: () => _delay(context, ref, 30)),
                const SizedBox(width: 10),
                _DominoActionChip(label: '+60m', icon: Icons.timer_outlined, onTap: () => _delay(context, ref, 60)),
                const SizedBox(width: 10),
                _DominoActionChip(
                  label: 'Surgery', 
                  icon: Icons.emergency_rounded, 
                  color: const Color(0xFFFF3B30),
                  onTap: () => _showEmergencyDialog(context, ref),
                ),
                const SizedBox(width: 10),
                _DominoActionChip(
                  label: 'Pause', 
                  icon: Icons.pause_circle_filled_rounded, 
                  color: const Color(0xFFFF9500),
                  onTap: () => _delay(context, ref, 20),
                ),
              ],
            ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0),
          ),
        ],
      ),
    );
  }

  void _showEmergencyDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.emergency_rounded, color: Color(0xFFFF3B30)),
            SizedBox(width: 12),
            Text('Emergency Surgery', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ],
        ),
        content: const Text(
          'This will shift all remaining appointments today. Estimated duration?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          _dialogAction(context, '60m', () => _delay(context, ref, 60, isEmergency: true)),
          _dialogAction(context, '90m', () => _delay(context, ref, 90, isEmergency: true)),
          _dialogAction(context, '120m', () => _delay(context, ref, 120, isEmergency: true)),
        ],
      ),
    );
  }

  Widget _dialogAction(BuildContext context, String label, VoidCallback onTap) {
    return TextButton(
      onPressed: () {
        Navigator.pop(context);
        onTap();
      },
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
    );
  }

  Future<void> _delay(BuildContext context, WidgetRef ref, int minutes, {bool isEmergency = false}) async {
    HapticFeedback.heavyImpact();
    if (isEmergency) {
      await ref.read(appointmentControllerProvider.notifier).applyEmergencySurgery(durationMinutes: minutes);
    } else {
      await ref.read(appointmentControllerProvider.notifier).applyDominoLatency(
        appointments: appointments, 
        delayMinutes: minutes
      );
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Domino Engine: Shifted ${appointments.length} slots by $minutes min'),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}

class _DominoActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _DominoActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? Colors.white.withValues(alpha: 0.1);
    final textColor = color != null ? Colors.white : Colors.white70;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  final sf.CalendarView current;
  final ValueChanged<sf.CalendarView> onChanged;
  const _ViewToggle({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          for (final view in [sf.CalendarView.day, sf.CalendarView.week, sf.CalendarView.month])
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => onChanged(view),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: current == view ? CliniGoTheme.primaryColor.withValues(alpha: 0.05) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      view.name[0].toUpperCase() + view.name.substring(1),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: current == view ? CliniGoTheme.primaryColor : Colors.grey[500],
                        fontWeight: current == view ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Syncfusion Data Source — using plain Appointment as the data object
// ---------------------------------------------------------------------------

class _CalendarEntry extends sf.Appointment {
  final model.Appointment source;

  _CalendarEntry({required this.source})
      : super(
          startTime: source.startTime,
          endTime: source.endTime,
          subject: source.patientName,
          color: _statusColor(source),
        );

  static Color _statusColor(model.Appointment appt) {
    if (appt.appointmentType == 'surgery') return Colors.redAccent;
    
    switch (appt.status) {
      case model.AppointmentStatus.running:
        return CliniGoTheme.warningColor;
      case model.AppointmentStatus.finished:
        return CliniGoTheme.successColor;
      case model.AppointmentStatus.paymentPending:
        return Colors.blueAccent;
      case model.AppointmentStatus.completed:
        return Colors.purple;
      case model.AppointmentStatus.noShow:
        return Colors.black54;
      case model.AppointmentStatus.needsReschedule:
        return CliniGoTheme.errorColor;
      case model.AppointmentStatus.cancelled:
        return Colors.grey;
      default:
        return CliniGoTheme.primaryColor;
    }
  }
}

class _AppointmentDataSource extends sf.CalendarDataSource {
  _AppointmentDataSource(List<model.Appointment> appts) {
    appointments = appts.map((a) => _CalendarEntry(source: a)).toList();
  }
}

class _AppointmentCard extends StatelessWidget {
  final _CalendarEntry entry;
  const _AppointmentCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: entry.color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: entry.color.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.subject,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (entry.source.appointmentType == 'surgery')
                const Icon(Icons.emergency_rounded, color: Colors.white, size: 12),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            entry.source.status.toDbString().replaceAll('_', ' ').toUpperCase(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add Appointment Sheet
// ---------------------------------------------------------------------------

class _AddAppointmentSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _AddAppointmentSheet({required this.ref});

  @override
  ConsumerState<_AddAppointmentSheet> createState() => _AddAppointmentSheetState();
}

class _AddAppointmentSheetState extends ConsumerState<_AddAppointmentSheet> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPatientId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final int _durationMinutes = 30;
  String _appointmentType = 'consultation';
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a patient')));
      return;
    }

    final startTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute);
    await ref.read(appointmentControllerProvider.notifier).addAppointment(
          patientId: _selectedPatientId!,
          startTime: startTime,
          durationMinutes: _durationMinutes,
          appointmentType: _appointmentType,
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(appointmentControllerProvider).isLoading;
    final patientsAsync = ref.watch(patientsProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const Text('Schedule Appointment', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5)),
              const SizedBox(height: 24),
              patientsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
                data: (patients) => DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Patient Name', prefixIcon: Icon(Icons.person_outline_rounded)),
                  items: patients.map((p) => DropdownMenuItem(value: p.id, child: Text(p.fullName))).toList(),
                  onChanged: (v) => setState(() => _selectedPatientId = v),
                  validator: (v) => v == null ? 'Select a patient' : null,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _DateTimePickerTile(
                      label: 'Date',
                      value: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      icon: Icons.calendar_today_rounded,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) setState(() => _selectedDate = picked);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateTimePickerTile(
                      label: 'Time',
                      value: _selectedTime.format(context),
                      icon: Icons.access_time_rounded,
                      onTap: () async {
                        final picked = await showTimePicker(context: context, initialTime: _selectedTime);
                        if (picked != null) setState(() => _selectedTime = picked);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _appointmentType,
                decoration: const InputDecoration(labelText: 'Visit Type', prefixIcon: Icon(Icons.medical_services_outlined)),
                items: ['consultation', 'surgery', 'follow_up', 'emergency', 'examination'].map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type[0].toUpperCase() + type.substring(1).replaceAll('_', ' ')),
                )).toList(),
                onChanged: (v) => setState(() => _appointmentType = v ?? 'consultation'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(labelText: 'Notes', prefixIcon: Icon(Icons.edit_note_rounded)),
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: isLoading ? null : _save,
                child: isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Confirm Appointment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateTimePickerTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _DateTimePickerTile({required this.label, required this.value, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[500])),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(icon, size: 14, color: CliniGoTheme.primaryColor),
                const SizedBox(width: 6),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Appointment Actions Sheet
// ---------------------------------------------------------------------------

class _AppointmentActionsSheet extends ConsumerWidget {
  final model.Appointment appointment;
  final WidgetRef ref;
  const _AppointmentActionsSheet({required this.appointment, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: CliniGoTheme.primaryColor.withValues(alpha: 0.1),
                child: Text(appointment.patientName[0], style: const TextStyle(fontWeight: FontWeight.bold, color: CliniGoTheme.primaryColor)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appointment.patientName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                    Text(
                      '${appointment.startTime.hour}:${appointment.startTime.minute.toString().padLeft(2, '0')} · ${appointment.durationMinutes} min',
                      style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: CliniGoTheme.accentColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(appointment.status.toDbString().toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: CliniGoTheme.accentColor)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          if (appointment.status == model.AppointmentStatus.pending)
            _ActionRow(icon: Icons.play_circle_fill_rounded, label: 'Start Consultation', color: CliniGoTheme.primaryColor, onTap: () => _update(context, ref, model.AppointmentStatus.running)),
          if (appointment.status == model.AppointmentStatus.running)
            _ActionRow(icon: Icons.check_circle_rounded, label: 'End Consultation', color: CliniGoTheme.successColor, onTap: () => _update(context, ref, model.AppointmentStatus.finished)),
          if (appointment.status == model.AppointmentStatus.finished)
            _ActionRow(icon: Icons.receipt_long_rounded, label: 'Process Billing', color: const Color(0xFF6366F1), onTap: () => _update(context, ref, model.AppointmentStatus.paymentPending)),
          _ActionRow(icon: Icons.cancel_rounded, label: 'Cancel Appointment', color: Colors.grey[400]!, onTap: () => _update(context, ref, model.AppointmentStatus.cancelled)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _update(BuildContext context, WidgetRef ref, model.AppointmentStatus status) async {
    await ref.read(appointmentControllerProvider.notifier).updateStatus(appointment.id, status);
    if (!context.mounted) return;
    Navigator.pop(context);
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionRow({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 16),
              Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 14)),
              const Spacer(),
              Icon(Icons.chevron_right_rounded, color: color.withValues(alpha: 0.5), size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
