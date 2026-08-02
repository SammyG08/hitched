enum VendorServiceCategory {
  venue('venue', 'Venue'),
  catering('catering', 'Catering'),
  photography('photography', 'Photography'),
  videography('videography', 'Videography'),
  floral('floral', 'Floral'),
  entertainment('entertainment', 'Entertainment'),
  attire('attire', 'Attire'),
  beauty('beauty', 'Beauty'),
  transportation('transportation', 'Transportation'),
  stationery('stationery', 'Stationery'),
  cake('cake', 'Cake'),
  planning('planning', 'Planning'),
  other('other', 'Other');

  const VendorServiceCategory(this.apiValue, this.label);
  final String apiValue;
  final String label;

  static VendorServiceCategory fromApi(String value) {
    return values.firstWhere((category) => category.apiValue == value);
  }
}

enum VendorBookingStatus {
  researching('researching', 'Researching'),
  contacted('contacted', 'Contacted'),
  shortlisted('shortlisted', 'Shortlisted'),
  booked('booked', 'Booked'),
  rejected('rejected', 'Rejected');

  const VendorBookingStatus(this.apiValue, this.label);
  final String apiValue;
  final String label;

  static VendorBookingStatus fromApi(String value) {
    return values.firstWhere((status) => status.apiValue == value);
  }
}

enum VendorQuoteStatus {
  notRequested('not_requested', 'Not requested'),
  requested('requested', 'Requested'),
  received('received', 'Received'),
  accepted('accepted', 'Accepted'),
  rejected('rejected', 'Rejected');

  const VendorQuoteStatus(this.apiValue, this.label);
  final String apiValue;
  final String label;

  static VendorQuoteStatus fromApi(String value) {
    return values.firstWhere((status) => status.apiValue == value);
  }
}

enum VendorContractStatus {
  notStarted('not_started', 'Not started'),
  reviewing('reviewing', 'Reviewing'),
  signed('signed', 'Signed');

  const VendorContractStatus(this.apiValue, this.label);
  final String apiValue;
  final String label;

  static VendorContractStatus fromApi(String value) {
    return values.firstWhere((status) => status.apiValue == value);
  }
}

class WeddingVendor {
  const WeddingVendor({
    required this.id,
    required this.weddingId,
    required this.name,
    required this.serviceCategory,
    required this.contactPerson,
    required this.email,
    required this.phone,
    required this.website,
    required this.address,
    required this.bookingStatus,
    required this.quoteStatus,
    required this.contractStatus,
    required this.estimatedExpenseTotal,
    required this.actualExpenseTotal,
    required this.paidExpenseTotal,
    required this.notes,
    this.quoteAmount,
    this.contractSignedAt,
  });

  final int id;
  final int weddingId;
  final String name;
  final VendorServiceCategory serviceCategory;
  final String contactPerson;
  final String email;
  final String phone;
  final String website;
  final String address;
  final VendorBookingStatus bookingStatus;
  final VendorQuoteStatus quoteStatus;
  final double? quoteAmount;
  final VendorContractStatus contractStatus;
  final DateTime? contractSignedAt;
  final double estimatedExpenseTotal;
  final double actualExpenseTotal;
  final double paidExpenseTotal;
  final String notes;

  double get outstandingExpenseTotal =>
      (actualExpenseTotal - paidExpenseTotal).clamp(0, double.infinity);

  factory WeddingVendor.fromJson(Map<String, dynamic> json) {
    return WeddingVendor(
      id: json['id'] as int,
      weddingId: json['wedding'] as int,
      name: json['name'] as String,
      serviceCategory: VendorServiceCategory.fromApi(
        json['service_category'] as String,
      ),
      contactPerson: json['contact_person'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      website: json['website'] as String? ?? '',
      address: json['address'] as String? ?? '',
      bookingStatus: VendorBookingStatus.fromApi(
        json['booking_status'] as String,
      ),
      quoteStatus: VendorQuoteStatus.fromApi(json['quote_status'] as String),
      quoteAmount: _nullableMoney(json['quote_amount']),
      contractStatus: VendorContractStatus.fromApi(
        json['contract_status'] as String,
      ),
      contractSignedAt: _date(json['contract_signed_at']),
      estimatedExpenseTotal: _money(json['estimated_expense_total']),
      actualExpenseTotal: _money(json['actual_expense_total']),
      paidExpenseTotal: _money(json['paid_expense_total']),
      notes: json['notes'] as String? ?? '',
    );
  }
}

class VendorDraft {
  const VendorDraft({
    required this.name,
    required this.serviceCategory,
    required this.contactPerson,
    required this.email,
    required this.phone,
    required this.website,
    required this.address,
    required this.bookingStatus,
    required this.quoteStatus,
    required this.contractStatus,
    required this.notes,
    this.quoteAmount,
  });

  final String name;
  final VendorServiceCategory serviceCategory;
  final String contactPerson;
  final String email;
  final String phone;
  final String website;
  final String address;
  final VendorBookingStatus bookingStatus;
  final VendorQuoteStatus quoteStatus;
  final double? quoteAmount;
  final VendorContractStatus contractStatus;
  final String notes;

  Map<String, dynamic> toJson() => {
    'name': name.trim(),
    'service_category': serviceCategory.apiValue,
    'contact_person': contactPerson.trim(),
    'email': email.trim(),
    'phone': phone.trim(),
    'website': website.trim(),
    'address': address.trim(),
    'booking_status': bookingStatus.apiValue,
    'quote_status': quoteStatus.apiValue,
    'quote_amount': quoteAmount?.toStringAsFixed(2),
    'contract_status': contractStatus.apiValue,
    'notes': notes.trim(),
  };
}

double _money(dynamic value) => double.parse(value.toString());

double? _nullableMoney(dynamic value) {
  return value == null ? null : double.tryParse(value.toString());
}

DateTime? _date(dynamic value) {
  return value == null ? null : DateTime.tryParse(value.toString());
}
