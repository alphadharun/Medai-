/// Represents an upcoming or historical healthcare appointment.
class Appointment {
  final String id;
  final String doctorName;
  final String specialty;
  final String clinicName;
  final String clinicAddress;
  final DateTime dateTime;
  final String formattedTime;
  final String formattedDate;
  final String visitType; // "In-Person Visit" or "Video Consultation"
  final String prepInstructions;
  final String contactPhone;
  final bool isConfirmed;

  const Appointment({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.clinicName,
    required this.clinicAddress,
    required this.dateTime,
    required this.formattedTime,
    required this.formattedDate,
    this.visitType = 'In-Person Visit',
    required this.prepInstructions,
    this.contactPhone = '(555) 349-8800',
    this.isConfirmed = true,
  });

  Appointment copyWith({
    String? id,
    String? doctorName,
    String? specialty,
    String? clinicName,
    String? clinicAddress,
    DateTime? dateTime,
    String? formattedTime,
    String? formattedDate,
    String? visitType,
    String? prepInstructions,
    String? contactPhone,
    bool? isConfirmed,
  }) {
    return Appointment(
      id: id ?? this.id,
      doctorName: doctorName ?? this.doctorName,
      specialty: specialty ?? this.specialty,
      clinicName: clinicName ?? this.clinicName,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      dateTime: dateTime ?? this.dateTime,
      formattedTime: formattedTime ?? this.formattedTime,
      formattedDate: formattedDate ?? this.formattedDate,
      visitType: visitType ?? this.visitType,
      prepInstructions: prepInstructions ?? this.prepInstructions,
      contactPhone: contactPhone ?? this.contactPhone,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }
}
