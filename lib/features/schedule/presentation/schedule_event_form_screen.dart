import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/api_exception.dart';
import '../../../shared/widgets/submit_button.dart';
import '../../weddings/domain/wedding.dart';
import '../../weddings/presentation/wedding_workspace_controller.dart';
import '../domain/schedule_models.dart';
import 'schedule_controller.dart';

class ScheduleEventFormScreen extends ConsumerStatefulWidget {
  const ScheduleEventFormScreen({this.eventId, super.key});

  final int? eventId;

  @override
  ConsumerState<ScheduleEventFormScreen> createState() =>
      _ScheduleEventFormScreenState();
}

class _ScheduleEventFormScreenState
    extends ConsumerState<ScheduleEventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late final TextEditingController _notesController;
  late ScheduleEventType _eventType;
  late ScheduleEventStatus _status;
  late DateTime _startAt;
  late DateTime _endAt;
  int? _responsibleMemberId;
  int? _vendorId;

  bool get _isEditing => widget.eventId != null;

  @override
  void initState() {
    super.initState();
    final state = ref.read(scheduleProvider).value;
    final event = widget.eventId == null
        ? null
        : state?.events.where((item) => item.id == widget.eventId).firstOrNull;
    final weddingDate = ref
        .read(weddingWorkspaceProvider)
        .value
        ?.selectedWedding
        ?.weddingDate;
    final initialStart = _initialStart(weddingDate);
    _titleController = TextEditingController(text: event?.title ?? '');
    _locationController = TextEditingController(text: event?.location ?? '');
    _notesController = TextEditingController(text: event?.notes ?? '');
    _eventType = event?.eventType ?? ScheduleEventType.other;
    _status = event?.status ?? ScheduleEventStatus.planned;
    _startAt = event?.startAt ?? initialStart;
    _endAt = event?.endAt ?? initialStart.add(const Duration(hours: 1));
    _responsibleMemberId = event?.responsibleMember?.id;
    _vendorId = event?.vendor?.id;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  DateTime _initialStart(DateTime? weddingDate) {
    final now = DateTime.now();
    final date = weddingDate ?? now.add(const Duration(days: 1));
    return DateTime(date.year, date.month, date.day, 9);
  }

  Future<DateTime?> _chooseDateTime(DateTime current) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 15),
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _chooseStart() async {
    final value = await _chooseDateTime(_startAt);
    if (value == null) return;
    setState(() {
      final duration = _endAt.difference(_startAt);
      _startAt = value;
      _endAt = value.add(
        duration.isNegative || duration == Duration.zero
            ? const Duration(hours: 1)
            : duration,
      );
    });
  }

  Future<void> _chooseEnd() async {
    final value = await _chooseDateTime(_endAt);
    if (value != null) setState(() => _endAt = value);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_endAt.isAfter(_startAt)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be later than start time.'),
        ),
      );
      return;
    }
    final succeeded = await ref
        .read(scheduleProvider.notifier)
        .saveEvent(
          eventId: widget.eventId,
          draft: ScheduleEventDraft(
            title: _titleController.text,
            eventType: _eventType,
            startAt: _startAt,
            endAt: _endAt,
            location: _locationController.text,
            status: _status,
            responsibleMemberId: _responsibleMemberId,
            vendorId: _vendorId,
            notes: _notesController.text,
          ),
        );
    if (succeeded && mounted) {
      context.pop();
      return;
    }
    if (mounted) {
      final error = ref.read(scheduleProvider).value?.actionError;
      final message = error is ApiException
          ? error.displayMessage
          : error.toString();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleState = ref.watch(scheduleProvider).value;
    final wedding = ref.watch(weddingWorkspaceProvider).value?.selectedWedding;
    final members = wedding?.members ?? const <WeddingMember>[];
    final vendors = scheduleState?.vendors ?? const <ScheduleVendorReference>[];
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit event' : 'Add event')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  autofocus: !_isEditing,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Event title',
                    hintText: 'Wedding ceremony',
                    prefixIcon: Icon(Icons.event_note_outlined),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter an event title.'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ScheduleEventType>(
                  initialValue: _eventType,
                  decoration: const InputDecoration(labelText: 'Event type'),
                  items: ScheduleEventType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.label),
                        ),
                      )
                      .toList(),
                  onChanged: (type) {
                    if (type != null) setState(() => _eventType = type);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ScheduleEventStatus>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: ScheduleEventStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.label),
                        ),
                      )
                      .toList(),
                  onChanged: (status) {
                    if (status != null) setState(() => _status = status);
                  },
                ),
                const SizedBox(height: 24),
                _DateTimeField(
                  label: 'Starts',
                  value: _startAt,
                  onTap: _chooseStart,
                ),
                const SizedBox(height: 16),
                _DateTimeField(
                  label: 'Ends',
                  value: _endAt,
                  onTap: _chooseEnd,
                  errorText: _endAt.isAfter(_startAt)
                      ? null
                      : 'Must be later than start time',
                ),
                const SizedBox(height: 8),
                Text(
                  'Duration: ${_duration(_endAt.difference(_startAt))}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _locationController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int?>(
                  initialValue: _responsibleMemberId,
                  decoration: const InputDecoration(
                    labelText: 'Responsible member',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Unassigned'),
                    ),
                    ...members.map(
                      (member) => DropdownMenuItem<int?>(
                        value: member.id,
                        child: Text(member.user.displayName),
                      ),
                    ),
                  ],
                  onChanged: (memberId) {
                    setState(() => _responsibleMemberId = memberId);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int?>(
                  initialValue: _vendorId,
                  decoration: const InputDecoration(
                    labelText: 'Vendor',
                    prefixIcon: Icon(Icons.storefront_outlined),
                    helperText: 'Hitched prevents overlapping vendor bookings.',
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('No vendor'),
                    ),
                    ...vendors.map(
                      (vendor) => DropdownMenuItem<int?>(
                        value: vendor.id,
                        child: Text(vendor.name),
                      ),
                    ),
                  ],
                  onChanged: (vendorId) => setState(() => _vendorId = vendorId),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  minLines: 4,
                  maxLines: 7,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 28),
                SubmitButton(
                  label: _isEditing ? 'Save event' : 'Create event',
                  isLoading: scheduleState?.isMutating ?? false,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DateTimeField extends StatelessWidget {
  const _DateTimeField({
    required this.label,
    required this.value,
    required this.onTap,
    this.errorText,
  });

  final String label;
  final DateTime value;
  final VoidCallback onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(value));
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_month_outlined),
          errorText: errorText,
        ),
        child: Text('${_date(value)} at $time'),
      ),
    );
  }
}

String _date(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

String _duration(Duration duration) {
  if (duration.isNegative || duration == Duration.zero) return 'Invalid';
  final minutes = duration.inMinutes;
  final hours = minutes ~/ 60;
  final remainder = minutes % 60;
  if (hours == 0) return '$remainder min';
  return remainder == 0 ? '$hours hr' : '$hours hr $remainder min';
}
