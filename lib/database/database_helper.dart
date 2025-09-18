import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/doctor.dart';
import '../models/patient.dart';
import '../models/appointment.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'safe_mother.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create doctors table
    await db.execute('''
      CREATE TABLE doctors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL,
        specialization TEXT NOT NULL,
        licenseNumber TEXT NOT NULL UNIQUE,
        hospital TEXT NOT NULL,
        experience TEXT NOT NULL,
        bio TEXT NOT NULL,
        profileImage TEXT,
        rating REAL DEFAULT 0.0,
        totalPatients INTEGER DEFAULT 0,
        isAvailable INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Create patients table
    await db.execute('''
      CREATE TABLE patients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL,
        dateOfBirth TEXT NOT NULL,
        bloodType TEXT NOT NULL,
        emergencyContact TEXT NOT NULL,
        emergencyPhone TEXT NOT NULL,
        medicalHistory TEXT,
        allergies TEXT,
        currentMedications TEXT,
        lastVisit TEXT NOT NULL,
        assignedDoctorId INTEGER,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (assignedDoctorId) REFERENCES doctors (id)
      )
    ''');

    // Create appointments table
    await db.execute('''
      CREATE TABLE appointments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        doctorId INTEGER NOT NULL,
        patientId INTEGER NOT NULL,
        appointmentDate TEXT NOT NULL,
        timeSlot TEXT NOT NULL,
        status TEXT DEFAULT 'scheduled',
        reason TEXT,
        notes TEXT,
        prescription TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (doctorId) REFERENCES doctors (id),
        FOREIGN KEY (patientId) REFERENCES patients (id)
      )
    ''');

    // Insert sample data
    await _insertSampleData(db);
  }

  Future<void> _insertSampleData(Database db) async {
    final now = DateTime.now();
    
    // Insert sample doctors
    await db.insert('doctors', Doctor(
      name: 'Dr. Sarah Johnson',
      email: 'sarah.johnson@hospital.com',
      phone: '+1-555-0101',
      specialization: 'Obstetrics & Gynecology',
      licenseNumber: 'MD123456',
      hospital: 'City General Hospital',
      experience: '10 years',
      bio: 'Specialized in high-risk pregnancies and maternal-fetal medicine.',
      rating: 4.8,
      totalPatients: 150,
      isAvailable: true,
      createdAt: now,
      updatedAt: now,
    ).toMap());

    await db.insert('doctors', Doctor(
      name: 'Dr. Michael Chen',
      email: 'michael.chen@hospital.com',
      phone: '+1-555-0102',
      specialization: 'Pediatrics',
      licenseNumber: 'MD123457',
      hospital: 'City General Hospital',
      experience: '8 years',
      bio: 'Expert in newborn care and early childhood development.',
      rating: 4.6,
      totalPatients: 200,
      isAvailable: true,
      createdAt: now,
      updatedAt: now,
    ).toMap());

    await db.insert('doctors', Doctor(
      name: 'Dr. Emily Rodriguez',
      email: 'emily.rodriguez@hospital.com',
      phone: '+1-555-0103',
      specialization: 'Family Medicine',
      licenseNumber: 'MD123458',
      hospital: 'Community Health Center',
      experience: '12 years',
      bio: 'Comprehensive family care with focus on women\'s health.',
      rating: 4.9,
      totalPatients: 300,
      isAvailable: true,
      createdAt: now,
      updatedAt: now,
    ).toMap());
  }

  // Doctor CRUD operations
  Future<int> insertDoctor(Doctor doctor) async {
    final db = await database;
    return await db.insert('doctors', doctor.toMap());
  }

  Future<List<Doctor>> getAllDoctors() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('doctors');
    return List.generate(maps.length, (i) => Doctor.fromMap(maps[i]));
  }

  Future<Doctor?> getDoctorById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'doctors',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Doctor.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateDoctor(Doctor doctor) async {
    final db = await database;
    return await db.update(
      'doctors',
      doctor.toMap(),
      where: 'id = ?',
      whereArgs: [doctor.id],
    );
  }

  Future<int> deleteDoctor(int id) async {
    final db = await database;
    return await db.delete(
      'doctors',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Patient CRUD operations
  Future<int> insertPatient(Patient patient) async {
    final db = await database;
    return await db.insert('patients', patient.toMap());
  }

  Future<List<Patient>> getAllPatients() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('patients');
    return List.generate(maps.length, (i) => Patient.fromMap(maps[i]));
  }

  Future<Patient?> getPatientById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'patients',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Patient.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Patient>> getPatientsByDoctorId(int doctorId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'patients',
      where: 'assignedDoctorId = ?',
      whereArgs: [doctorId],
    );
    return List.generate(maps.length, (i) => Patient.fromMap(maps[i]));
  }

  Future<int> updatePatient(Patient patient) async {
    final db = await database;
    return await db.update(
      'patients',
      patient.toMap(),
      where: 'id = ?',
      whereArgs: [patient.id],
    );
  }

  Future<int> deletePatient(int id) async {
    final db = await database;
    return await db.delete(
      'patients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Appointment CRUD operations
  Future<int> insertAppointment(Appointment appointment) async {
    final db = await database;
    return await db.insert('appointments', appointment.toMap());
  }

  Future<List<Appointment>> getAllAppointments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('appointments');
    return List.generate(maps.length, (i) => Appointment.fromMap(maps[i]));
  }

  Future<List<Appointment>> getAppointmentsByDoctorId(int doctorId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'appointments',
      where: 'doctorId = ?',
      whereArgs: [doctorId],
    );
    return List.generate(maps.length, (i) => Appointment.fromMap(maps[i]));
  }

  Future<List<Appointment>> getAppointmentsByPatientId(int patientId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'appointments',
      where: 'patientId = ?',
      whereArgs: [patientId],
    );
    return List.generate(maps.length, (i) => Appointment.fromMap(maps[i]));
  }

  Future<int> updateAppointment(Appointment appointment) async {
    final db = await database;
    return await db.update(
      'appointments',
      appointment.toMap(),
      where: 'id = ?',
      whereArgs: [appointment.id],
    );
  }

  Future<int> deleteAppointment(int id) async {
    final db = await database;
    return await db.delete(
      'appointments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

