import 'vendor_models.dart';

abstract interface class VendorRepository {
  Future<List<WeddingVendor>> fetchVendors(int weddingId);
  Future<WeddingVendor> createVendor(int weddingId, VendorDraft draft);
  Future<WeddingVendor> updateVendor(
    int weddingId,
    int vendorId,
    VendorDraft draft,
  );
  Future<WeddingVendor> updateWorkflow(
    int weddingId,
    int vendorId, {
    VendorBookingStatus? bookingStatus,
    VendorQuoteStatus? quoteStatus,
    VendorContractStatus? contractStatus,
  });
  Future<void> deleteVendor(int weddingId, int vendorId);
}
