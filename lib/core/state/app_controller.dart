import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hitched/core/api/auth_api.dart';
import 'package:hitched/core/models/wedding_models.dart';

final appControllerProvider = StateNotifierProvider<AppController, AppState>(
  (ref) => AppController(),
);

class AppState {
  const AppState({
    this.currentUser,
    required this.couple,
    required this.guests,
    required this.tasks,
    required this.vendors,
    required this.bookings,
    this.selectedCategory,
    this.isBusy = false,
    this.authError,
  });

  final AppUser? currentUser;
  final CoupleProfile couple;
  final List<WeddingGuest> guests;
  final List<WeddingTask> tasks;
  final List<VendorListing> vendors;
  final List<VendorBooking> bookings;
  final VendorCategory? selectedCategory;
  final bool isBusy;
  final String? authError;

  bool get isAuthenticated => currentUser != null;

  List<VendorListing> get visibleVendors {
    final user = currentUser;
    Iterable<VendorListing> source = vendors;
    if (selectedCategory != null) {
      source = source.where((vendor) => vendor.category == selectedCategory);
    }
    if (user?.role == UserRole.bride) {
      source = source.where(
        (vendor) => vendor.startingPriceCents <= couple.budgetCents,
      );
    }
    if (user?.role == UserRole.vendor) {
      source = source.where((vendor) => vendor.ownerId == user?.id);
    }
    return source.toList();
  }

  int get bookedSpendCents {
    return bookings
        .where((booking) => booking.status == BookingStatus.booked)
        .fold(0, (sum, booking) {
          final vendor = vendors.firstWhere(
            (item) => item.id == booking.vendorId,
          );
          final package = vendor.packages.firstWhere(
            (item) => item.id == booking.packageId,
          );
          return sum + package.priceCents;
        });
  }

  AppState copyWith({
    AppUser? currentUser,
    CoupleProfile? couple,
    List<WeddingGuest>? guests,
    List<WeddingTask>? tasks,
    List<VendorListing>? vendors,
    List<VendorBooking>? bookings,
    VendorCategory? selectedCategory,
    bool? isBusy,
    String? authError,
    bool clearCategory = false,
    bool clearUser = false,
    bool clearAuthError = false,
  }) {
    return AppState(
      currentUser: clearUser ? null : currentUser ?? this.currentUser,
      couple: couple ?? this.couple,
      guests: guests ?? this.guests,
      tasks: tasks ?? this.tasks,
      vendors: vendors ?? this.vendors,
      bookings: bookings ?? this.bookings,
      selectedCategory: clearCategory
          ? null
          : selectedCategory ?? this.selectedCategory,
      isBusy: isBusy ?? this.isBusy,
      authError: clearAuthError ? null : authError ?? this.authError,
    );
  }
}

class AppController extends StateNotifier<AppState> {
  AppController({AuthApi? authApi})
    : _authApi = authApi ?? AuthApi(),
      super(_initialState);

  final AuthApi _authApi;

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isBusy: true, clearAuthError: true);
    try {
      final user = await _authApi.login(email: email, password: password);
      state = state.copyWith(currentUser: user, isBusy: false);
      return true;
    } catch (error) {
      state = state.copyWith(isBusy: false, authError: '$error');
      return false;
    }
  }

  Future<bool> registerCouple({
    required UserRole role,
    required String name,
    required String email,
    required String password,
    required String partnerName,
    required String partnerEmail,
    required String partnerPassword,
    required String weddingDate,
    required String location,
  }) async {
    state = state.copyWith(isBusy: true, clearAuthError: true);
    try {
      final user = await _authApi.registerCouple(
        role: role,
        name: name,
        email: email,
        password: password,
        partnerName: partnerName,
        partnerEmail: partnerEmail,
        partnerPassword: partnerPassword,
        weddingDate: weddingDate,
        location: location,
      );
      final brideName = role == UserRole.bride ? name : partnerName;
      final groomName = role == UserRole.groom ? name : partnerName;
      state = state.copyWith(
        currentUser: user,
        isBusy: false,
        couple: state.couple.copyWith(
          brideName: brideName,
          groomName: groomName,
          weddingDate: DateTime.tryParse(weddingDate),
          location: location,
        ),
      );
      return true;
    } catch (error) {
      state = state.copyWith(isBusy: false, authError: '$error');
      return false;
    }
  }

  Future<bool> registerVendor({
    required String ownerName,
    required String email,
    required String password,
    required String serviceName,
    required VendorCategory category,
    required int startingPriceCents,
  }) async {
    state = state.copyWith(isBusy: true, clearAuthError: true);
    try {
      final user = await _authApi.registerVendor(
        ownerName: ownerName,
        email: email,
        password: password,
        serviceName: serviceName,
        category: category,
        description:
            'Premium wedding service with curated packages, imagery, and reviews.',
        priceCents: startingPriceCents,
        imageUrl:
            'https://images.unsplash.com/photo-1527529482837-4698179dc6ce?q=80&w=1200&auto=format&fit=crop',
      );
      final listing = VendorListing(
        id: 'vendor-${DateTime.now().millisecondsSinceEpoch}',
        ownerId: user.id,
        name: serviceName,
        category: category,
        city: 'Lagos',
        description:
            'Premium wedding service with curated packages, imagery, and reviews.',
        imageUrl:
            'https://images.unsplash.com/photo-1527529482837-4698179dc6ce?q=80&w=1200&auto=format&fit=crop',
        startingPriceCents: startingPriceCents,
        rating: 4.7,
        packages: [
          VendorPackage(
            id: 'package-new',
            name: 'Signature package',
            priceCents: startingPriceCents,
            description: 'Core service package for one wedding day.',
          ),
        ],
        reviews: const [
          VendorReview(
            author: 'New listing',
            rating: 4.7,
            comment: 'Ready for couples to discover.',
          ),
        ],
        availableDates: [DateTime(2027, 4, 18), DateTime(2027, 5, 22)],
      );
      state = state.copyWith(
        currentUser: user,
        isBusy: false,
        vendors: [listing, ...state.vendors],
      );
      return true;
    } catch (error) {
      state = state.copyWith(isBusy: false, authError: '$error');
      return false;
    }
  }

  void logout() => state = state.copyWith(clearUser: true, clearCategory: true);

  void setBudget(int budgetCents) {
    state = state.copyWith(
      couple: state.couple.copyWith(budgetCents: budgetCents),
    );
  }

  void selectCategory(VendorCategory? category) {
    state = state.copyWith(
      selectedCategory: category,
      clearCategory: category == null,
    );
  }

  void addGuest(String name, String email) {
    addGuestWithStatus(name, email, 'pending');
  }

  void addGuestWithStatus(String name, String email, String status) {
    state = state.copyWith(
      guests: [
        WeddingGuest(
          id: 'guest-${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          email: email.trim().isEmpty ? null : email,
          status: status,
        ),
        ...state.guests,
      ],
    );
  }

  void removeGuest(String guestId) {
    state = state.copyWith(
      guests: state.guests.where((guest) => guest.id != guestId).toList(),
    );
  }

  void addTask(String title) {
    state = state.copyWith(
      tasks: [
        WeddingTask(
          id: 'task-${DateTime.now().millisecondsSinceEpoch}',
          title: title,
          ownerRole: null,
          isDone: false,
        ),
        ...state.tasks,
      ],
    );
  }

  void toggleTask(String taskId) {
    state = state.copyWith(
      tasks: state.tasks
          .map(
            (task) =>
                task.id == taskId ? task.copyWith(isDone: !task.isDone) : task,
          )
          .toList(),
    );
  }

  void shortlistVendor(String vendorId) {
    if (state.bookings.any((booking) => booking.vendorId == vendorId)) return;
    final vendor = state.vendors.firstWhere((item) => item.id == vendorId);
    state = state.copyWith(
      bookings: [
        VendorBooking(
          id: 'booking-${DateTime.now().millisecondsSinceEpoch}',
          vendorId: vendor.id,
          packageId: vendor.packages.first.id,
          status: BookingStatus.shortlisted,
          eventDate: state.couple.weddingDate,
          note: 'Saved for review',
        ),
        ...state.bookings,
      ],
    );
  }

  void requestBooking(String vendorId, String packageId, String note) {
    final existing = state.bookings
        .where((booking) => booking.vendorId == vendorId)
        .toList();
    if (existing.isEmpty) {
      state = state.copyWith(
        bookings: [
          VendorBooking(
            id: 'booking-${DateTime.now().millisecondsSinceEpoch}',
            vendorId: vendorId,
            packageId: packageId,
            status: BookingStatus.requested,
            eventDate: state.couple.weddingDate,
            note: note,
          ),
          ...state.bookings,
        ],
      );
      return;
    }
    state = state.copyWith(
      bookings: state.bookings
          .map(
            (booking) => booking.vendorId == vendorId
                ? booking.copyWith(status: BookingStatus.requested)
                : booking,
          )
          .toList(),
    );
  }

  void updateBookingStatus(String bookingId, BookingStatus status) {
    state = state.copyWith(
      bookings: state.bookings
          .map(
            (booking) => booking.id == bookingId
                ? booking.copyWith(status: status)
                : booking,
          )
          .toList(),
    );
  }

  void createVendorListing({
    required String name,
    required VendorCategory category,
    required String city,
    required String description,
    required String imageUrl,
    required int startingPriceCents,
    required String packageName,
    required String packageDescription,
  }) {
    final user = state.currentUser;
    if (user == null || user.role != UserRole.vendor) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final listing = VendorListing(
      id: 'vendor-$now',
      ownerId: user.id,
      name: name,
      category: category,
      city: city,
      description: description,
      imageUrl: imageUrl.trim().isEmpty
          ? 'https://images.unsplash.com/photo-1527529482837-4698179dc6ce?q=80&w=1200&auto=format&fit=crop'
          : imageUrl,
      startingPriceCents: startingPriceCents,
      rating: 0,
      packages: [
        VendorPackage(
          id: 'package-$now',
          name: packageName,
          priceCents: startingPriceCents,
          description: packageDescription,
        ),
      ],
      reviews: const [],
      availableDates: [state.couple.weddingDate],
    );
    state = state.copyWith(vendors: [listing, ...state.vendors]);
  }
}

final _initialState = AppState(
  couple: CoupleProfile(
    id: 'couple-1',
    brideName: 'Amara Belle',
    groomName: 'Daniel Hart',
    weddingDate: DateTime(2027, 4, 18),
    location: 'The Glasshouse, Lagos',
    budgetCents: 650000000,
  ),
  guests: const [
    WeddingGuest(
      id: 'guest-1',
      name: 'Maya Cole',
      email: 'maya@example.com',
      status: 'attending',
    ),
    WeddingGuest(
      id: 'guest-2',
      name: 'Ade Martins',
      email: 'ade@example.com',
      status: 'pending',
    ),
    WeddingGuest(
      id: 'guest-3',
      name: 'The Okafor family',
      email: null,
      status: 'attending',
    ),
  ],
  tasks: [
    WeddingTask(
      id: 'task-1',
      title: 'Confirm ceremony music',
      ownerRole: null,
      isDone: false,
      dueDate: DateTime(2027, 2, 10),
    ),
    WeddingTask(
      id: 'task-2',
      title: 'Book makeup trial',
      ownerRole: UserRole.bride,
      isDone: false,
      dueDate: DateTime(2027, 1, 18),
    ),
    WeddingTask(
      id: 'task-3',
      title: 'Review final seating chart',
      ownerRole: null,
      isDone: true,
      dueDate: DateTime(2027, 3, 28),
    ),
  ],
  vendors: _vendors,
  bookings: const [],
);

final _vendors = [
  VendorListing(
    id: 'vendor-opal',
    ownerId: 'vendor-opal',
    name: 'Opal Atelier',
    category: VendorCategory.gowns,
    city: 'Lagos',
    description:
        'Hand-beaded bridal gowns, veil styling, and private fittings for editorial brides.',
    imageUrl:
        'https://images.unsplash.com/photo-1594552072238-b8a33785b261?q=80&w=1200&auto=format&fit=crop',
    startingPriceCents: 240000000,
    rating: 4.9,
    packages: const [
      VendorPackage(
        id: 'opal-1',
        name: 'Classic gown fitting',
        priceCents: 240000000,
        description: 'One custom gown, veil consultation, and two fittings.',
      ),
      VendorPackage(
        id: 'opal-2',
        name: 'Couture bridal edit',
        priceCents: 420000000,
        description: 'Custom gown, reception look, veil, and styling day.',
      ),
    ],
    reviews: const [
      VendorReview(
        author: 'Nadia',
        rating: 5,
        comment: 'The fitting felt private, calm, and very premium.',
      ),
      VendorReview(
        author: 'Ese',
        rating: 4.8,
        comment: 'Beautiful beadwork and thoughtful styling advice.',
      ),
    ],
    availableDates: [DateTime(2027, 4, 18), DateTime(2027, 5, 9)],
  ),
  VendorListing(
    id: 'vendor-saffron',
    name: 'Saffron Table',
    category: VendorCategory.catering,
    city: 'Abuja',
    description:
        'Modern plated dinners, cocktails, late-night bites, and dessert tables.',
    imageUrl:
        'https://images.unsplash.com/photo-1555244162-803834f70033?q=80&w=1200&auto=format&fit=crop',
    startingPriceCents: 520000000,
    rating: 4.8,
    packages: const [
      VendorPackage(
        id: 'saffron-1',
        name: '120 guest tasting menu',
        priceCents: 520000000,
        description: 'Three-course dinner, cocktails, and dessert bar.',
      ),
      VendorPackage(
        id: 'saffron-2',
        name: 'Luxury reception',
        priceCents: 780000000,
        description:
            'Five-course dinner, champagne service, and late-night station.',
      ),
    ],
    reviews: const [
      VendorReview(
        author: 'Tomi',
        rating: 4.9,
        comment: 'Guests still talk about the dessert table.',
      ),
    ],
    availableDates: [DateTime(2027, 4, 18)],
  ),
  VendorListing(
    id: 'vendor-pearl',
    name: 'Pearl Room',
    category: VendorCategory.venue,
    city: 'Lagos',
    description:
        'Light-filled ceremony venue with courtyard, getting-ready suite, and 180 guest capacity.',
    imageUrl:
        'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=1200&auto=format&fit=crop',
    startingPriceCents: 900000000,
    rating: 4.6,
    packages: const [
      VendorPackage(
        id: 'pearl-1',
        name: 'Courtyard ceremony',
        priceCents: 900000000,
        description:
            'Venue access, changing suite, and courtyard ceremony setup.',
      ),
    ],
    reviews: const [
      VendorReview(
        author: 'Kemi',
        rating: 4.6,
        comment: 'The courtyard photographs beautifully.',
      ),
    ],
    availableDates: [DateTime(2027, 6, 12)],
  ),
  VendorListing(
    id: 'vendor-velvet',
    name: 'Velvet Lens',
    category: VendorCategory.photography,
    city: 'Accra',
    description:
        'Editorial photo and film direction for couples who dislike posing.',
    imageUrl:
        'https://images.unsplash.com/photo-1519741497674-611481863552?q=80&w=1200&auto=format&fit=crop',
    startingPriceCents: 450000000,
    rating: 4.9,
    packages: const [
      VendorPackage(
        id: 'velvet-1',
        name: 'Photo only',
        priceCents: 450000000,
        description:
            '10 hour coverage, online gallery, and engagement session.',
      ),
      VendorPackage(
        id: 'velvet-2',
        name: 'Photo and film',
        priceCents: 720000000,
        description:
            'Full photo team, highlight film, ceremony cut, and drone.',
      ),
    ],
    reviews: const [
      VendorReview(
        author: 'Lola',
        rating: 5,
        comment: 'They made us comfortable without forcing poses.',
      ),
    ],
    availableDates: [DateTime(2027, 4, 18), DateTime(2027, 7, 3)],
  ),
  VendorListing(
    id: 'vendor-flora',
    name: 'Maison Flora',
    category: VendorCategory.decor,
    city: 'Lagos',
    description:
        'Ceremony florals and reception installations with garden texture.',
    imageUrl:
        'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?q=80&w=1200&auto=format&fit=crop',
    startingPriceCents: 380000000,
    rating: 4.7,
    packages: const [
      VendorPackage(
        id: 'flora-1',
        name: 'Garden ceremony',
        priceCents: 380000000,
        description: 'Aisle florals, altar installation, and table accents.',
      ),
    ],
    reviews: const [
      VendorReview(
        author: 'Ife',
        rating: 4.7,
        comment: 'Romantic without looking crowded.',
      ),
    ],
    availableDates: [DateTime(2027, 4, 18)],
  ),
];
