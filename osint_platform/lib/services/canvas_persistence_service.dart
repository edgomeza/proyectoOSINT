import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../providers/canvas_provider.dart';

/// Service for persisting Canvas diagrams to SQLite database
class CanvasPersistenceService {
  static Database? _database;
  static const String _tableName = 'canvas_diagrams';
  static const String _dbName = 'osint_canvas.db';

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create tables
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        investigation_id TEXT NOT NULL,
        name TEXT,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_active INTEGER DEFAULT 0
      )
    ''');

    // Create index for faster queries
    await db.execute('''
      CREATE INDEX idx_investigation_id ON $_tableName(investigation_id)
    ''');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future schema changes here
  }

  /// Save canvas state to database
  Future<void> saveCanvas({
    required String id,
    required String investigationId,
    required CanvasState canvasState,
    String? name,
  }) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final data = {
      'id': id,
      'investigation_id': investigationId,
      'name': name ?? 'Canvas $id',
      'data': jsonEncode(canvasState.toJson()),
      'created_at': now,
      'updated_at': now,
      'is_active': 1,
    };

    await db.insert(
      _tableName,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update existing canvas
  Future<void> updateCanvas({
    required String id,
    required CanvasState canvasState,
    String? name,
  }) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final data = {
      'data': jsonEncode(canvasState.toJson()),
      'updated_at': now,
    };

    if (name != null) {
      data['name'] = name;
    }

    await db.update(
      _tableName,
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Load canvas by ID
  Future<CanvasState?> loadCanvas(String id) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final data = maps.first;
    final canvasData = jsonDecode(data['data'] as String);

    return CanvasState.fromJson(canvasData);
  }

  /// Load canvas by investigation ID
  Future<CanvasState?> loadCanvasByInvestigation(String investigationId) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'investigation_id = ? AND is_active = 1',
      whereArgs: [investigationId],
      orderBy: 'updated_at DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final data = maps.first;
    final canvasData = jsonDecode(data['data'] as String);

    return CanvasState.fromJson(canvasData);
  }

  /// Get all canvas for an investigation
  Future<List<Map<String, dynamic>>> getCanvasListByInvestigation(
    String investigationId,
  ) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'investigation_id = ?',
      whereArgs: [investigationId],
      orderBy: 'updated_at DESC',
    );

    return maps;
  }

  /// Delete canvas
  Future<void> deleteCanvas(String id) async {
    final db = await database;

    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete all canvas for an investigation
  Future<void> deleteAllCanvasByInvestigation(String investigationId) async {
    final db = await database;

    await db.delete(
      _tableName,
      where: 'investigation_id = ?',
      whereArgs: [investigationId],
    );
  }

  /// Mark canvas as active/inactive
  Future<void> setCanvasActive(String id, bool isActive) async {
    final db = await database;

    // If setting active, deactivate all others in the same investigation
    if (isActive) {
      final canvas = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (canvas.isNotEmpty) {
        final investigationId = canvas.first['investigation_id'] as String;

        await db.update(
          _tableName,
          {'is_active': 0},
          where: 'investigation_id = ?',
          whereArgs: [investigationId],
        );
      }
    }

    await db.update(
      _tableName,
      {'is_active': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Check if canvas exists
  Future<bool> canvasExists(String id) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    return maps.isNotEmpty;
  }

  /// Get canvas metadata
  Future<Map<String, dynamic>?> getCanvasMetadata(String id) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      columns: ['id', 'investigation_id', 'name', 'created_at', 'updated_at', 'is_active'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    return maps.first;
  }

  /// Export canvas to JSON
  Future<Map<String, dynamic>?> exportCanvas(String id) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    return maps.first;
  }

  /// Import canvas from JSON
  Future<void> importCanvas(Map<String, dynamic> canvasData) async {
    final db = await database;

    await db.insert(
      _tableName,
      canvasData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Clear all data (for testing)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete(_tableName);
  }
}
