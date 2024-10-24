import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'housing.db');
    return await openDatabase(
      path,
      version: 5, // Incremented version for new columns
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE houses ('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'name TEXT, '
          'location TEXT, '
          'price INTEGER, '
          'renter TEXT, '
          'renter_email TEXT, '
          'renter_contact_number TEXT, '
          'available INTEGER, '
          'paid INTEGER DEFAULT 0, ' // New column to track payment status
          'months_paid INTEGER DEFAULT 0, ' // New column to track number of months paid
          'payment_month INTEGER, ' // Month of payment
          'payment_year INTEGER ' // Year of payment
          ')',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE houses ADD COLUMN renter_email TEXT');
          await db.execute('ALTER TABLE houses ADD COLUMN renter_contact_number TEXT');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE houses ADD COLUMN paid INTEGER DEFAULT 0');
        }
        if (oldVersion < 4) {
          await db.execute('ALTER TABLE houses ADD COLUMN months_paid INTEGER DEFAULT 0');
          await db.execute('ALTER TABLE houses ADD COLUMN payment_month INTEGER');
          await db.execute('ALTER TABLE houses ADD COLUMN payment_year INTEGER');
        }
      },
    );
  }

  Future<void> insertHouse(Map<String, dynamic> house) async {
    final db = await database;
    await db.insert('houses', house);
  }

  Future<List<Map<String, dynamic>>> getHouses() async {
    final db = await database;
    return await db.query('houses');
  }

  Future<void> updateHouseAvailability(int id, int available) async {
    final db = await database;
    await db.update(
      'houses',
      {'available': available},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateRenter(int houseId, String renterName, String renterEmail, String renterContactNumber) async {
    final db = await database;
    await db.update(
      'houses',
      {
        'renter': renterName,
        'renter_email': renterEmail,
        'renter_contact_number': renterContactNumber,
      },
      where: 'id = ?',
      whereArgs: [houseId],
    );
  }

  Future<void> markRenterAsPaid(int houseId, int month, int year) async {
    final db = await database;

    // Get the current status of the house
    final List<Map<String, dynamic>> house = await db.query(
      'houses',
      where: 'id = ?',
      whereArgs: [houseId],
    );

    if (house.isNotEmpty) {
      // Cast the retrieved values to the correct types
      int monthsPaid = house[0]['months_paid'] as int? ?? 0;

      // Update to mark as paid
      await db.update(
        'houses',
        {
          'paid': 1, // Set paid status to 1
          'payment_month': month, // Save the month
          'payment_year': year, // Save the year
          'months_paid': monthsPaid + 1, // Increment months paid
        },
        where: 'id = ?',
        whereArgs: [houseId],
      );
    }
  }

  Future<void> deleteHouse(int houseId) async {
    final db = await database;
    await db.delete(
      'houses',
      where: 'id = ?',
      whereArgs: [houseId],
    );
  }
}
