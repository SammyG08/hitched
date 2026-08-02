import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/api_exception.dart';
import '../../../shared/widgets/submit_button.dart';
import '../domain/guest_models.dart';
import 'guest_controller.dart';

class GuestFormScreen extends ConsumerStatefulWidget {
  const GuestFormScreen({this.guestId, this.initialHouseholdId, super.key});

  final int? guestId;
  final int? initialHouseholdId;

  @override
  ConsumerState<GuestFormScreen> createState() => _GuestFormScreenState();
}

class _GuestFormScreenState extends ConsumerState<GuestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _dietary;
  late final TextEditingController _table;
  late final TextEditingController _notes;
  int? _householdId;
  int? _plusOneOfId;
  GuestRsvpStatus _rsvp = GuestRsvpStatus.pending;

  @override
  void initState() {
    super.initState();
    final guest = widget.guestId == null
        ? null
        : ref.read(guestListProvider.notifier).guestById(widget.guestId!);
    _firstName = TextEditingController(text: guest?.firstName ?? '');
    _lastName = TextEditingController(text: guest?.lastName ?? '');
    _email = TextEditingController(text: guest?.email ?? '');
    _phone = TextEditingController(text: guest?.phone ?? '');
    _dietary = TextEditingController(text: guest?.dietaryRequirements ?? '');
    _table = TextEditingController(text: guest?.tableName ?? '');
    _notes = TextEditingController(text: guest?.notes ?? '');
    _householdId = guest?.householdId ?? widget.initialHouseholdId;
    _plusOneOfId = guest?.plusOneOf?.id;
    _rsvp = guest?.rsvpStatus ?? GuestRsvpStatus.pending;
  }

  @override
  void dispose() {
    for (final controller in [
      _firstName,
      _lastName,
      _email,
      _phone,
      _dietary,
      _table,
      _notes,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _householdId == null) return;
    final succeeded = await ref
        .read(guestListProvider.notifier)
        .saveGuest(
          guestId: widget.guestId,
          draft: GuestDraft(
            householdId: _householdId!,
            firstName: _firstName.text,
            lastName: _lastName.text,
            email: _email.text,
            phone: _phone.text,
            plusOneOfId: _plusOneOfId,
            rsvpStatus: _rsvp,
            dietaryRequirements: _dietary.text,
            tableName: _table.text,
            notes: _notes.text,
          ),
        );
    if (succeeded && mounted) {
      context.pop();
      return;
    }
    if (mounted) {
      final error = ref.read(guestListProvider).value?.actionError;
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
    final state = ref.watch(guestListProvider).value;
    final households = state?.households ?? const <GuestHousehold>[];
    final plusOneCandidates =
        state?.guests.where((guest) {
          if (guest.householdId != _householdId || guest.isPlusOne) {
            return false;
          }
          if (guest.id == widget.guestId) return false;
          return !state.guests.any(
            (item) =>
                item.plusOneOf?.id == guest.id && item.id != widget.guestId,
          );
        }).toList() ??
        const <WeddingGuest>[];
    final editing = widget.guestId != null;

    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Edit guest' : 'New guest')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: _householdId,
                  decoration: const InputDecoration(labelText: 'Household'),
                  items: households
                      .map(
                        (household) => DropdownMenuItem(
                          value: household.id,
                          child: Text(household.name),
                        ),
                      )
                      .toList(),
                  onChanged: (id) => setState(() {
                    _householdId = id;
                    _plusOneOfId = null;
                  }),
                  validator: (value) =>
                      value == null ? 'Choose a household.' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int?>(
                  initialValue: _plusOneOfId,
                  decoration: const InputDecoration(labelText: 'Plus-one for'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Primary guest'),
                    ),
                    ...plusOneCandidates.map(
                      (guest) => DropdownMenuItem<int?>(
                        value: guest.id,
                        child: Text(guest.fullName),
                      ),
                    ),
                  ],
                  onChanged: (id) => setState(() => _plusOneOfId = id),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstName,
                        decoration: const InputDecoration(
                          labelText: 'First name',
                        ),
                        validator: (value) =>
                            _plusOneOfId == null &&
                                (value == null || value.trim().isEmpty)
                            ? 'Required.'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lastName,
                        decoration: const InputDecoration(
                          labelText: 'Last name',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<GuestRsvpStatus>(
                  initialValue: _rsvp,
                  decoration: const InputDecoration(labelText: 'RSVP'),
                  items: GuestRsvpStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.label),
                        ),
                      )
                      .toList(),
                  onChanged: (status) {
                    if (status != null) setState(() => _rsvp = status);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dietary,
                  decoration: const InputDecoration(
                    labelText: 'Dietary requirements',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _table,
                  decoration: const InputDecoration(labelText: 'Table name'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notes,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
                const SizedBox(height: 28),
                SubmitButton(
                  label: editing ? 'Save guest' : 'Create guest',
                  isLoading: state?.isMutating ?? false,
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
