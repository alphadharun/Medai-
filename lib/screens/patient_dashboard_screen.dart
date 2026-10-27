import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/appointment.dart';
import '../models/medication.dart';
import '../theme/app_theme.dart';
import '../widgets/appointment_details_sheet.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/medication_history_sheet.dart';
import '../widgets/next_dose_card.dart';
import '../widgets/prescription_scanner_sheet.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/today_summary_card.dart';
import '../widgets/upcoming_appointment_card.dart';
import 'add_medication_sheet.dart';

/// Main Patient Home Dashboard for MediCare AI.
/// Provides all 7 requested sections and responsive bottom navigation.
class PatientDashboardScreen extends StatefulWidget {
  final VoidCallback? onSignOut;

  const PatientDashboardScreen({
    super.key,
    this.onSignOut,
  });

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  int _selectedTabIndex = 0;
  String _selectedMedicationFilter = 'All';
  String _medicationSearchQuery = '';
  DateTime _selectedMedicationDate = DateTime.now();

  // Local state for medications and appointments (mock demo)
  late List<Medication> _medications;
  late List<Appointment> _appointments;

  @override
  void initState() {
    super.initState();
    _medications = MockData.getInitialMedications();
    _appointments = MockData.getInitialAppointments();
  }

  // Dose summary calculations
  int get _takenCount => _medications.where((m) => m.isTakenToday).length;
  int get _missedCount => _medications.where((m) => m.isMissedToday).length;
  int get _remainingCount =>
      _medications.where((m) => !m.isTakenToday && !m.isMissedToday).length;

  // Find the next upcoming dose for today
  Medication? get _nextDose {
    final remaining =
        _medications.where((m) => !m.isTakenToday && !m.isMissedToday).toList();
    if (remaining.isEmpty) return null;
    return remaining.first;
  }

  // Find upcoming appointment
  Appointment? get _upcomingAppointment {
    if (_appointments.isEmpty) return null;
    return _appointments.first;
  }

  // Handle Mark as Taken
  void _handleTakeDose(Medication med) {
    setState(() {
      final index = _medications.indexWhere((m) => m.id == med.id);
      if (index != -1) {
        _medications[index] = _medications[index].copyWith(
          isTakenToday: true,
          isMissedToday: false,
          takenAt: DateTime.now(),
        );
      }
    });

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
                'Marked ${med.name} ${med.dosage} as taken!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Handle Snooze Dose
  void _handleSnoozeDose(Medication med) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Snoozed ${med.name} reminder for 15 minutes.'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Handle Add Medication
  void _openAddMedicationSheet({
    String? initialName,
    String? initialDosage,
    String? initialInstructions,
  }) {
    AddMedicationSheet.show(
      context,
      initialName: initialName,
      initialDosage: initialDosage,
      initialInstructions: initialInstructions,
      onMedicationAdded: (newMed) {
        setState(() {
          _medications.insert(0, newMed);
        });
      },
    );
  }

  // Handle Scan Prescription
  void _openScanPrescriptionSheet() {
    PrescriptionScannerSheet.show(
      context,
      onAddExtractedMedication: () {
        _openAddMedicationSheet(
          initialName: 'Amlodipine',
          initialDosage: '5 mg',
          initialInstructions: 'Take 1 tablet daily in the morning with water',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedTabIndex,
          children: [
            _buildHomeTab(),
            _buildMedicationsTab(),
            _buildAppointmentsTab(),
            _buildProfileTab(),
          ],
        ),
      ),
      // Section 6: Bottom Navigation with high contrast and clear active state
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          border: const Border(
            top: BorderSide(color: AppTheme.cardBorder, width: 1.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedTabIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedTabIndex = index);
          },
          backgroundColor: AppTheme.surfaceWhite,
          indicatorColor: AppTheme.primaryTealLight,
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              key: Key('nav_destination_home'),
              icon: Icon(Icons.home_outlined),
              selectedIcon:
                  Icon(Icons.home_rounded, color: AppTheme.primaryTeal),
              label: 'Home',
            ),
            NavigationDestination(
              key: Key('nav_destination_medications'),
              icon: Icon(Icons.medication_outlined),
              selectedIcon:
                  Icon(Icons.medication_rounded, color: AppTheme.primaryTeal),
              label: 'Medications',
            ),
            NavigationDestination(
              key: Key('nav_destination_appointments'),
              icon: Icon(Icons.calendar_today_outlined),
              selectedIcon:
                  Icon(Icons.calendar_today_rounded, color: AppTheme.primaryTeal),
              label: 'Appointments',
            ),
            NavigationDestination(
              key: Key('nav_destination_profile'),
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon:
                  Icon(Icons.person_rounded, color: AppTheme.primaryTeal),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 0: HOME DASHBOARD (Sections 1 to 5)
  // ==========================================
  Widget _buildHomeTab() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 600));
            setState(() {
              _medications = MockData.getInitialMedications();
            });
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Header (Greeting, patient name, profile/settings)
                DashboardHeader(
                  patientName: MockData.patientName,
                  onProfilePressed: () {
                    setState(() => _selectedTabIndex = 3);
                  },
                ),

                const SizedBox(height: 16),

                // 2. Today's Medication Summary (Taken, Remaining, Missed)
                TodaySummaryCard(
                  takenCount: _takenCount,
                  remainingCount: _remainingCount,
                  missedCount: _missedCount,
                  onTap: () {
                    setState(() => _selectedTabIndex = 1);
                  },
                ),

                const SizedBox(height: 16),

                // 3. Next Dose Card (Medicine, dosage, time, reminder, actions)
                NextDoseCard(
                  nextDose: _nextDose,
                  onTakeDose: _handleTakeDose,
                  onSnoozeDose: _handleSnoozeDose,
                ),

                const SizedBox(height: 18),

                // 4. Quick Actions Grid (Scan Rx, Add Med, Schedule, History)
                QuickActionsGrid(
                  onScanPrescription: _openScanPrescriptionSheet,
                  onAddMedication: () => _openAddMedicationSheet(),
                  onViewSchedule: () {
                    setState(() => _selectedTabIndex = 1);
                  },
                  onViewHistory: () {
                    MedicationHistorySheet.show(context);
                  },
                ),

                const SizedBox(height: 18),

                // 5. Upcoming Appointment (Doctor, specialty, date, time, details)
                UpcomingAppointmentCard(
                  appointment: _upcomingAppointment,
                  onDetailsPressed: (apt) {
                    AppointmentDetailsSheet.show(context, apt);
                  },
                  onBookAppointment: () {
                    setState(() => _selectedTabIndex = 2);
                  },
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: MEDICATIONS TAB (Full Schedule & List)
  // ==========================================
Widget _buildMedicationsTab() {
    final query = _medicationSearchQuery.trim().toLowerCase();
    final visibleMedications = _medications.where((medication) {
      final matchesQuery = query.isEmpty ||
          medication.name.toLowerCase().contains(query) ||
          medication.dosage.toLowerCase().contains(query) ||
          medication.purpose.toLowerCase().contains(query);
      final matchesCategory = _selectedMedicationFilter == 'All' ||
          _medicationCategory(medication) == _selectedMedicationFilter;
      return matchesQuery && matchesCategory;
    }).toList();
    final isToday = _isSelectedMedicationDateToday;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MEDICARE',
                          style: TextStyle(
                            color: AppTheme.primaryTeal,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Medications',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    key: const Key('tab_add_medication_button'),
                    onPressed: () => _openAddMedicationSheet(),
                    icon: const Icon(Icons.add_rounded, size: 19),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      minimumSize: const Size(0, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildMedicationWeekStrip(),
              const SizedBox(height: 14),
              TextField(
                onChanged: (value) =>
                    setState(() => _medicationSearchQuery = value),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search your medications or doctors...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _medicationSearchQuery.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () => setState(
                            () => _medicationSearchQuery = '',
                          ),
                          icon: const Icon(Icons.close_rounded),
                        ),
                  filled: true,
                  fillColor: AppTheme.surfaceWhite,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              _buildMedicationCategoryFilters(),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.event_note_rounded,
                    size: 18,
                    color: AppTheme.primaryTeal,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      isToday
                          ? 'Today · $_takenCount of ${_medications.length} taken'
                          : 'Medication plan · ${_weekdayLabel(_selectedMedicationDate)}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (_selectedMedicationFilter != 'All')
                    Text(
                      '${visibleMedications.length} shown',
                      style: const TextStyle(
                        color: AppTheme.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: visibleMedications.isEmpty
                    ? Center(
                        child: Text(
                          _medications.isEmpty
                              ? 'No medications yet. Add one to build your schedule.'
                              : 'No medications match this search or time filter.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 14),
                        itemCount: visibleMedications.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) =>
                            _buildMedicationListTile(
                          visibleMedications[index],
                          showTodayStatus: isToday,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicationWeekStrip() {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);

    return SizedBox(
      height: 68,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final date = startOfToday.add(Duration(days: index));
          final selected = date.year == _selectedMedicationDate.year &&
              date.month == _selectedMedicationDate.month &&
              date.day == _selectedMedicationDate.day;
          return InkWell(
            key: Key('medication_day_${date.day}'),
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _selectedMedicationDate = date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 54,
              decoration: BoxDecoration(
                color: selected
                    ? AppTheme.primaryTeal
                    : AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? AppTheme.primaryTeal : AppTheme.cardBorder,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryTeal.withValues(alpha: 0.18),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekdays[date.weekday - 1],
                    style: TextStyle(
                      color: selected ? Colors.white70 : AppTheme.textTertiary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      color: selected ? Colors.white : AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMedicationCategoryFilters() {
    const categories = ['All', 'Morning', 'Afternoon', 'Bedtime'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final selected = _selectedMedicationFilter == category;
          final count = category == 'All'
              ? _medications.length
              : _medications
                  .where((medication) =>
                      _medicationCategory(medication) == category)
                  .length;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              key: Key('medication_filter_${category.toLowerCase()}'),
              selected: selected,
              showCheckmark: false,
              label: Text('$category ($count)'),
              labelStyle: TextStyle(
                color: selected ? Colors.white : AppTheme.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              selectedColor: AppTheme.primaryTeal,
              backgroundColor: AppTheme.surfaceWhite,
              side: BorderSide(
                color: selected ? AppTheme.primaryTeal : AppTheme.cardBorder,
              ),
              onSelected: (_) =>
                  setState(() => _selectedMedicationFilter = category),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _medicationCategory(Medication medication) {
    final time = medication.reminderTimes.isEmpty
        ? const TimeOfDay(hour: 20, minute: 0)
        : medication.reminderTimes.first;
    if (time.hour < 12) return 'Morning';
    if (time.hour < 17) return 'Afternoon';
    return 'Bedtime';
  }

  bool get _isSelectedMedicationDateToday {
    final now = DateTime.now();
    return _selectedMedicationDate.year == now.year &&
        _selectedMedicationDate.month == now.month &&
        _selectedMedicationDate.day == now.day;
  }

  String _weekdayLabel(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return '${weekdays[date.weekday - 1]}, ${date.month}/${date.day}';
  }

Widget _buildMedicationListTile(
    Medication med, {
    required bool showTodayStatus,
  }) {
    final isTaken = showTodayStatus && med.isTakenToday;
    final isMissed = showTodayStatus && med.isMissedToday;
    final daysRemaining = med.endDate?.difference(DateTime.now()).inDays;
    final needsRefill = daysRemaining != null &&
        daysRemaining >= 0 &&
        daysRemaining <= 10;

    return Container(
      key: Key('medication_list_tile_${med.id}'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isTaken
              ? AppTheme.successGreen.withValues(alpha: 0.28)
              : AppTheme.cardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF28164D).withValues(alpha: 0.045),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isTaken
                      ? const Color(0xFFEAF7EF)
                      : AppTheme.primaryTealLight,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  isTaken
                      ? Icons.check_circle_rounded
                      : Icons.medication_rounded,
                  color: isTaken ? AppTheme.successGreen : AppTheme.primaryTeal,
                  size: 25,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      med.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${med.dosage} · ${med.frequency.label}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _medicationStatusBadge(
                isTaken: isTaken,
                isMissed: isMissed,
                showTodayStatus: showTodayStatus,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F5FC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 18,
                  color: AppTheme.primaryTeal,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_medicationCategory(med)} · ${med.scheduledTimeSlot}',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (isTaken && med.takenAt != null)
                  Text(
                    'Taken ${TimeOfDay.fromDateTime(med.takenAt!).format(context)}',
                    style: const TextStyle(
                      color: AppTheme.successGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          if (med.instructions.isNotEmpty) ...[
            const SizedBox(height: 11),
            Text(
              med.instructions,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ],
          if (needsRefill) ...[
            const SizedBox(height: 11),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5E8),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFF9A5700),
                    size: 17,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'Refill reminder · ${daysRemaining == 0 ? "ends today" : "$daysRemaining days remaining"}',
                      style: const TextStyle(
                        color: Color(0xFF754000),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (showTodayStatus && !isTaken && !isMissed) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleTakeDose(med),
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                    label: const Text('Log Dose Now'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 46),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _handleSnoozeDose(med),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(48, 46),
                    padding: const EdgeInsets.symmetric(horizontal: 11),
                    side: BorderSide(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.25),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: const Icon(Icons.snooze_rounded, size: 20),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _medicationStatusBadge({
    required bool isTaken,
    required bool isMissed,
    required bool showTodayStatus,
  }) {
    final label = !showTodayStatus
        ? 'Scheduled'
        : isTaken
            ? 'Taken'
            : isMissed
                ? 'Missed'
                : 'Pending dose';
    final foreground = !showTodayStatus
        ? AppTheme.primaryTeal
        : isTaken
            ? AppTheme.successGreen
            : isMissed
                ? AppTheme.errorRed
                : AppTheme.primaryTeal;
    final background = !showTodayStatus
        ? AppTheme.primaryTealLight
        : isTaken
            ? const Color(0xFFEAF7EF)
            : isMissed
                ? AppTheme.errorContainer
                : AppTheme.primaryTealLight;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildEmptyMedicationsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppTheme.primaryTealLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.medication_rounded,
              size: 48,
              color: AppTheme.primaryTeal,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No medications registered yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap "Add Med" or "Scan Prescription" to start tracking.',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _openAddMedicationSheet(),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Your First Medication'),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: APPOINTMENTS TAB
  // ==========================================
  Widget _buildAppointmentsTab() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    child: Text(
                      'Appointments',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Appointment booking system online (Demo).'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Book Visit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryTeal,
                      minimumSize: const Size(100, 42),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: _appointments.isEmpty
                    ? _buildEmptyAppointmentsView()
                    : ListView.separated(
                        itemCount: _appointments.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final apt = _appointments[index];
                          return UpcomingAppointmentCard(
                            appointment: apt,
                            onDetailsPressed: (a) {
                              AppointmentDetailsSheet.show(context, a);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyAppointmentsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFF0F5F4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_available_rounded,
              size: 48,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No upcoming appointments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'You are all caught up on your routine checkups.',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: PROFILE & SETTINGS TAB
  // ==========================================
  Widget _buildProfileTab() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryTeal,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'SJ',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            MockData.patientName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Age: ${MockData.patientAge} • Blood: ${MockData.bloodType}',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Primary Clinic: Metro Health',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Emergency Contact Tile
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.emergency_rounded,
                      color: AppTheme.errorRed,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Emergency Contact',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            MockData.emergencyContact,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Settings Options
              const Text(
                'Portal Preferences',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              _buildSettingSwitchTile(
                icon: Icons.notifications_active_rounded,
                title: 'Medication Reminders',
                subtitle: 'Audible chime and push reminder 15m prior',
                initialValue: true,
              ),
              const SizedBox(height: 8),
              _buildSettingSwitchTile(
                icon: Icons.contrast_rounded,
                title: 'High Contrast Mode',
                subtitle: 'Optimized readability for low vision',
                initialValue: true,
              ),
              const SizedBox(height: 8),
              _buildSettingSwitchTile(
                icon: Icons.health_and_safety_rounded,
                title: 'Caregiver Sharing',
                subtitle: 'Allow family caregiver to view taken doses',
                initialValue: false,
              ),

              const SizedBox(height: 24),

              // Sign out button
              OutlinedButton.icon(
                key: const Key('profile_sign_out_button'),
                onPressed: () {
                  if (widget.onSignOut != null) {
                    widget.onSignOut!();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: const Text('Sign Out of Patient Portal'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.errorRed,
                  side: const BorderSide(color: AppTheme.errorRed),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool initialValue,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryTeal, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: initialValue,
            activeThumbColor: AppTheme.primaryTeal,
            onChanged: (val) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$title preference updated (Demo).'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
