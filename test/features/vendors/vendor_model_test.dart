import 'package:flutter_test/flutter_test.dart';
import 'package:hitched/features/vendors/domain/vendor_models.dart';

void main() {
  test('parses vendor workflow and linked expense totals', () {
    final vendor = WeddingVendor.fromJson({
      'id': 4,
      'wedding': 2,
      'name': 'Example Studios',
      'service_category': 'photography',
      'contact_person': 'Robin Doe',
      'email': 'hello@example.test',
      'phone': '+233 20 000 0000',
      'website': 'https://example.test',
      'address': 'Accra',
      'booking_status': 'booked',
      'quote_status': 'accepted',
      'quote_amount': '4500.00',
      'contract_status': 'signed',
      'contract_signed_at': '2026-08-02T09:30:00Z',
      'estimated_expense_total': '5000.00',
      'actual_expense_total': '4500.00',
      'paid_expense_total': '2000.00',
      'notes': '',
    });

    expect(vendor.serviceCategory, VendorServiceCategory.photography);
    expect(vendor.bookingStatus, VendorBookingStatus.booked);
    expect(vendor.contractStatus, VendorContractStatus.signed);
    expect(vendor.quoteAmount, 4500);
    expect(vendor.outstandingExpenseTotal, 2500);
    expect(vendor.contractSignedAt, isNotNull);
  });
}
