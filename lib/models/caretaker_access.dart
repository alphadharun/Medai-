import 'appointment.dart';
import 'medication.dart';

/// Caregiver link status lifecycle relative to patient consent.
enum CaregiverLinkStatus {
  approved('Approved', 'Active consent link granted by patient'),
  pending('Pending Patient Approval', 'Waiting for patient to accept invitation'),
  revoked('Access Revoked', 'Patient has withdrawn caregiver access permissions');

  final String label;
  final String description;
  const CaregiverLinkStatus(this.label, this.description);
}

/// Alert details for a missed medication dose.
class MissedDoseAlert {
  final String id;
  final String medicationName;
  final String dosage;
  final String scheduledTime;
  final String patientName;
  final String patientPhone;
  final bool isAcknowledged;
  final bool isFollowUpComplete;
  final String? followUpNote;
  final DateTime? acknowledgedAt;
  final DateTime? completedAt;

  const MissedDoseAlert({
    required this.id,
    required this.medicationName,
    required this.dosage,
    required this.scheduledTime,
    required this.patientName,
    required this.patientPhone,
    this.isAcknowledged = false,
    this.isFollowUpComplete = false,
    this.followUpNote,
    this.acknowledgedAt,
    this.completedAt,
  });

  MissedDoseAlert copyWith({
    String? id,
    String? medicationName,
    String? dosage,
    String? scheduledTime,
    String? patientName,
    String? patientPhone,
    bool? isAcknowledged,
    bool? isFollowUpComplete,
    String? followUpNote,
    DateTime? acknowledgedAt,
    DateTime? completedAt,
  }) {
    return MissedDoseAlert(
      id: id ?? this.id,
      medicationName: medicationName ?? this.medicationName,
      dosage: dosage ?? this.dosage,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      isFollowUpComplete: isFollowUpComplete ?? this.isFollowUpComplete,
      followUpNote: followUpNote ?? this.followUpNote,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// Alert details for medication running low and needing refill.
class RefillAlert {
  final String id;
  final String medicationName;
  final String dosage;
  final int daysLeft;
  final int pillsRemaining;

  const RefillAlert({
    required this.id,
    required this.medicationName,
    required this.dosage,
    required this.daysLeft,
    required this.pillsRemaining,
  });
}

/// A patient profile linked to the caretaker.
class CaregiverLinkedPatient {
  final String id;
  final String name;
  final String relationship;
  final int age;
  final String gender;
  final String mrn;
  final String phone;
  final CaregiverLinkStatus linkStatus;
  final String linkedSince;
  final List<Medication> medications;
  final List<Appointment> appointments;
  final MissedDoseAlert? activeMissedDose;
  final List<RefillAlert> refillAlerts;

  const CaregiverLinkedPatient({
    required this.id,
    required this.name,
    required this.relationship,
    required this.age,
    required this.gender,
    required this.mrn,
    required this.phone,
    required this.linkStatus,
    required this.linkedSince,
    required this.medications,
    required this.appointments,
    this.activeMissedDose,
    required this.refillAlerts,
  });

  bool get isApproved => linkStatus == CaregiverLinkStatus.approved;
  bool get isPending => linkStatus == CaregiverLinkStatus.pending;
  bool get isRevoked => linkStatus == CaregiverLinkStatus.revoked;

  CaregiverLinkedPatient copyWith({
    String? id,
    String? name,
    String? relationship,
    int? age,
    String? gender,
    String? mrn,
    String? phone,
    CaregiverLinkStatus? linkStatus,
    String? linkedSince,
    List<Medication>? medications,
    List<Appointment>? appointments,
    MissedDoseAlert? activeMissedDose,
    bool clearActiveMissedDose = false,
    List<RefillAlert>? refillAlerts,
  }) {
    return CaregiverLinkedPatient(
      id: id ?? this.id,
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      mrn: mrn ?? this.mrn,
      phone: phone ?? this.phone,
      linkStatus: linkStatus ?? this.linkStatus,
      linkedSince: linkedSince ?? this.linkedSince,
      medications: medications ?? this.medications,
      appointments: appointments ?? this.appointments,
      activeMissedDose: clearActiveMissedDose
          ? null
          : (activeMissedDose ?? this.activeMissedDose),
      refillAlerts: refillAlerts ?? this.refillAlerts,
    );
  }
}

/// Notification preferences for a caretaker.
class CaretakerNotificationPreferences {
  final bool missedDoses;
  final bool appointments;
  final bool refills;
  final bool dailySummary;

  const CaretakerNotificationPreferences({
    this.missedDoses = true,
    this.appointments = true,
    this.refills = true,
    this.dailySummary = false,
  });

  CaretakerNotificationPreferences copyWith({
    bool? missedDoses,
    bool? appointments,
    bool? refills,
    bool? dailySummary,
  }) {
    return CaretakerNotificationPreferences(
      missedDoses: missedDoses ?? this.missedDoses,
      appointments: appointments ?? this.appointments,
      refills: refills ?? this.refills,
      dailySummary: dailySummary ?? this.dailySummary,
    );
  }
}

/// Fictional mock directory for Caretaker Portal demonstration.
class MockCaretakerDirectory {
  static List<CaregiverLinkedPatient> getInitialLinkedPatients() {
    return [
      CaregiverLinkedPatient(
        id: 'patient_sarah',
        name: 'Sarah Jenkins',
        relationship: 'Mother',
        age: 68,
        gender: 'Female',
        mrn: 'MRN-849201',
        phone: '(555) 234-9988',
        linkStatus: CaregiverLinkStatus.approved,
        linkedSince: 'Jan 15, 2026',
        medications: [
          Medication(
            id: 'med_lisinopril',
            name: 'Lisinopril',
            dosage: '10 mg',
            frequency: MedicationFrequency.onceDaily,
            startDate: DateTime(2026, 1, 1),
            instructions: 'Take 1 tablet every morning with water',
            reminderTimes: const [],
            isTakenToday: false,
            isMissedToday: true,
            scheduledTimeSlot: '08:00 AM',
            purpose: 'Blood Pressure Control',
          ),
          Medication(
            id: 'med_metformin',
            name: 'Metformin',
            dosage: '500 mg',
            frequency: MedicationFrequency.twiceDaily,
            startDate: DateTime(2026, 1, 1),
            instructions: 'Take with evening meal',
            reminderTimes: const [],
            isTakenToday: false,
            isMissedToday: false,
            scheduledTimeSlot: '08:00 PM',
            purpose: 'Type 2 Diabetes',
          ),
          Medication(
            id: 'med_atorvastatin',
            name: 'Atorvastatin',
            dosage: '20 mg',
            frequency: MedicationFrequency.onceDaily,
            startDate: DateTime(2026, 1, 1),
            instructions: 'Take at bedtime',
            reminderTimes: const [],
            isTakenToday: false,
            isMissedToday: false,
            scheduledTimeSlot: '10:00 PM',
            purpose: 'Cholesterol Management',
          ),
        ],
        appointments: [
          Appointment(
            id: 'apt_vance_1',
            doctorName: 'Dr. Eleanor Vance, MD',
            specialty: 'Cardiology',
            clinicName: 'St. Jude Heart Center',
            clinicAddress: '450 Health Ave, Suite 300',
            dateTime: DateTime(2026, 10, 28, 10, 30),
            formattedTime: '10:30 AM',
            formattedDate: 'Wednesday, Oct 28',
            visitType: 'In-Person Visit',
            prepInstructions: 'Fast 4 hours prior. Bring recent BP log.',
            contactPhone: '(555) 349-8800',
          ),
          Appointment(
            id: 'apt_endocrinology',
            doctorName: 'Dr. Marcus Reid, MD',
            specialty: 'Endocrinology',
            clinicName: 'Metabolic Care Clinic',
            clinicAddress: '120 Medical Blvd, Room 210',
            dateTime: DateTime(2026, 11, 12, 14, 0),
            formattedTime: '02:00 PM',
            formattedDate: 'Thursday, Nov 12',
            visitType: 'Video Consultation',
            prepInstructions: 'Have glucose meter and 7-day readings ready.',
            contactPhone: '(555) 890-1234',
          ),
        ],
        activeMissedDose: const MissedDoseAlert(
          id: 'alert_lisinopril_1',
          medicationName: 'Lisinopril',
          dosage: '10 mg',
          scheduledTime: '08:00 AM',
          patientName: 'Sarah Jenkins',
          patientPhone: '(555) 234-9988',
          isAcknowledged: false,
          isFollowUpComplete: false,
        ),
        refillAlerts: const [
          RefillAlert(
            id: 'refill_atorvastatin',
            medicationName: 'Atorvastatin 20 mg',
            dosage: '20 mg',
            daysLeft: 4,
            pillsRemaining: 4,
          ),
        ],
      ),
      const CaregiverLinkedPatient(
        id: 'patient_robert',
        name: 'Robert Chen',
        relationship: 'Father-in-law',
        age: 74,
        gender: 'Male',
        mrn: 'MRN-592180',
        phone: '(555) 781-9922',
        linkStatus: CaregiverLinkStatus.pending,
        linkedSince: 'Oct 21, 2026',
        medications: [],
        appointments: [],
        activeMissedDose: null,
        refillAlerts: [],
      ),
      const CaregiverLinkedPatient(
        id: 'patient_arthur',
        name: 'Arthur Miller',
        relationship: 'Uncle',
        age: 79,
        gender: 'Male',
        mrn: 'MRN-102941',
        phone: '(555) 441-2099',
        linkStatus: CaregiverLinkStatus.revoked,
        linkedSince: 'Aug 10, 2026',
        medications: [],
        appointments: [],
        activeMissedDose: null,
        refillAlerts: [],
      ),
    ];
  }
}
