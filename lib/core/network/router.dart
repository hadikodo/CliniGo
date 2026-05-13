
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/register_clinic_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/dashboard/presentation/dashboard_shell.dart';
import '../../features/dashboard/presentation/dashboard_home_page.dart';
import '../../features/patient_management/presentation/patients_list_page.dart';
import '../../features/patient_management/presentation/patient_detail_page.dart';
import '../../features/calendar/presentation/calendar_page.dart';
import '../../features/billing/presentation/billing_page.dart';
import '../../features/superadmin/presentation/joker_console_page.dart';
import '../../features/dashboard/presentation/setup_wizard_page.dart';
import '../../features/settings/presentation/staff_management_page.dart';
import '../../features/medical_records/presentation/patient_medical_history_page.dart';
import '../../shared/models/patient.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final clinicAsync = ref.watch(clinicProvider);

  return GoRouter(
    initialLocation: '/splash',
    routes: [
      // ---- Unauthenticated Routes ----
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/setup',
        builder: (context, state) => const SetupWizardPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterClinicScreen(),
      ),

      // ---- Authenticated Shell ----
      ShellRoute(
        builder: (context, state, child) => DashboardShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardHomePage(),
          ),
          GoRoute(
            path: '/patients',
            builder: (context, state) => const PatientsListPage(),
          ),
          GoRoute(
            path: '/patients/:id',
            builder: (context, state) {
              final patient = state.extra as Patient;
              return PatientDetailPage(patient: patient);
            },
          ),
          GoRoute(
            path: '/calendar',
            builder: (context, state) => const CalendarPage(),
          ),
          GoRoute(
            path: '/billing',
            builder: (context, state) => const BillingPage(),
          ),
          GoRoute(
            path: '/joker',
            builder: (context, state) => const JokerConsolePage(),
          ),
          GoRoute(
            path: '/staff',
            builder: (context, state) => const StaffManagementPage(),
          ),
          GoRoute(
            path: '/patient/:id/history',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              final name = state.uri.queryParameters['name'] ?? 'Patient';
              return PatientMedicalHistoryPage(patientId: id, patientName: name);
            },
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      if (authState.isLoading) return null;

      final session = authState.value?.session;
      final isAuth = session != null;
      final isJoker = ref.read(isJokerProvider);

      final loc = state.matchedLocation;
      final isPublic = loc == '/login' || loc == '/register' || loc == '/onboarding' || loc == '/splash';

      if (!isAuth && !isPublic) return '/login';
      if (isAuth) {
        if (isPublic) return isJoker ? '/joker' : '/dashboard';
        
        // Setup Check (Joker bypasses)
        if (!isJoker) {
          final clinic = clinicAsync.value;
          if (clinic != null && !clinic.isSetupCompleted && loc != '/setup') {
            return '/setup';
          }
        }
      }
      return null;
    },
  );
});
