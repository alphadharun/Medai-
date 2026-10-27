import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../theme/app_theme.dart';

enum _EntryStep {
  fillForm,
  review,
}

/// Section 7: Manual Medication Entry Flow
/// Multi-step flow:
/// 1. Form entry with validation (name, dosage, frequency, dates, instructions, reminders).
/// 2. Patient review screen summarizing all entered details.
/// 3. Confirmation and addition to mock data.
class AddMedicationSheet extends StatefulWidget {
  final ValueChanged<Medication> onMedicationAdded;
  final String? initialName;
  final String? initialDosage;
  final String? initialInstructions;

  const AddMedicationSheet({
    super.key,
    required this.onMedicationAdded,
    this.initialName,
    this.initialDosage,
    this.initialInstructions,
  });

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<Medication> onMedicationAdded,
    String? initialName,
    String? initialDosage,
    String? initialInstructions,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddMedicationSheet(
        onMedicationAdded: onMedicationAdded,
        initialName: initialName,
        initialDosage: initialDosage,
        initialInstructions: initialInstructions,
      ),
    );
  }

  @override
  State<AddMedicationSheet> createState() => _AddMedicationSheetState();
}

class _AddMedicationSheetState extends State<AddMedicationSheet> {
  final _formKey = GlobalKey<FormState>();
  _EntryStep _currentStep = _EntryStep.fillForm;

  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  late final TextEditingController _instructionsController;

  MedicationFrequency _selectedFrequency = MedicationFrequency.onceDaily;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isOngoing = true;

  final List<TimeOfDay> _reminderTimes = [
    const TimeOfDay(hour: 8, minute: 0),
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _dosageController = TextEditingController(text: widget.initialDosage ?? '');
    _instructionsController = TextEditingController(
      text: widget.initialInstructions ??
          'Take with a full glass of water after food',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 30));
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
      firstDate: _startDate,
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _isOngoing = false;
      });
    }
  }

  Future<void> _addReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (picked != null && !_reminderTimes.contains(picked)) {
      setState(() {
        _reminderTimes.add(picked);
        _reminderTimes.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
      });
    }
  }

  void _proceedToReview() {
    if (!_formKey.currentState!.validate()) return;
    if (_reminderTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one reminder time.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _currentStep = _EntryStep.review);
  }

  void _confirmAndSave() {
    final newMed = Medication(
      id: 'med_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      dosage: _dosageController.text.trim(),
      frequency: _selectedFrequency,
      startDate: _startDate,
      endDate: _isOngoing ? null : _endDate,
      instructions: _instructionsController.text.trim(),
      reminderTimes: List.from(_reminderTimes),
      scheduledTimeSlot: _formatTime(_reminderTimes.first),
      isTakenToday: false,
      isMissedToday: false,
      purpose: 'Patient added medication',
    );

    widget.onMedicationAdded(newMed);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${newMed.name} ${newMed.dosage} added to your schedule!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Title Banner
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTealLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _currentStep == _EntryStep.fillForm
                      ? Icons.add_circle_outline_rounded
                      : Icons.rate_review_rounded,
                  color: AppTheme.primaryTeal,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentStep == _EntryStep.fillForm
                          ? 'Add New Medication'
                          : 'Review Medication Details',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      _currentStep == _EntryStep.fillForm
                          ? 'Enter prescription dosage and reminder schedule'
                          : 'Confirm details before saving to your daily plan',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Form Content (Scrollable)
          Flexible(
            child: SingleChildScrollView(
              child: _currentStep == _EntryStep.fillForm
                  ? _buildFormView()
                  : _buildReviewView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('form_step'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Medicine Name
          const Text(
            'Medicine Name *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            key: const Key('med_name_input'),
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please enter the medicine name';
              }
              return null;
            },
            decoration: const InputDecoration(
              hintText: 'e.g. Amlodipine, Metformin',
              prefixIcon: Icon(Icons.medication_rounded),
            ),
          ),
          const SizedBox(height: 14),

          // 2. Dosage
          const Text(
            'Dosage & Unit *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            key: const Key('med_dosage_input'),
            controller: _dosageController,
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please enter the dosage (e.g. 10 mg or 1 tablet)';
              }
              return null;
            },
            decoration: const InputDecoration(
              hintText: 'e.g. 10 mg, 500 mg, 1 tablet',
              prefixIcon: Icon(Icons.scale_rounded),
            ),
          ),
          const SizedBox(height: 14),

          // 3. Frequency
          const Text(
            'Frequency *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<MedicationFrequency>(
            key: const Key('med_frequency_dropdown'),
            initialValue: _selectedFrequency,
            isExpanded: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.repeat_rounded),
            ),
            items: MedicationFrequency.values.map((freq) {
              return DropdownMenuItem(
                value: freq,
                child: Text(
                  '${freq.label} (${freq.description})',
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedFrequency = val);
            },
          ),
          const SizedBox(height: 14),

          // 4. Start & End Dates
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Start Date *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      key: const Key('med_start_date_picker'),
                      onTap: _pickStartDate,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceWhite,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.cardBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 18,
                              color: AppTheme.primaryTeal,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _formatDate(_startDate),
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'End Date',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      key: const Key('med_end_date_picker'),
                      onTap: _pickEndDate,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceWhite,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.cardBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.event_busy_rounded,
                              size: 18,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _isOngoing || _endDate == null
                                    ? 'Ongoing'
                                    : _formatDate(_endDate!),
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  color: _isOngoing
                                      ? AppTheme.primaryTeal
                                      : AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 5. Instructions
          const Text(
            'Special Instructions',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            key: const Key('med_instructions_input'),
            controller: _instructionsController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'e.g. Take with food, avoid grapefruit',
              prefixIcon: Icon(Icons.note_alt_outlined),
            ),
          ),
          const SizedBox(height: 14),

          // 6. Reminder Times
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'Reminder Times *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              TextButton.icon(
                key: const Key('add_reminder_time_button'),
                onPressed: _addReminderTime,
                icon: const Icon(Icons.add_alarm_rounded, size: 18),
                label: const Text('Add Time'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryTeal,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _reminderTimes.map((time) {
              return Chip(
                avatar: const Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: AppTheme.primaryTeal,
                ),
                label: Text(
                  _formatTime(time),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryTealDark,
                  ),
                ),
                backgroundColor: AppTheme.primaryTealLight,
                deleteIcon: _reminderTimes.length > 1
                    ? const Icon(Icons.close_rounded, size: 16)
                    : null,
                onDeleted: _reminderTimes.length > 1
                    ? () {
                        setState(() => _reminderTimes.remove(time));
                      }
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: AppTheme.cardBorder),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Action Button to Review
          ElevatedButton(
            key: const Key('proceed_to_review_button'),
            onPressed: _proceedToReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    'Review Medication Details',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewView() {
    return Column(
      key: const ValueKey('review_step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Summary Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FBFB),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTealLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.medication_liquid_rounded,
                      color: AppTheme.primaryTeal,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nameController.text.trim(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'Dosage: ${_dosageController.text.trim()}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: AppTheme.cardBorder),
              ),
              _buildReviewRow('Frequency', _selectedFrequency.label),
              const SizedBox(height: 8),
              _buildReviewRow('Start Date', _formatDate(_startDate)),
              const SizedBox(height: 8),
              _buildReviewRow(
                'End Date',
                _isOngoing || _endDate == null
                    ? 'Ongoing (Active indefinitely)'
                    : _formatDate(_endDate!),
              ),
              const SizedBox(height: 8),
              _buildReviewRow(
                'Instructions',
                _instructionsController.text.trim().isEmpty
                    ? 'None specified'
                    : _instructionsController.text.trim(),
              ),
              const SizedBox(height: 8),
              _buildReviewRow(
                'Reminders',
                _reminderTimes.map((t) => _formatTime(t)).join(', '),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Action Buttons: Edit or Confirm
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                key: const Key('back_to_edit_button'),
                onPressed: () {
                  setState(() => _currentStep = _EntryStep.fillForm);
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Back to Edit'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                key: const Key('confirm_add_medication_button'),
                onPressed: _confirmAndSave,
                icon: const Icon(Icons.check_rounded, size: 20),
                label: const Text('Confirm & Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
