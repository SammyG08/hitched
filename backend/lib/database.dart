import 'dart:convert';
import 'dart:io';

import 'package:mysql_client/mysql_client.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  MySQLConnection? _connection;

  Future<MySQLConnection> get connection async {
    final existing = _connection;
    if (existing != null && existing.connected) return existing;

    final conn = await MySQLConnection.createConnection(
      host: Platform.environment['MYSQL_HOST'] ?? '127.0.0.1',
      port: int.tryParse(Platform.environment['MYSQL_PORT'] ?? '3306') ?? 3306,
      userName: Platform.environment['MYSQL_USER'] ?? 'root',
      password: Platform.environment['MYSQL_PASSWORD'] ?? '',
      databaseName: Platform.environment['MYSQL_DATABASE'] ?? 'hitched',
      secure: (Platform.environment['MYSQL_SECURE'] ?? 'false') == 'true',
    );
    await conn.connect();
    _connection = conn;
    return conn;
  }

  Future<void> migrate() async {
    final db = await connection;
    for (final statement in _schemaStatements) {
      await db.execute(statement);
    }
    await seedMarketplace();
  }

  Future<Map<String, dynamic>?> userByToken(String token) async {
    final db = await connection;
    final result = await db.execute(
      'SELECT u.*, c.budget_cents, c.partner_a_id, c.partner_b_id FROM auth_tokens t '
      'JOIN users u ON u.id = t.user_id '
      'LEFT JOIN couples c ON c.id = u.couple_id '
      'WHERE t.token = :token AND t.expires_at > NOW() LIMIT 1',
      {'token': token},
    );
    if (result.rows.isEmpty) return null;
    return result.rows.first.assoc();
  }

  Future<Map<String, dynamic>?> userByEmail(String email) async {
    final db = await connection;
    final result = await db.execute(
      'SELECT * FROM users WHERE email = :email LIMIT 1',
      {'email': email.toLowerCase()},
    );
    if (result.rows.isEmpty) return null;
    return result.rows.first.assoc();
  }

  Future<Map<String, dynamic>> createCoupleRegistration({
    required String registeringRole,
    required String name,
    required String email,
    required String password,
    required String partnerName,
    required String partnerEmail,
    required String partnerPassword,
    required String weddingDate,
    required String location,
  }) async {
    final db = await connection;
    final role = registeringRole == 'groom' ? 'groom' : 'bride';
    final partnerRole = role == 'bride' ? 'groom' : 'bride';
    final primaryEmail = email.toLowerCase();
    final secondaryEmail = partnerEmail.toLowerCase();

    await db.execute('START TRANSACTION');
    try {
      final first = await db.execute(
        'INSERT INTO users (name, email, password_hash, role) VALUES (:name, :email, SHA2(:password, 256), :role)',
        {
          'name': name,
          'email': primaryEmail,
          'password': password,
          'role': role
        },
      );
      final firstId = first.lastInsertID.toInt();
      final second = await db.execute(
        'INSERT INTO users (name, email, password_hash, role) VALUES (:name, :email, SHA2(:password, 256), :role)',
        {
          'name': partnerName,
          'email': secondaryEmail,
          'password': partnerPassword,
          'role': partnerRole
        },
      );
      final secondId = second.lastInsertID.toInt();
      final brideId = role == 'bride' ? firstId : secondId;
      final groomId = role == 'groom' ? firstId : secondId;
      final couple = await db.execute(
        'INSERT INTO couples (bride_id, groom_id, partner_a_id, partner_b_id, wedding_date, location) '
        'VALUES (:brideId, :groomId, :brideId, :groomId, :weddingDate, :location)',
        {
          'brideId': brideId,
          'groomId': groomId,
          'weddingDate': weddingDate,
          'location': location,
        },
      );
      final coupleId = couple.lastInsertID.toInt();
      await db.execute(
        'UPDATE users SET couple_id = :coupleId WHERE id IN (:firstId, :secondId)',
        {'coupleId': coupleId, 'firstId': firstId, 'secondId': secondId},
      );
      await db.execute('COMMIT');
      return (await userByEmail(primaryEmail))!;
    } catch (_) {
      await db.execute('ROLLBACK');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final db = await connection;
    final result = await db.execute(
      'SELECT * FROM users WHERE email = :email AND password_hash = SHA2(:password, 256) LIMIT 1',
      {'email': email.toLowerCase(), 'password': password},
    );
    if (result.rows.isEmpty) return null;
    final user = result.rows.first.assoc();
    final token = base64UrlEncode(
        utf8.encode('${user['id']}:${DateTime.now().microsecondsSinceEpoch}'));
    await db.execute(
      'INSERT INTO auth_tokens (user_id, token, expires_at) VALUES (:userId, :token, DATE_ADD(NOW(), INTERVAL 30 DAY))',
      {'userId': user['id'], 'token': token},
    );
    user['token'] = token;
    return user;
  }

  Future<void> seedMarketplace() async {
    final db = await connection;
    final count = await db.execute('SELECT COUNT(*) AS total FROM vendors');
    if ((int.tryParse('${count.rows.first.assoc()['total']}') ?? 0) > 0) return;
    final vendors = [
      [
        'Opal Atelier',
        'bridal_gown',
        'Hand-beaded gowns and veil fittings',
        240000,
        'https://images.unsplash.com/photo-1594552072238-b8a33785b261?q=80&w=1200&auto=format&fit=crop',
        'Elegant fittings, thoughtful stylists, excellent fabric quality.'
      ],
      [
        'Maison Flora',
        'vendor',
        'Ceremony florals and reception installations',
        380000,
        'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?q=80&w=1200&auto=format&fit=crop',
        'Creates lush garden installations without overwhelming the venue.'
      ],
      [
        'Saffron Table',
        'catering',
        'Modern plated dinners and dessert tables',
        520000,
        'https://images.unsplash.com/photo-1555244162-803834f70033?q=80&w=1200&auto=format&fit=crop',
        'Guests consistently mention the tasting menu and calm service.'
      ],
      [
        'Velvet Lens',
        'vendor',
        'Editorial photo and film team',
        450000,
        'https://images.unsplash.com/photo-1519741497674-611481863552?q=80&w=1200&auto=format&fit=crop',
        'Strong direction for couples who dislike posing.'
      ],
      [
        'Pearl Room',
        'venue',
        'Light-filled city venue with courtyard',
        900000,
        'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=1200&auto=format&fit=crop',
        'Best for intimate ceremonies and clean modern receptions.'
      ],
    ];
    for (final v in vendors) {
      await db.execute(
        'INSERT INTO vendors (name, category, description, price_cents, image_url, remarks, owner_user_id, approved) '
        'VALUES (:name, :category, :description, :price, :image, :remarks, NULL, TRUE)',
        {
          'name': v[0],
          'category': v[1],
          'description': v[2],
          'price': v[3],
          'image': v[4],
          'remarks': v[5]
        },
      );
    }
  }
}

const _schemaStatements = [
  '''CREATE TABLE IF NOT EXISTS users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    couple_id BIGINT NULL,
    name VARCHAR(160) NOT NULL,
    email VARCHAR(190) NOT NULL UNIQUE,
    password_hash CHAR(64) NOT NULL,
    role ENUM('bride','groom','vendor','admin') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  )''',
  '''CREATE TABLE IF NOT EXISTS couples (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    bride_id BIGINT NOT NULL,
    groom_id BIGINT NOT NULL,
    partner_a_id BIGINT NOT NULL,
    partner_b_id BIGINT NOT NULL,
    wedding_date DATE NOT NULL,
    location VARCHAR(220) NOT NULL,
    budget_cents INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  )''',
  '''CREATE TABLE IF NOT EXISTS auth_tokens (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    token VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  )''',
  '''CREATE TABLE IF NOT EXISTS guests (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    couple_id BIGINT NOT NULL,
    name VARCHAR(160) NOT NULL,
    email VARCHAR(190) NULL,
    rsvp_status ENUM('pending','attending','declined') DEFAULT 'pending',
    dietary_notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  )''',
  '''CREATE TABLE IF NOT EXISTS todos (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    couple_id BIGINT NOT NULL,
    title VARCHAR(220) NOT NULL,
    owner_role ENUM('bride','groom','shared') DEFAULT 'shared',
    is_done BOOLEAN DEFAULT FALSE,
    due_date DATE NULL
  )''',
  '''CREATE TABLE IF NOT EXISTS vendors (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    owner_user_id BIGINT NULL,
    name VARCHAR(180) NOT NULL,
    category ENUM('vendor','bridal_gown','catering','venue') NOT NULL,
    description TEXT NOT NULL,
    price_cents INT NOT NULL,
    image_url TEXT NOT NULL,
    remarks TEXT NULL,
    approved BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  )''',
  '''CREATE TABLE IF NOT EXISTS selections (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    couple_id BIGINT NOT NULL,
    vendor_id BIGINT NOT NULL,
    status ENUM('shortlisted','booked','rejected') DEFAULT 'shortlisted',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  )''',
];
