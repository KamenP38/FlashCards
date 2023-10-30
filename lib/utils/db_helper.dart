import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

// DBHelper is a Singleton class (only one instance)
class DBHelper {
  static const String _databaseName = 'flashcards.db';
  static const int _databaseVersion = 1;

  DBHelper._(); // private constructor (can't be called from outside)

  // the single instance
  static final DBHelper _singleton = DBHelper._();

  // factory constructor that always returns the single instance
  factory DBHelper() => _singleton;

  // the singleton will hold a reference to the database once opened
  Database? _database;

  // initialize the database when it's first requested
  get db async {
    _database ??= await _initDatabase(); // if null, initialize it
    return _database;
  }

  Future<Database> _initDatabase() async {
    // use path_provider to get the platform-dependent documents directory
    var dbDir = await getApplicationDocumentsDirectory();

    // path.join joins two paths together, and is platform aware
    var dbPath = path.join(dbDir.path, _databaseName);

    // await deleteDatabase(dbPath); // nuke the database (for testing)

    // open the database
    var db = await openDatabase(
      dbPath, 
      version: _databaseVersion, // used for migrations

      // called when the database is first created
      onCreate: (Database db, int version) async {
        // create the customer table
        await db.execute('''
          CREATE TABLE deck(
            id INTEGER PRIMARY KEY,
            title TEXT,
            flashcardCount INTEGER
          )
        ''');

        // create the purchase_order table (can't use "order" as it's a keyword)
        await db.execute('''
          CREATE TABLE flashcard(
            id INTEGER PRIMARY KEY,
            deckId INTEGER,
            question TEXT,
            answer TEXT,
            FOREIGN KEY(deckId) REFERENCES deck(id)
          )
        ''');
      }
    );

    return db;
  }

  // fetch records from a table with an optional "where" clause
  Future<List<Map<String, dynamic>>> query(String table, {String? where, List<dynamic>? whereArgs}) async {
    final db = await this.db;
    return db.query(table, where: where, whereArgs: whereArgs);
  }

  // insert a record into a table
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await this.db;
    int id = await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  // update a record in a table
  Future<void> update(String table, Map<String, dynamic> data, {String? where, List<dynamic>? whereArgs}) async {
    final db = await this.db;
    await db.update(
      table,
      data,
      where: where ?? 'id = ?',
      whereArgs: whereArgs ?? [data['id']],
    );
}

  // delete a record from a table
  Future<void> delete(String table, {String? where, List<dynamic>? whereArgs}) async {
    final db = await this.db;
    await db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
}
}
