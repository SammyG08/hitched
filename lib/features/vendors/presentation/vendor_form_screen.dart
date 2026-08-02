import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/api_exception.dart';
import '../../../shared/widgets/submit_button.dart';
import '../domain/vendor_models.dart';
import 'vendor_controller.dart';

class VendorFormScreen extends ConsumerStatefulWidget {
  const VendorFormScreen({this.vendorId, super.key});

  final int? vendorId;

  @override
  ConsumerState<VendorFormScreen> createState() => _VendorFormScreenState();
}

class _VendorFormScreenState extends ConsumerState<VendorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _contactController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _websiteController;
  late final TextEditingController _addressController;
  late final TextEditingController _quoteController;
  late final TextEditingController _notesController;
  late VendorServiceCategory _serviceCategory;
  late VendorBookingStatus _bookingStatus;
  late VendorQuoteStatus _quoteStatus;
  late VendorContractStatus _contractStatus;
  DateTime? _contractSignedAt;

  bool get _isEditing => widget.vendorId != null;

  @override
  void initState() {
    super.initState();
    final vendor = widget.vendorId == null
        ? null
        : ref
              .read(vendorListProvider)
              .value
              ?.vendors
              .where((item) => item.id == widget.vendorId)
              .firstOrNull;
    _nameController = TextEditingController(text: vendor?.name ?? '');
    _contactController = TextEditingController(
      text: vendor?.contactPerson ?? '',
    );
    _emailController = TextEditingController(text: vendor?.email ?? '');
    _phoneController = TextEditingController(text: vendor?.phone ?? '');
    _websiteController = TextEditingController(text: vendor?.website ?? '');
    _addressController = TextEditingController(text: vendor?.address ?? '');
    _quoteController = TextEditingController(
      text: vendor?.quoteAmount?.toStringAsFixed(2) ?? '',
    );
    _notesController = TextEditingController(text: vendor?.notes ?? '');
    _serviceCategory = vendor?.serviceCategory ?? VendorServiceCategory.other;
    _bookingStatus = vendor?.bookingStatus ?? VendorBookingStatus.researching;
    _quoteStatus = vendor?.quoteStatus ?? VendorQuoteStatus.notRequested;
    _contractStatus = vendor?.contractStatus ?? VendorContractStatus.notStarted;
    _contractSignedAt = vendor?.contractSignedAt;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _quoteController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final quoteText = _quoteController.text.trim();
    final succeeded = await ref
        .read(vendorListProvider.notifier)
        .saveVendor(
          vendorId: widget.vendorId,
          draft: VendorDraft(
            name: _nameController.text,
            serviceCategory: _serviceCategory,
            contactPerson: _contactController.text,
            email: _emailController.text,
            phone: _phoneController.text,
            website: _websiteController.text,
            address: _addressController.text,
            bookingStatus: _bookingStatus,
            quoteStatus: _quoteStatus,
            quoteAmount: quoteText.isEmpty ? null : double.parse(quoteText),
            contractStatus: _contractStatus,
            notes: _notesController.text,
          ),
        );
    if (succeeded && mounted) {
      context.pop();
      return;
    }
    if (mounted) {
      final error = ref.read(vendorListProvider).value?.actionError;
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
    final state = ref.watch(vendorListProvider).value;
    final vendor = widget.vendorId == null
        ? null
        : state?.vendors
              .where((item) => item.id == widget.vendorId)
              .firstOrNull;
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit vendor' : 'Add vendor')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _FormSectionTitle('Vendor'),
                TextFormField(
                  controller: _nameController,
                  autofocus: !_isEditing,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Vendor name',
                    prefixIcon: Icon(Icons.storefront_outlined),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a vendor name.'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<VendorServiceCategory>(
                  initialValue: _serviceCategory,
                  decoration: const InputDecoration(labelText: 'Service'),
                  items: VendorServiceCategory.values
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category.label),
                        ),
                      )
                      .toList(),
                  onChanged: (category) {
                    if (category != null) {
                      setState(() => _serviceCategory = category);
                    }
                  },
                ),
                const SizedBox(height: 28),
                const _FormSectionTitle('Contact'),
                TextFormField(
                  controller: _contactController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Contact person',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (email.isEmpty) return null;
                    return email.contains('@')
                        ? null
                        : 'Enter a valid email address.';
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _websiteController,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Website',
                    hintText: 'https://example.com',
                    prefixIcon: Icon(Icons.language_rounded),
                  ),
                  validator: (value) {
                    final website = value?.trim() ?? '';
                    if (website.isEmpty) return null;
                    final uri = Uri.tryParse(website);
                    return uri != null &&
                            (uri.scheme == 'http' || uri.scheme == 'https') &&
                            uri.host.isNotEmpty
                        ? null
                        : 'Enter a complete http or https URL.';
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  minLines: 2,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 28),
                const _FormSectionTitle('Booking and quote'),
                DropdownButtonFormField<VendorBookingStatus>(
                  initialValue: _bookingStatus,
                  decoration: const InputDecoration(
                    labelText: 'Booking status',
                  ),
                  items: VendorBookingStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.label),
                        ),
                      )
                      .toList(),
                  onChanged: (status) {
                    if (status != null) {
                      setState(() => _bookingStatus = status);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<VendorQuoteStatus>(
                  initialValue: _quoteStatus,
                  decoration: const InputDecoration(labelText: 'Quote status'),
                  items: VendorQuoteStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.label),
                        ),
                      )
                      .toList(),
                  onChanged: (status) {
                    if (status != null) setState(() => _quoteStatus = status);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _quoteController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Quote amount',
                    prefixIcon: Icon(Icons.request_quote_outlined),
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return null;
                    final amount = double.tryParse(text);
                    return amount == null || amount < 0
                        ? 'Enter a valid non-negative amount.'
                        : null;
                  },
                ),
                const SizedBox(height: 28),
                const _FormSectionTitle('Contract'),
                DropdownButtonFormField<VendorContractStatus>(
                  initialValue: _contractStatus,
                  decoration: const InputDecoration(
                    labelText: 'Contract status',
                  ),
                  items: VendorContractStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.label),
                        ),
                      )
                      .toList(),
                  onChanged: (status) {
                    if (status != null) {
                      setState(() => _contractStatus = status);
                    }
                  },
                ),
                if (_contractSignedAt != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Signed ${_displayDate(_contractSignedAt!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (vendor != null &&
                    (vendor.actualExpenseTotal > 0 ||
                        vendor.estimatedExpenseTotal > 0)) ...[
                  const SizedBox(height: 24),
                  _ExpenseRollup(vendor: vendor),
                ],
                const SizedBox(height: 28),
                const _FormSectionTitle('Notes'),
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
                  label: _isEditing ? 'Save vendor' : 'Create vendor',
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

class _FormSectionTitle extends StatelessWidget {
  const _FormSectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(label, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _ExpenseRollup extends StatelessWidget {
  const _ExpenseRollup({required this.vendor});

  final WeddingVendor vendor;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Linked budget expenses',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _RollupValue(
                    label: 'Estimated',
                    value: vendor.estimatedExpenseTotal,
                  ),
                ),
                Expanded(
                  child: _RollupValue(
                    label: 'Actual',
                    value: vendor.actualExpenseTotal,
                  ),
                ),
                Expanded(
                  child: _RollupValue(
                    label: 'Paid',
                    value: vendor.paidExpenseTotal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RollupValue extends StatelessWidget {
  const _RollupValue({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 3),
        Text(
          value.toStringAsFixed(2),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

String _displayDate(DateTime date) {
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
