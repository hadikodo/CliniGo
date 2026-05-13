# CliniGo — Enterprise Clinic Management SaaS Plan

## 1. Project Vision & Brand Identity

### Vision
CliniGo is a premium multi-tenant Clinic Management SaaS platform designed for modern clinics, hospitals, and medical centers in Lebanon and international markets.

The platform focuses on:
- High-speed medical workflows
- Smart appointment orchestration
- Multi-role operational management
- Specialty-driven medical records
- Beautiful premium user experience
- Enterprise-grade scalability

The core differentiator of CliniGo is the **Domino Scheduling Engine**, allowing recursive appointment shifting and latency management for real-world clinical operations.

---

## 2. Brand Identity & UI/UX System

### Design Philosophy
**"Medical Apple" Aesthetic**

CliniGo must feel:
- Minimal
- Premium
- Clinical
- Calm
- Extremely fast
- High trust

### UI Principles
- High-density whitespace
- Glassmorphism cards
- Soft shadows
- Rounded corners (16–24px)
- Smooth animations
- Haptic feedback on mobile
- Clean typography hierarchy
- Subtle gradients only where necessary

### Typography
Primary Fonts:
- SF Pro Display
- Inter

Typography Scale:
- Headlines: 28–36px
- Section Titles: 20–24px
- Body: 14–16px
- Caption: 12px

### Color Palette
| Purpose | Color |
|---|---|
| Primary | #007AFF |
| Background | #FFFFFF |
| Secondary Slate | #8E8E93 |
| Success | #34C759 |
| Warning | #FF9500 |
| Error | #FF3B30 |
| Glass Overlay | rgba(255,255,255,0.65) |

### Platform Targets
- Flutter Android
- Flutter iOS
- Flutter Web
- Tablet Responsive Layouts

### Responsiveness
#### Mobile
- Single column
- Bottom navigation
- Drawer for advanced settings

#### Tablet/Web
- Multi-pane layout
- Calendar + Patient Details split view
- Sidebar navigation
- Floating utility panels

---

# 3. Technology Stack

## Frontend
| Technology | Purpose |
|---|---|
| Flutter | Cross-platform app framework |
| Riverpod | State management |
| GoRouter | Navigation |
| Flutter Hooks | Reactive lifecycle handling |
| Syncfusion Calendar | Advanced scheduling |
| Flutter Animate | Smooth transitions |
| Responsive Framework | Adaptive layouts |

## Backend
| Technology | Purpose |
|---|---|
| Supabase | Database + Auth + Realtime |
| PostgreSQL | Main relational database |
| Supabase Edge Functions | Serverless APIs |
| Firebase Cloud Messaging | Push notifications |
| RevenueCat | Subscription management |
| Twilio/Firebase SMS | SMS delivery |

## Infrastructure
| Component | Service |
|---|---|
| Hosting | Supabase + Vercel |
| Monitoring | Sentry |
| Analytics | Firebase Analytics |
| CI/CD | GitHub Actions |
| Secrets | Supabase Vault |

---

# 4. Flutter System Architecture

## Folder Structure

```plaintext
lib/
├── core/
│   ├── constants/
│   ├── utils/
│   ├── widgets/
│   └── network/
│
├── features/
│   ├── auth/
│   ├── calendar/
│   ├── medical_records/
│   ├── patient_management/
│   ├── billing/
│   └── superadmin/
│
└── shared/
    ├── models/
    ├── providers/
    └── services/
```

---

## Clean Architecture Layers

### Presentation Layer
Contains:
- Pages
- Widgets
- Providers
- UI State

### Domain Layer
Contains:
- Entities
- Business Logic
- Use Cases
- Validation Rules

### Data Layer
Contains:
- Repositories
- DTOs
- Supabase APIs
- Local caching

---

# 5. State Management Strategy

## Riverpod Providers

### authProvider
Responsibilities:
- Authentication session
- User role
- Clinic resolution
- Subscription validation

### calendarProvider
Responsibilities:
- Realtime appointment stream
- Domino engine sync
- Calendar filtering
- Drag/drop updates

### specialtyProvider
Responsibilities:
- Specialty JSON schema loading
- Dynamic form rendering
- Validation rules

### billingProvider
Responsibilities:
- Invoice generation
- Revenue statistics
- Payment states

### notificationProvider
Responsibilities:
- SMS queues
- Push notifications
- Alert banners

---

# 6. Database Architecture (Supabase)

## Main Tables

### clinics
```sql
CREATE TABLE clinics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  specialty_type TEXT NOT NULL,
  work_hour_start TIME NOT NULL,
  work_hour_end TIME NOT NULL,
  subscription_status TEXT DEFAULT 'trial',
  trial_ends_at TIMESTAMP WITH TIME ZONE DEFAULT (now() + interval '30 days')
);
```

### user_profiles
```sql
CREATE TABLE user_profiles (
  id UUID REFERENCES auth.users PRIMARY KEY,
  clinic_id UUID REFERENCES clinics(id),
  role user_role NOT NULL,
  full_name TEXT
);
```

### patients
```sql
CREATE TABLE patients (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  clinic_id UUID REFERENCES clinics(id),
  first_name TEXT,
  last_name TEXT,
  phone TEXT,
  birth_date DATE,
  gender TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);
```

### appointments
```sql
CREATE TABLE appointments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  clinic_id UUID REFERENCES clinics(id),
  patient_id UUID REFERENCES patients(id),
  doctor_id UUID REFERENCES user_profiles(id),
  start_time TIMESTAMP WITH TIME ZONE,
  end_time TIMESTAMP WITH TIME ZONE,
  duration_minutes INTEGER,
  status TEXT,
  notes TEXT
);
```

### medical_records
```sql
CREATE TABLE medical_records (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  clinic_id UUID REFERENCES clinics(id),
  patient_id UUID REFERENCES patients(id),
  clinical_data JSONB,
  created_by UUID REFERENCES user_profiles(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);
```

### invoices
```sql
CREATE TABLE invoices (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  clinic_id UUID REFERENCES clinics(id),
  patient_id UUID REFERENCES patients(id),
  amount NUMERIC,
  status TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);
```

---

# 7. Security & Row Level Security (RLS)

## User Roles
```sql
CREATE TYPE user_role AS ENUM (
  'doctor',
  'secretary',
  'assistant',
  'superadmin'
);
```

## Joker Override Function

```sql
CREATE OR REPLACE FUNCTION is_joker() RETURNS BOOLEAN AS $$
BEGIN
  RETURN (
    SELECT email
    FROM auth.users
    WHERE id = auth.uid()
  ) = 'jocker@supertechlb.com';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Global RLS Example

```sql
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Clinic Access or Joker Override"
ON appointments
FOR ALL
USING (
  clinic_id = (
    SELECT clinic_id
    FROM user_profiles
    WHERE id = auth.uid()
  )
  OR is_joker()
);
```

---

# 8. The Domino Scheduling Engine

## Overview
The Domino Scheduling Engine is the core innovation of CliniGo.

It dynamically recalculates appointment chains when:
- Doctors are late
- Emergencies occur
- Surgeries exceed estimated duration
- Walk-ins are inserted
- Appointment durations change

---

## Engine Responsibilities

### Latency Shift
Shift all upcoming appointments.

### Overflow Detection
Move overflow appointments automatically.

### Smart Rescheduling
Find nearest valid slot.

### Patient Notification Triggering
Automatically queue SMS alerts.

### Work Hour Protection
Prevent scheduling beyond clinic hours.

---

## Core Service

```dart
class ScheduleManagerService {
  List<Appointment> applyLatency({
    required List<Appointment> todayAppointments,
    required Duration delay,
    required TimeOfDay workHourEnd,
  }) {
    List<Appointment> updated = [];

    for (var appt in todayAppointments.where((a) => a.status == 'pending')) {
      DateTime newStart = appt.startTime.add(delay);
      DateTime newEnd = newStart.add(appt.duration);

      if (isExceedingWorkHours(newEnd, workHourEnd)) {
        updated.add(appt.copyWith(
          status: 'needs_reschedule',
          date: appt.date.add(Duration(days: 1)),
          notes: 'Moved due to clinic latency'
        ));
      } else {
        updated.add(appt.copyWith(startTime: newStart));
      }
    }

    return updated;
  }
}
```

---

# 9. Dynamic Specialty Module

## Overview
Medical forms are generated dynamically based on the clinic specialty.

All clinical data is stored in JSONB.

This allows:
- Unlimited specialty expansion
- Dynamic forms
- No schema rewrites
- AI analysis compatibility

---

## Dental Example

```json
{
  "teeth": [
    {
      "id": 18,
      "status": "decayed"
    }
  ],
  "gum_depth": [3,2,3]
}
```

## Cardiology Example

```json
{
  "bp_history": [
    {
      "s": 120,
      "d": 80
    }
  ],
  "ecg_note": "Sinus rhythm"
}
```

## Pediatrics Example

```json
{
  "growth": {
    "weight": 12.5,
    "height": 85
  },
  "vaccines": ["MMR", "Polio"]
}
```

## OB/GYN Example

```json
{
  "lmp": "2026-02-01",
  "edd": "2026-11-08",
  "fetal_heart": 145
}
```

---

# 10. Authentication & Onboarding Flow

## User Journey

### Step 1 — Register Clinic
User enters:
- Clinic name
- Specialty
- Country
- Phone
- Owner account

### Step 2 — Trial Paywall
Display:
- 30-day trial
- Features list
- Pricing
- Subscription terms

### Step 3 — RevenueCat Purchase
Supported:
- Apple Pay
- Google Pay
- Credit Cards

### Step 4 — Clinic Initialization
After successful payment:
- Create clinic record
- Create owner profile
- Assign doctor/admin role
- Initialize settings

### Step 5 — Guided Setup Wizard
Includes:
- Work hours
- Staff invites
- Appointment durations
- SMS templates

---

# 11. Subscription System

## Pricing
| Plan | Price |
|---|---|
| Trial | 30 Days |
| Standard | $49.99/month |

## Future Plans
- Enterprise clinics
- Multi-branch organizations
- Hospital packages
- AI add-ons

---

# 12. Role-Based Dashboards

# Doctor Dashboard

## Features
### Analytics
- Monthly revenue
- Revenue trends
- Patient growth
- Average waiting time

### Staff Management
- Invite staff
- Revoke access
- Permission controls

### Clinical Workspace
- Full patient history
- Rich text notes
- Imaging attachments
- Dynamic specialty forms

### Smart Calendar
- Real-time schedule
- Delays visualization
- Drag/drop editing

---

# Secretary Dashboard

## War Room Calendar
Features:
- Drag/drop appointments
- Instant updates
- Queue management
- Overflow handling

## Lifecycle Controls
Buttons:
- Start Appointment
- Mark Finished
- Payment Collected

## SMS Center
Templates:
- Confirm booking
- Delay notice
- Reminder message

---

# Assistant Dashboard

## Queue View
- Today's patients only
- Minimal distractions
- Large touch targets

## Vitals Entry
Fast forms:
- Blood pressure
- Temperature
- Weight
- Height
- Pulse

---

# 13. Joker Console (Superadmin)

## Access
Exclusive to:
```plaintext
jocker@supertechlb.com
```

## Features

### Global Clinics Map
- Active clinics
- Subscription states
- Clinic locations

### Subscription Override
- Activate/deactivate clinics
- Trial extension
- Force suspension

### System Monitoring
- Live logs
- Failed API requests
- SMS failures
- Revenue statistics

### User Monitoring
- Active sessions
- Login history
- Device tracking

---

# 14. SMS & Notification System

## SmsService Abstraction

```dart
abstract class SmsService {
  Future<void> sendMessage({
    required String phone,
    required String message,
  });
}
```

---

## Templates

### Booking Confirmation
```plaintext
Hi [Name], your appointment at [Clinic] is set for [Time]. See you then!
```

### Delay Notification
```plaintext
Apologies! Due to an emergency, your appointment is moved to tomorrow at [Time]. Please confirm.
```

### Reminder
```plaintext
Reminder: Your appointment at [Clinic] is tomorrow at [Time].
```

---

# 15. Realtime System Design

## Supabase Realtime Channels

### Appointment Stream
Realtime updates for:
- New appointments
- Delays
- Status changes

### Notifications Stream
Realtime alerts for:
- Staff invites
- Payment updates
- Emergencies

### Queue Synchronization
Keep all devices synchronized instantly.

---

# 16. Offline Strategy

## Local Cache
Use:
- Hive
- Isar
- SQLite

## Offline Capabilities
- View schedules
- Access patient history
- Draft notes
- Queue pending sync

## Conflict Resolution
Priority:
1. Server timestamp
2. Doctor modifications
3. Last write fallback

---

# 17. Performance Optimization

## Flutter Optimization
- Lazy loading
- Pagination
- Memoized providers
- Debounced search
- Virtualized lists

## Supabase Optimization
- Indexed columns
- RPC functions
- Batched inserts
- Optimized JSONB queries

---

# 18. AI Features Roadmap

## AI Assistant
Powered by OpenAI.

### Features
- Clinical note summarization
- Smart diagnosis suggestions
- Medication interaction alerts
- AI-generated SOAP notes
- Appointment forecasting

## Future AI Modules
- Arabic transcription
- Voice-to-medical-record
- AI triage assistant
- Medical coding assistant

---

# 19. Security & Compliance

## Security Requirements
- HTTPS everywhere
- JWT validation
- Secure storage
- Encrypted local cache
- Signed API requests

## Audit Logging
Track:
- Login events
- Patient record access
- Billing changes
- Prescription modifications

## Backup Strategy
- Daily backups
- Point-in-time recovery
- Disaster recovery plan

---

# 20. Deployment Strategy

## Environments
| Environment | Purpose |
|---|---|
| Development | Internal testing |
| Staging | QA validation |
| Production | Live clinics |

## CI/CD
GitHub Actions:
- Flutter tests
- Linting
- Build validation
- Deployment automation

---

# 21. QA & Testing

## Automated Testing
- Unit tests
- Widget tests
- Integration tests
- End-to-end tests

## Manual Testing
- Doctor workflows
- Secretary workflows
- Offline testing
- Multi-device synchronization

---

# 22. Analytics & Monitoring

## Analytics
Track:
- Monthly active clinics
- Appointment counts
- Revenue metrics
- User retention

## Monitoring
Tools:
- Sentry
- Firebase Crashlytics
- Supabase Logs

---

# 23. MVP Launch Scope

## Included in MVP
- Authentication
- Subscription flow
- Scheduling engine
- Calendar
- Patients management
- Billing basics
- SMS notifications
- Multi-role dashboards
- Joker console

## Post-MVP
- AI assistant
- Telemedicine
- Insurance integration
- Multi-branch support
- Voice transcription

---

# 24. Future Expansion

## Expansion Targets
- GCC countries
- Europe
- Africa

## Additional Verticals
- Hospitals
- Laboratories
- Pharmacies
- Radiology centers
- Home healthcare

---

# 25. Advanced Operational Workflow System

## Appointment Lifecycle Engine

Every appointment must follow a strict operational workflow.

## Appointment Statuses

| Status | Description |
|---|---|
| pending | Appointment created and waiting |
| running | Patient entered doctor room |
| finished | Doctor completed consultation |
| payment_pending | Billing amount generated |
| completed | Secretary collected payment |
| cancelled | Appointment cancelled |
| no_show | Patient did not arrive |
| needs_reschedule | Moved because of overflow |

---

## Lifecycle Workflow

```plaintext
Pending
→ Running
→ Finished
→ Payment Pending
→ Completed
```

---

## Workflow Permissions

### Secretary
Can:
- Create appointment
- Edit appointment
- Start appointment
- Complete payment
- Send SMS
- Create patient profile

Cannot:
- Edit medical notes
- Edit prescriptions

### Assistant
Can:
- View today's appointments
- Add medical notes
- Add prescriptions
- Edit vitals
- Add attachments

Cannot:
- Access billing
- Modify users
- Delete appointments

### Doctor
Can:
- Full access
- Manage users
- Manage clinic settings
- Modify all medical records
- Manage billing
- Override schedule

---

# 26. Smart Compression Scheduling Engine

## Reverse Latency Optimization

The Domino Engine must support:
- Delays
- Overflow
- Schedule compression
- Dynamic time reclaiming

---

## Compression Example

If:
- Appointment reserved for 30 minutes
- Doctor finishes in 10 minutes

Then:
- Remaining appointments today shift earlier by 20 minutes
- Only today's appointments are affected
- Tomorrow appointments are never pulled earlier

---

## Compression Rules

| Rule | Behavior |
|---|---|
| Earlier finish | Shift remaining today appointments earlier |
| Overflow | Push extra appointments to tomorrow |
| Emergency surgery | Add latency to all remaining appointments |
| Work hour exceeded | Auto move remaining patients |
| Manual override | Doctor can freeze schedule |

---

# 27. Calendar Emergency Actions

## Quick Actions

Inside the calendar UI:

```plaintext
[Delay 15 Minutes]
[Delay 30 Minutes]
[Delay 1 Hour]
[Pause Clinic]
[Emergency Surgery]
[Freeze Calendar]
```

---

## Emergency Surgery Flow

When doctor presses:
```plaintext
Emergency Surgery
```

The system:
1. Asks estimated surgery duration
2. Calculates new latency
3. Re-arranges remaining appointments
4. Detects overflow patients
5. Marks overflow appointments
6. Suggests SMS sending

---

# 28. Surgery Block System

## Calendar Surgery Blocks

Secretaries and doctors can create:
- Surgery blocks
- Reserved time slots
- Emergency blocks
- Personal unavailable time

---

## Surgery Block Properties

| Field | Type |
|---|---|
| title | TEXT |
| duration | INTEGER |
| start_time | TIMESTAMP |
| end_time | TIMESTAMP |
| surgery_type | TEXT |
| notes | TEXT |
| affects_schedule | BOOLEAN |

---

# 29. SMS Trigger UX

## SMS Philosophy

SMS messages are NOT automatically sent.

Doctor or secretary must manually confirm sending.

---

## SMS Trigger Buttons

### Appointment Creation
```plaintext
[Send Confirmation SMS]
```

### Appointment Delay
```plaintext
[Send Delay SMS]
```

### Overflow Movement
```plaintext
[Send Tomorrow Appointment SMS]
```

### Reminder
```plaintext
[Send Reminder SMS]
```

---

## SMS Templates

### Appointment Created
```plaintext
Hello [Patient Name], your appointment at [Clinic Name] is confirmed on [Date] at [Time].
```

### Delay Notification
```plaintext
Hello [Patient Name], due to an emergency your appointment has been delayed to [New Time].
```

### Overflow Notification
```plaintext
Hello [Patient Name], due to clinic emergency your appointment has been moved to tomorrow at [Time]. Please confirm.
```

---

# 30. Prescription Module

## Prescription System

Doctors and assistants can:
- Add medicines
- Edit medicines
- Print prescriptions
- Save reusable templates

---

## Prescription Fields

| Field | Type |
|---|---|
| medicine_name | TEXT |
| dosage | TEXT |
| frequency | TEXT |
| duration | TEXT |
| notes | TEXT |
| created_by | UUID |

---

## Prescription Features

- PDF export
- Clinic logo printing
- Arabic + English support
- Favorite medications
- Recent medications history
- Drug interaction AI alerts (future)

---

# 31. Registration Lead Funnel

## Public Landing Flow

No public account registration exists.

Instead:

```plaintext
Register Your Clinic
```

opens a lead generation form.

---

## Registration Form Fields

| Field | Type |
|---|---|
| clinic_name | TEXT |
| clinic_specialty | SELECT |
| estimated_monthly_patients | INTEGER |
| country | TEXT |
| city | TEXT |
| mobile_number | TEXT |
| whatsapp_number | TEXT |
| clinic_size | SELECT |
| message | TEXT |

---

## Admin Review Flow

After submission:
1. Lead stored in database
2. Superadmin receives notification
3. Lead reviewed manually
4. Clinic activated
5. Subscription process starts

---

# 32. Appointment Types

## Supported Appointment Types

| Type | Description |
|---|---|
| consultation | Standard visit |
| follow_up | Follow-up session |
| surgery | Surgical procedure |
| emergency | Emergency appointment |
| procedure | Clinic procedure |
| examination | Diagnostic examination |
| online_consultation | Virtual appointment |
| vaccination | Vaccine session |
| therapy | Therapy session |
| imaging | Imaging/radiology session |

---

# 33. Queue Management System

## Live Queue Board

Secretaries and assistants can view:
- Waiting patients
- Running appointment
- Delayed patients
- Finished patients
- Payment pending patients

---

## Queue Features

- Drag/drop priority
- Emergency insertion
- Color-coded statuses
- Realtime updates
- Sound alerts

---

# 34. Simplicity-First UX Philosophy

## Core Product Principle

CliniGo must remain:
- Extremely simple
- Fast to learn
- Minimal clicks
- Non-overwhelming
- Premium feeling

---

## UX Rules

| Rule | Description |
|---|---|
| Max 2-click actions | Frequent operations must be fast |
| Large touch targets | Tablet-friendly |
| Minimal text clutter | Clean interfaces |
| Smart defaults | Reduce typing |
| Fast appointment creation | Under 15 seconds |
| Persistent search | Quickly find patients |

---

# 35. Global Specialty Registry

## Specialty System

The system must ship with preloaded medical specialties.

Each specialty contains:
- Specialty name
- Required medical fields
- Clinical templates
- Prescription presets
- Appointment durations
- Common procedures
- Common diagnoses

---

## Core Specialties

### General Medicine
Fields:
- Symptoms
- Diagnosis
- Blood pressure
- Temperature
- Chronic diseases

### Cardiology
Fields:
- ECG
- Blood pressure
- Heart rate
- Echocardiogram notes
- Chest pain history

### Dermatology
Fields:
- Skin type
- Allergy history
- Rash location
- Lesion images

### Dentistry
Fields:
- Teeth chart
- Gum depth
- Cavities
- Procedures
- X-rays

### Pediatrics
Fields:
- Weight
- Height
- Vaccines
- Growth tracking
- Development notes

### Orthopedics
Fields:
- Bone injury
- MRI results
- Mobility status
- Pain scale

### Neurology
Fields:
- Seizure history
- Reflex tests
- MRI notes
- Cognitive assessment

### Psychiatry
Fields:
- Mood assessment
- Medication history
- Session notes
- Anxiety scale

### OB/GYN
Fields:
- LMP
- EDD
- Pregnancy status
- Fetal heart rate
- Ultrasound notes

### Ophthalmology
Fields:
- Vision test
- Eye pressure
- Retina findings
- Lens prescription

### ENT
Fields:
- Hearing tests
- Sinus status
- Infection notes
- Endoscopy notes

### Urology
Fields:
- Kidney history
- Urinary symptoms
- Ultrasound results

### Gastroenterology
Fields:
- Endoscopy
- Colonoscopy
- Digestion history
- Liver functions

### Pulmonology
Fields:
- Oxygen saturation
- Lung function
- Asthma history
- X-ray notes

### Oncology
Fields:
- Cancer stage
- Chemotherapy history
- Biopsy notes
- Treatment plans

### Endocrinology
Fields:
- Thyroid levels
- Diabetes history
- Hormone tracking

### Nephrology
Fields:
- Kidney function
- Dialysis schedule
- Creatinine levels

### Rheumatology
Fields:
- Joint pain
- Autoimmune markers
- Mobility status

### Plastic Surgery
Fields:
- Before images
- Procedure planning
- Healing tracking

### Physical Therapy
Fields:
- Mobility score
- Therapy sessions
- Recovery tracking

### Radiology
Fields:
- Imaging reports
- Scan type
- Findings

### Laboratory
Fields:
- Blood tests
- Results
- Reference ranges

### Nutrition
Fields:
- Weight history
- Diet plans
- Calories

### Speech Therapy
Fields:
- Speech evaluation
- Therapy plans

### Psychology
Fields:
- Behavioral notes
- Therapy sessions

### Emergency Medicine
Fields:
- Triage level
- Emergency procedures
- Critical alerts

---

## Future Specialty Expansion

The system architecture must support unlimited specialties dynamically using JSONB schema rendering.

---

# 36. Seed Data & Static Data Initialization

## Required Seed Data

The backend must preload:

### Medical Specialties
- All major specialties
- Sub-specialties

### Appointment Statuses
- pending
- running
- finished
- payment_pending
- completed
- cancelled
- no_show

### Appointment Types
- consultation
- surgery
- follow_up
- emergency
- procedure

### Clinic Types
- private_clinic
- medical_center
- laboratory
- radiology_center
- dental_clinic
- therapy_center

### Permissions Matrix
- doctor permissions
- secretary permissions
- assistant permissions

### SMS Templates
- booking
- delay
- reminder
- overflow

### Prescription Templates
- common antibiotics
- common painkillers
- chronic medications

---

# 37. Final Product Identity

CliniGo is not just a clinic application.

It is:
- A premium medical operating system
- A real-time clinic orchestration platform
- A multi-tenant healthcare SaaS ecosystem
- A smart appointment management engine
- A future AI-powered healthcare infrastructure

The mission is to become the modern infrastructure layer for clinics and private healthcare operations across Lebanon and international markets.

