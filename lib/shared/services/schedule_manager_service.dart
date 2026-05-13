import 'package:flutter/material.dart';
import '../models/appointment.dart';

/// The Domino Scheduling Engine — CliniGo's core innovation.
///
/// Dynamically recalculates appointment chains when:
/// - Doctors are late
/// - Emergencies occur
/// - Surgeries exceed estimated duration
/// - Walk-ins are inserted
/// - Appointment durations change
class ScheduleManagerService {
  /// Shifts all pending appointments by [delay] starting from now.
  ///
  /// If an appointment would exceed [workHourEnd] after shifting,
  /// it is marked as 'needs_reschedule' and flagged for the next day.
  List<Appointment> applyLatency({
    required List<Appointment> todayAppointments,
    required Duration delay,
    required TimeOfDay workHourEnd,
  }) {
    final List<Appointment> updated = [];

    for (final appt in todayAppointments) {
      if (appt.status != AppointmentStatus.pending) {
        updated.add(appt);
        continue;
      }

      final newStart = appt.startTime.add(delay);
      final newEnd = newStart.add(appt.duration);

      if (_exceedsWorkHours(newEnd, workHourEnd)) {
        updated.add(appt.copyWith(
          status: AppointmentStatus.needsReschedule,
      notes: '${appt.notes ?? ''}\n[Domino] Moved due to clinic latency on ${_fmt(appt.startTime)}',
        ));
      } else {
        updated.add(appt.copyWith(startTime: newStart, endTime: newEnd));
      }
    }

    return updated;
  }

  /// Detects which appointments overflow beyond [workHourEnd].
  List<Appointment> detectOverflow({
    required List<Appointment> appointments,
    required TimeOfDay workHourEnd,
  }) {
    return appointments.where((a) {
      return a.status == AppointmentStatus.pending &&
          _exceedsWorkHours(a.endTime, workHourEnd);
    }).toList();
  }

  /// Finds the next available slot of [durationMinutes] length
  /// in [appointments] after [from], without exceeding [workHourEnd].
  DateTime? findNextSlot({
    required List<Appointment> appointments,
    required DateTime from,
    required int durationMinutes,
    required TimeOfDay workHourEnd,
  }) {
    final sorted = [...appointments]..sort((a, b) => a.startTime.compareTo(b.startTime));
    DateTime candidate = from;

    for (final appt in sorted) {
      if (appt.startTime.isAfter(candidate)) {
        final slotEnd = candidate.add(Duration(minutes: durationMinutes));
        if (slotEnd.isBefore(appt.startTime) || slotEnd.isAtSameMomentAs(appt.startTime)) {
          if (!_exceedsWorkHours(slotEnd, workHourEnd)) return candidate;
        }
      }
      if (appt.endTime.isAfter(candidate)) {
        candidate = appt.endTime;
      }
    }

    // Try after the last appointment
    final end = candidate.add(Duration(minutes: durationMinutes));
    if (!_exceedsWorkHours(end, workHourEnd)) return candidate;

    return null; // No slot available today
  }

  bool _exceedsWorkHours(DateTime time, TimeOfDay workHourEnd) {
    final endMinutes = workHourEnd.hour * 60 + workHourEnd.minute;
    final timeMinutes = time.hour * 60 + time.minute;
    return timeMinutes > endMinutes;
  }

  String _fmt(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
}
