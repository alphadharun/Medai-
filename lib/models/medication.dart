import 'package:flutter/material.dart';

/// Frequency options for medications.
enum MedicationFrequency {
  onceDaily('Once daily', 'Every 24 hours'),
  twiceDaily('Twice daily', 'Morning & Evening'),
  threeTimesDaily('Three times daily', 'With meals'),
  fourTimesDaily('Four times daily', 'Every 6 hours'),
  asNeeded('As needed (PRN)', 'When symptoms occur'),
  weekly('Weekly', 'Once per week');

  final String label;
  final String description;
  const MedicationFrequency(this.label, this.description);
}

/// Status of a dose for today.
enum DoseStatus {
  taken,
  remaining,
  missed,
}

/// Represents a patient's medication entry in MediCare AI.
class Medication {
  final String id;
  final String name;
  final String dosage;
  final MedicationFrequency frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final String instructions;
  final List<TimeOfDay> reminderTimes;
  final bool isTakenToday;
  final bool isMissedToday;
  final DateTime? takenAt;
  final String scheduledTimeSlot; // e.g. "08:00 AM", "12:30 PM", "08:00 PM"
  final String purpose; // e.g. "Blood pressure", "Blood sugar management"

  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.instructions,
    required this.reminderTimes,
    this.isTakenToday = false,
    this.isMissedToday = false,
    this.takenAt,
    required this.scheduledTimeSlot,
    this.purpose = 'Prescription medication',
  });

  DoseStatus get todayStatus {
    if (isTakenToday) return DoseStatus.taken;
    if (isMissedToday) return DoseStatus.missed;
    return DoseStatus.remaining;
  }

  Medication copyWith({
    String? id,
    String? name,
    String? dosage,
    MedicationFrequency? frequency,
    DateTime? startDate,
    DateTime? endDate,
    String? instructions,
    List<TimeOfDay>? reminderTimes,
    bool? isTakenToday,
    bool? isMissedToday,
    DateTime? takenAt,
    String? scheduledTimeSlot,
    String? purpose,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      instructions: instructions ?? this.instructions,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      isTakenToday: isTakenToday ?? this.isTakenToday,
      isMissedToday: isMissedToday ?? this.isMissedToday,
      takenAt: takenAt ?? this.takenAt,
      scheduledTimeSlot: scheduledTimeSlot ?? this.scheduledTimeSlot,
      purpose: purpose ?? this.purpose,
    );
  }
}
