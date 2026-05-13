/// Abstract SMS service following the architecture plan.
/// Swap implementation for Twilio, Firebase, or any provider.
abstract class SmsService {
  Future<void> sendMessage({
    required String phone,
    required String message,
  });
}

// ---------------------------------------------------------------------------
// SMS Templates (from architecture plan)
// ---------------------------------------------------------------------------

class SmsTemplates {
  /// Booking confirmation
  static String bookingConfirmation({
    required String patientName,
    required String clinicName,
    required String time,
  }) =>
      'Hi $patientName, your appointment at $clinicName is set for $time. See you then!';

  /// Delay notification
  static String delayNotification({
    required String patientName,
    required String newTime,
  }) =>
      'Hi $patientName, apologies! Due to an emergency, your appointment is moved to $newTime. Please confirm.';

  /// Reminder
  static String reminder({
    required String patientName,
    required String clinicName,
    required String time,
  }) =>
      'Reminder: Hi $patientName, your appointment at $clinicName is tomorrow at $time.';
}

// ---------------------------------------------------------------------------
// Log-only implementation (dev/no-op)
// Swap with TwilioSmsService or FirebaseSmsService in production
// ---------------------------------------------------------------------------

class LogSmsService implements SmsService {
  @override
  Future<void> sendMessage({
    required String phone,
    required String message,
  }) async {
    // In production, call Twilio REST API or Firebase extension here
    // ignore: avoid_print
    print('[SMS] To: $phone\n$message');
  }
}

// ---------------------------------------------------------------------------
// Singleton provider
// ---------------------------------------------------------------------------

final smsService = LogSmsService();
