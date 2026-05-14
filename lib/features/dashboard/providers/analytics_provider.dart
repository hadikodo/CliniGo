import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../calendar/providers/appointment_provider.dart';
import '../../patient_management/providers/patient_provider.dart';
import '../../../shared/models/appointment.dart';

class ClinicAnalytics {
  final double patientGrowth;
  final int averageWaitTimeMinutes;
  final double revenueGrowth;

  ClinicAnalytics({
    required this.patientGrowth,
    required this.averageWaitTimeMinutes,
    required this.revenueGrowth,
  });
}

final analyticsProvider = Provider<ClinicAnalytics>((ref) {
  final appointments = ref.watch(appointmentsProvider).value ?? [];
  final patients = ref.watch(patientsProvider).value ?? [];

  // Simulate analytics logic
  double growth = 12.5;
  if (patients.length > 50) growth = 18.2;
  
  int waitTime = 15;
  if (appointments.any((a) => a.startTime.isBefore(DateTime.now()) && a.status == AppointmentStatus.pending)) {
    waitTime = 25;
  }

  return ClinicAnalytics(
    patientGrowth: growth,
    averageWaitTimeMinutes: waitTime,
    revenueGrowth: 8.4,
  );
});
