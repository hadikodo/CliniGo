import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/models/appointment.dart' as model;
import '../../../shared/services/sms_service.dart';

// ---------------------------------------------------------------------------
// Today's appointments — simple FutureProvider (no Realtime complexity)
// ---------------------------------------------------------------------------

final appointmentsProvider = FutureProvider<List<model.Appointment>>((ref) async {
  final supabase = ref.read(supabaseClientProvider);

  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day).toIso8601String();
  final todayEnd =
      DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

  final response = await supabase
      .from('appointments')
      .select('*, patients(first_name, last_name, phone)')
      .gte('start_time', todayStart)
      .lte('start_time', todayEnd)
      .order('start_time');

  return (response as List)
      .map((e) => model.Appointment.fromJson(e as Map<String, dynamic>))
      .toList();
});

// ---------------------------------------------------------------------------
// Appointment Notifier
// ---------------------------------------------------------------------------

class AppointmentNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> addAppointment({
    required String patientId,
    required DateTime startTime,
    required int durationMinutes,
    String? appointmentType,
    String? notes,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final supabase = ref.read(supabaseClientProvider);
      final profile = await ref.read(userProfileProvider.future);
      final endTime = startTime.add(Duration(minutes: durationMinutes));

      await supabase.from('appointments').insert({
        'clinic_id': profile?.clinicId,
        'patient_id': patientId,
        'doctor_id': profile?.id,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'duration_minutes': durationMinutes,
        'status': 'pending',
        'appointment_type': appointmentType ?? 'consultation',
        'notes': notes,
      });

      // Optional: Send booking confirmation SMS
      // (This would require fetching the patient details again or passing them in)

      ref.invalidate(appointmentsProvider);
    });
  }

  Future<void> updateStatus(
      String appointmentId, model.AppointmentStatus status, {double? billingAmount}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final supabase = ref.read(supabaseClientProvider);
      final updates = {
        'status': status.toDbString(),
        if (billingAmount != null) 'billing_amount': billingAmount,
      };
      await supabase
          .from('appointments')
          .update(updates)
          .eq('id', appointmentId);
      ref.invalidate(appointmentsProvider);
    });
  }

  Future<void> applyDominoLatency({
    required List<model.Appointment> appointments,
    required int delayMinutes,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final supabase = ref.read(supabaseClientProvider);
      for (final appt in appointments) {
        if (appt.status != model.AppointmentStatus.pending) continue;
        final newStart = appt.startTime.add(Duration(minutes: delayMinutes));
        final newEnd = newStart.add(appt.duration);

        await supabase.from('appointments').update({
          'start_time': newStart.toIso8601String(),
          'end_time': newEnd.toIso8601String(),
        }).eq('id', appt.id);

        // TRIGGER SMS: Notify patient about the shift
        if (appt.patientPhone != null) {
          final message = SmsTemplates.delayNotification(
            patientName: appt.patientName,
            newTime: '${newStart.hour}:${newStart.minute.toString().padLeft(2, '0')}',
          );
          await smsService.sendMessage(
            phone: appt.patientPhone!,
            message: message,
          );
        }
      }
      ref.invalidate(appointmentsProvider);
    });
  }

  Future<void> applyDominoCompression({
    required String finishedAppointmentId,
    required DateTime actualEndTime,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final supabase = ref.read(supabaseClientProvider);
      final appointments = await ref.read(appointmentsProvider.future);
      
      final finishedAppt = appointments.firstWhere((a) => a.id == finishedAppointmentId);
      if (actualEndTime.isAfter(finishedAppt.endTime)) return; // No compression needed if late

      final reclaimDuration = finishedAppt.endTime.difference(actualEndTime);
      if (reclaimDuration.inMinutes < 5) return; // Ignore small gaps

      for (final appt in appointments) {
        // Only shift pending appointments that start after the finished one
        if (appt.status == model.AppointmentStatus.pending && 
            appt.startTime.isAfter(finishedAppt.startTime)) {
          
          final newStart = appt.startTime.subtract(reclaimDuration);
          final newEnd = newStart.add(appt.duration);

          await supabase.from('appointments').update({
            'start_time': newStart.toIso8601String(),
            'end_time': newEnd.toIso8601String(),
          }).eq('id', appt.id);
        }
      }
      ref.invalidate(appointmentsProvider);
    });
  }
}

final appointmentControllerProvider =
    AsyncNotifierProvider<AppointmentNotifier, void>(AppointmentNotifier.new);
