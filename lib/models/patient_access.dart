/// Access request status lifecycle.
enum AccessRequestStatus {
  notRequested,
  pending,
  approved,
  declined,
}

/// Represents a mock patient for doctor access requests.
class MockPatientProfile {
  final String id;
  final String name;
  final String mrn; // Medical Record Number
  final int age;
  final String gender;
  final String bloodType;
  final bool hasAuthorizedCaregiver;
  final String? caregiverName;
  final String? caregiverRelationship;
  final String? caregiverPhone;
  final List<String> activeConditions;
  final List<String> currentMedications;
  final String recentVitals;

  const MockPatientProfile({
    required this.id,
    required this.name,
    required this.mrn,
    required this.age,
    required this.gender,
    required this.bloodType,
    required this.hasAuthorizedCaregiver,
    this.caregiverName,
    this.caregiverRelationship,
    this.caregiverPhone,
    required this.activeConditions,
    required this.currentMedications,
    required this.recentVitals,
  });
}

/// Pre-populated mock patients for access requests.
class MockPatientDirectory {
  static const List<MockPatientProfile> patients = [
    MockPatientProfile(
      id: 'patient_sarah',
      name: 'Sarah Jenkins',
      mrn: 'MRN-849201',
      age: 68,
      gender: 'Female',
      bloodType: 'A+',
      hasAuthorizedCaregiver: true,
      caregiverName: 'Mark Jenkins',
      caregiverRelationship: 'Son (Authorized for alerts only)',
      caregiverPhone: '(555) 234-9988',
      activeConditions: [
        'Essential Hypertension (I10)',
        'Type 2 Diabetes Mellitus without complications (E11.9)',
        'Hyperlipidemia (E78.5)',
      ],
      currentMedications: [
        'Metformin 500 mg - Twice daily with meals',
        'Lisinopril 10 mg - Once daily in morning',
        'Atorvastatin 20 mg - Once daily at bedtime',
      ],
      recentVitals: 'BP: 128/82 mmHg • HR: 72 bpm • SpO2: 98% • HbA1c: 6.8%',
    ),
    MockPatientProfile(
      id: 'patient_robert',
      name: 'Robert Chen',
      mrn: 'MRN-592180',
      age: 74,
      gender: 'Male',
      bloodType: 'O+',
      hasAuthorizedCaregiver: false, // Caregiver NOT authorized
      caregiverName: null,
      caregiverRelationship: null,
      caregiverPhone: null,
      activeConditions: [
        'Atrial Fibrillation (I48.0)',
        'Mild Cognitive Impairment (G31.84)',
      ],
      currentMedications: [
        'Apixaban (Eliquis) 5 mg - Twice daily',
        'Metoprolol Tartrate 25 mg - Twice daily',
      ],
      recentVitals: 'BP: 134/86 mmHg • HR: 68 bpm (irregular) • SpO2: 97%',
    ),
    MockPatientProfile(
      id: 'patient_elena',
      name: 'Elena Rostova',
      mrn: 'MRN-310492',
      age: 52,
      gender: 'Female',
      bloodType: 'B+',
      hasAuthorizedCaregiver: true,
      caregiverName: 'Anna Rostova',
      caregiverRelationship: 'Daughter (Authorized for alerts only)',
      caregiverPhone: '(555) 782-1133',
      activeConditions: [
        'Asthma, uncomplicated (J45.909)',
        'Migraine without aura (G43.009)',
      ],
      currentMedications: [
        'Fluticasone/Salmeterol 250/50 mcg - 1 puff twice daily',
        'Albuterol HFA 90 mcg - 2 puffs PRN shortness of breath',
      ],
      recentVitals: 'BP: 118/76 mmHg • HR: 76 bpm • SpO2: 99%',
    ),
  ];
}
