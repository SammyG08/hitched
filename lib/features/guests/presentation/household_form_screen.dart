import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/api_exception.dart';
import '../../../shared/widgets/submit_button.dart';
import '../domain/guest_models.dart';
import 'guest_controller.dart';

class HouseholdFormScreen extends ConsumerStatefulWidget {
  const HouseholdFormScreen({this.householdId, super.key});

  final int? householdId;

  @override
  ConsumerState<HouseholdFormScreen> createState() =>
      _HouseholdFormScreenState();
}

class _HouseholdFormScreenState extends ConsumerState<HouseholdFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  InvitationStatus _status = InvitationStatus.notSent;

  @override
  void initState() {
    super.initState();
    final household = widget.householdId == null
        ? null
        : ref
              .read(guestListProvider.notifier)
              .householdById(widget.householdId!);
    _name = TextEditingController(text: household?.name ?? '');
    _email = TextEditingController(text: household?.contactEmail ?? '');
    _phone = TextEditingController(text: household?.contactPhone ?? '');
    _address = TextEditingController(text: household?.address ?? '');
    _status = household?.invitationStatus ?? InvitationStatus.notSent;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final succeeded = await ref
        .read(guestListProvider.notifier)
        .saveHousehold(
          householdId: widget.householdId,
          draft: HouseholdDraft(
            name: _name.text,
            contactEmail: _email.text,
            contactPhone: _phone.text,
            address: _address.text,
            invitationStatus: _status,
          ),
        );
    if (succeeded && mounted) {
      context.pop();
      return;
    }
    if (mounted) _showError();
  }

  void _showError() {
    final error = ref.read(guestListProvider).value?.actionError;
    final message = error is ApiException
        ? error.displayMessage
        : error.toString();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(guestListProvider).value?.isMutating ?? false;
    final editing = widget.householdId != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Edit household' : 'New household')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _name,
                  autofocus: !editing,
                  decoration: const InputDecoration(
                    labelText: 'Household name',
                    hintText: 'The Morgan Family',
                    prefixIcon: Icon(Icons.home_outlined),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a household name.'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Contact email'),
                  validator: (value) =>
                      value != null && value.isNotEmpty && !value.contains('@')
                      ? 'Enter a valid email address.'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Contact phone'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _address,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Postal address',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<InvitationStatus>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Invitation'),
                  items: InvitationStatus.values
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
                const SizedBox(height: 28),
                SubmitButton(
                  label: editing ? 'Save household' : 'Create household',
                  isLoading: isSaving,
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
