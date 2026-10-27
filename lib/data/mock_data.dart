import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../models/medication.dart';

/// Pre-populated mock data for MediCare AI patient dashboard.
class MockData {
  static const String patientName = 'Sarah Jenkins';
  static const String patientAge = '68';
  static const String bloodType = 'A+';
  static const String primaryDoctor = 'Dr. Eleanor Vance, MD';
  static const String emergencyContact = 'Mark Jenkins (Son) - (555) 234-9988';

  static List<Medication> getInitialMedications() {
    final today = DateTime.now();
    return [
      Medication(
        id: 'med_1',
        name: 'Metformin',
        dosage: '500 mg',
        frequency: MedicationFrequency.twiceDaily,
        startDate: today.subtract(const Duration(days: 60)),
        instructions: 'Take with food to reduce stomach upset',
        reminderTimes: const [
          TimeOfDay(hour: 8, minute: 0),
          TimeOfDay(hour: 18, minute: 30),
        ],
        isTakenToday: true,
        takenAt: DateTime(today.year, today.month, today.day, 8, 15),
        scheduledTimeSlot: '08:00 AM',
        purpose: 'Type 2 Diabetes management',
      ),
      Medication(
        id: 'med_2',
        name: 'Lisinopril',
        dosage: '10 mg',
        frequency: MedicationFrequency.onceDaily,
        startDate: today.subtract(const Duration(days: 90)),
        instructions: 'Take in the morning with a full glass of water',
        reminderTimes: const [
          TimeOfDay(hour: 8, minute: 0),
        ],
        isTakenToday: true,
        takenAt: DateTime(today.year, today.month, today.day, 8, 10),
        scheduledTimeSlot: '08:00 AM',
        purpose: 'Blood pressure control',
      ),
      Medication(
        id: 'med_3',
        name: 'Atorvastatin',
        dosage: '20 mg',
        frequency: MedicationFrequency.onceDaily,
        startDate: today.subtract(const Duration(days: 45)),
        instructions: 'Take in the evening before bedtime',
        reminderTimes: const [
          TimeOfDay(hour: 20, minute: 0),
        ],
        isTakenToday: false,
        isMissedToday: false,
        scheduledTimeSlot: '08:00 PM',
        purpose: 'Cholesterol management',
      ),
      Medication(
        id: 'med_4',
        name: 'Calcium + Vitamin D3',
        dosage: '600 mg / 400 IU',
        frequency: MedicationFrequency.onceDaily,
        startDate: today.subtract(const Duration(days: 30)),
        instructions: 'Take with lunch or an afternoon snack',
        reminderTimes: const [
          TimeOfDay(hour: 13, minute: 0),
        ],
        isTakenToday: false,
        isMissedToday: true, // Example missed dose for realistic summary demo
        scheduledTimeSlot: '01:00 PM',
        purpose: 'Bone density support',
      ),
    ];
  }

  static List<Appointment> getInitialAppointments() {
    final now = DateTime.now();
    return [
      Appointment(
        id: 'apt_1',
        doctorName: 'Dr. Eleanor Vance, MD',
        specialty: 'Cardiology & Vascular Health',
        clinicName: 'Metro Health Pavilion, Suite 402',
        clinicAddress: '742 Evergreen Medical Way, City Center',
        dateTime: now.add(const Duration(days: 6, hours: 2)),
        formattedDate: 'Thursday, Oct 29, 2026',
        formattedTime: '10:30 AM',
        visitType: 'In-Person Consultation',
        prepInstructions:
            'Please fast for 4 hours prior for blood pressure and lipid assessment. Bring all current prescription bottles.',
        contactPhone: '(555) 349-8800',
        isConfirmed: true,
      ),
      Appointment(
        id: 'apt_2',
        doctorName: 'Dr. Marcus Cole, OD',
        specialty: 'Ophthalmology & Diabetic Eye Care',
        clinicName: 'City Vision & Eye Health Center',
        clinicAddress: '120 Health Plaza, Suite 105',
        dateTime: now.add(const Duration(days: 18, hours: 4)),
        formattedDate: 'Wednesday, Nov 11, 2026',
        formattedTime: '02:15 PM',
        visitType: 'In-Person Consultation',
        prepInstructions:
            'Pupil dilation drops will be administered. Please arrange for a designated driver or companion.',
        contactPhone: '(555) 890-4421',
        isConfirmed: true,
      ),
    ];
  }
}
