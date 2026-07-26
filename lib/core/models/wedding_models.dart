enum UserRole { bride, groom, vendor, admin }

extension UserRoleLabel on UserRole {
  String get label => switch (this) {
    UserRole.bride => 'Bride',
    UserRole.groom => 'Groom',
    UserRole.vendor => 'Vendor',
    UserRole.admin => 'Admin',
  };
}

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.coupleId,
    this.token,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? coupleId;
  final String? token;
}

class CoupleProfile {
  const CoupleProfile({
    required this.id,
    required this.brideName,
    required this.groomName,
    required this.weddingDate,
    required this.location,
    required this.budgetCents,
  });

  final String id;
  final String brideName;
  final String groomName;
  final DateTime weddingDate;
  final String location;
  final int budgetCents;

  CoupleProfile copyWith({
    String? brideName,
    String? groomName,
    DateTime? weddingDate,
    String? location,
    int? budgetCents,
  }) {
    return CoupleProfile(
      id: id,
      brideName: brideName ?? this.brideName,
      groomName: groomName ?? this.groomName,
      weddingDate: weddingDate ?? this.weddingDate,
      location: location ?? this.location,
      budgetCents: budgetCents ?? this.budgetCents,
    );
  }
}

class WeddingGuest {
  const WeddingGuest({
    required this.id,
    required this.name,
    required this.status,
    this.email,
    this.dietaryNotes,
  });

  final String id;
  final String name;
  final String? email;
  final String status;
  final String? dietaryNotes;
}

class WeddingTask {
  const WeddingTask({
    required this.id,
    required this.title,
    required this.ownerRole,
    required this.isDone,
    this.dueDate,
  });

  final String id;
  final String title;
  final UserRole? ownerRole;
  final bool isDone;
  final DateTime? dueDate;

  WeddingTask copyWith({bool? isDone}) {
    return WeddingTask(
      id: id,
      title: title,
      ownerRole: ownerRole,
      isDone: isDone ?? this.isDone,
      dueDate: dueDate,
    );
  }
}

enum VendorCategory { gowns, catering, venue, photography, decor, music }

extension VendorCategoryLabel on VendorCategory {
  String get label => switch (this) {
    VendorCategory.gowns => 'Bridal gowns',
    VendorCategory.catering => 'Catering',
    VendorCategory.venue => 'Venues',
    VendorCategory.photography => 'Photo & film',
    VendorCategory.decor => 'Decor',
    VendorCategory.music => 'Music',
  };
}

class VendorPackage {
  const VendorPackage({
    required this.id,
    required this.name,
    required this.priceCents,
    required this.description,
  });

  final String id;
  final String name;
  final int priceCents;
  final String description;
}

class VendorReview {
  const VendorReview({
    required this.author,
    required this.rating,
    required this.comment,
  });

  final String author;
  final double rating;
  final String comment;
}

class VendorListing {
  const VendorListing({
    required this.id,
    required this.name,
    required this.category,
    required this.city,
    required this.description,
    required this.imageUrl,
    required this.startingPriceCents,
    required this.rating,
    required this.packages,
    required this.reviews,
    required this.availableDates,
    this.ownerId,
  });

  final String id;
  final String name;
  final VendorCategory category;
  final String city;
  final String description;
  final String imageUrl;
  final int startingPriceCents;
  final double rating;
  final List<VendorPackage> packages;
  final List<VendorReview> reviews;
  final List<DateTime> availableDates;
  final String? ownerId;
}

enum BookingStatus { shortlisted, requested, accepted, declined, booked }

extension BookingStatusLabel on BookingStatus {
  String get label => switch (this) {
    BookingStatus.shortlisted => 'Shortlisted',
    BookingStatus.requested => 'Requested',
    BookingStatus.accepted => 'Accepted',
    BookingStatus.declined => 'Declined',
    BookingStatus.booked => 'Booked',
  };
}

class VendorBooking {
  const VendorBooking({
    required this.id,
    required this.vendorId,
    required this.packageId,
    required this.status,
    required this.eventDate,
    required this.note,
  });

  final String id;
  final String vendorId;
  final String packageId;
  final BookingStatus status;
  final DateTime eventDate;
  final String note;

  VendorBooking copyWith({BookingStatus? status}) {
    return VendorBooking(
      id: id,
      vendorId: vendorId,
      packageId: packageId,
      status: status ?? this.status,
      eventDate: eventDate,
      note: note,
    );
  }
}
