import 'package:hitched/features/vendors/domain/vendor_models.dart';
import 'package:hitched/features/vendors/domain/vendor_repository.dart';

WeddingVendor vendorFixture({
  int id = 1,
  String name = 'Golden Spoon',
  VendorServiceCategory category = VendorServiceCategory.catering,
  VendorBookingStatus bookingStatus = VendorBookingStatus.shortlisted,
  VendorQuoteStatus quoteStatus = VendorQuoteStatus.received,
  VendorContractStatus contractStatus = VendorContractStatus.reviewing,
  DateTime? contractSignedAt,
}) {
  return WeddingVendor(
    id: id,
    weddingId: 1,
    name: name,
    serviceCategory: category,
    contactPerson: 'Taylor Doe',
    email: 'hello@goldenspoon.example',
    phone: '+233 20 555 0101',
    website: 'https://goldenspoon.example',
    address: 'Accra',
    bookingStatus: bookingStatus,
    quoteStatus: quoteStatus,
    quoteAmount: 4500,
    contractStatus: contractStatus,
    contractSignedAt: contractSignedAt,
    estimatedExpenseTotal: 5000,
    actualExpenseTotal: 4500,
    paidExpenseTotal: 2000,
    notes: 'Tasting scheduled.',
  );
}

class FakeVendorRepository implements VendorRepository {
  final vendors = <WeddingVendor>[vendorFixture()];

  @override
  Future<List<WeddingVendor>> fetchVendors(int weddingId) async =>
      List.unmodifiable(vendors);

  @override
  Future<WeddingVendor> createVendor(int weddingId, VendorDraft draft) async {
    final vendor = _fromDraft(vendors.length + 1, draft);
    vendors.add(vendor);
    return vendor;
  }

  @override
  Future<WeddingVendor> updateVendor(
    int weddingId,
    int vendorId,
    VendorDraft draft,
  ) async {
    final old = vendors.firstWhere((vendor) => vendor.id == vendorId);
    final updated = _fromDraft(vendorId, draft, old: old);
    vendors[vendors.indexOf(old)] = updated;
    return updated;
  }

  @override
  Future<WeddingVendor> updateWorkflow(
    int weddingId,
    int vendorId, {
    VendorBookingStatus? bookingStatus,
    VendorQuoteStatus? quoteStatus,
    VendorContractStatus? contractStatus,
  }) async {
    final old = vendors.firstWhere((vendor) => vendor.id == vendorId);
    final nextContract = contractStatus ?? old.contractStatus;
    final updated = WeddingVendor(
      id: old.id,
      weddingId: old.weddingId,
      name: old.name,
      serviceCategory: old.serviceCategory,
      contactPerson: old.contactPerson,
      email: old.email,
      phone: old.phone,
      website: old.website,
      address: old.address,
      bookingStatus: bookingStatus ?? old.bookingStatus,
      quoteStatus: quoteStatus ?? old.quoteStatus,
      quoteAmount: old.quoteAmount,
      contractStatus: nextContract,
      contractSignedAt: nextContract == VendorContractStatus.signed
          ? DateTime(2026, 8, 2)
          : null,
      estimatedExpenseTotal: old.estimatedExpenseTotal,
      actualExpenseTotal: old.actualExpenseTotal,
      paidExpenseTotal: old.paidExpenseTotal,
      notes: old.notes,
    );
    vendors[vendors.indexOf(old)] = updated;
    return updated;
  }

  @override
  Future<void> deleteVendor(int weddingId, int vendorId) async {
    vendors.removeWhere((vendor) => vendor.id == vendorId);
  }

  WeddingVendor _fromDraft(int id, VendorDraft draft, {WeddingVendor? old}) {
    return WeddingVendor(
      id: id,
      weddingId: 1,
      name: draft.name,
      serviceCategory: draft.serviceCategory,
      contactPerson: draft.contactPerson,
      email: draft.email,
      phone: draft.phone,
      website: draft.website,
      address: draft.address,
      bookingStatus: draft.bookingStatus,
      quoteStatus: draft.quoteStatus,
      quoteAmount: draft.quoteAmount,
      contractStatus: draft.contractStatus,
      contractSignedAt: draft.contractStatus == VendorContractStatus.signed
          ? old?.contractSignedAt ?? DateTime(2026, 8, 2)
          : null,
      estimatedExpenseTotal: old?.estimatedExpenseTotal ?? 0,
      actualExpenseTotal: old?.actualExpenseTotal ?? 0,
      paidExpenseTotal: old?.paidExpenseTotal ?? 0,
      notes: draft.notes,
    );
  }
}
