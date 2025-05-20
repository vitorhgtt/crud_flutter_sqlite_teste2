import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _db;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_db != null) return _db!;

    // iniciando o sqlite para desktop
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // path do banco
    final dbPath = await databaseFactory.getDatabasesPath();
    final path = join(dbPath, 'app_cadastro.db');

    // aqui eu precisei deletar o banco existente para rodar os testes
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }

    // abrindo o banco e criando o esquema se não existir
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );

    return _db!;
  }

  Future<void> _onCreate(Database db, int version) async {
    //  cria tabela cadastro
    await db.execute('''
      CREATE TABLE cadastro (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        texto    TEXT    NOT NULL,
        numero   INTEGER NOT NULL UNIQUE CHECK (numero > 0)
      );
    ''');

    //  cria tabela de log
    await db.execute('''
      CREATE TABLE log_operacoes (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        tabela    TEXT    NOT NULL,
        operacao  TEXT    NOT NULL CHECK (operacao IN ('INSERT','UPDATE','DELETE')),
        data_hora TEXT    NOT NULL
      );
    ''');

    // trigger de INSERT
    await db.execute('''
      CREATE TRIGGER trg_after_insert_cadastro
      AFTER INSERT ON cadastro
      BEGIN
        INSERT INTO log_operacoes (tabela, operacao, data_hora)
        VALUES ('cadastro','INSERT', datetime('now'));
      END;
    ''');

    // trigger de UPDATE
    await db.execute('''
      CREATE TRIGGER trg_after_update_cadastro
      AFTER UPDATE ON cadastro
      BEGIN
        INSERT INTO log_operacoes (tabela, operacao, data_hora)
        VALUES ('cadastro','UPDATE', datetime('now'));
      END;
    ''');

    // trigger de DELETE
    await db.execute('''
      CREATE TRIGGER trg_after_delete_cadastro
      AFTER DELETE ON cadastro
      BEGIN
        INSERT INTO log_operacoes (tabela, operacao, data_hora)
        VALUES ('cadastro','DELETE', datetime('now'));
      END;
    ''');
  }

  /// aqui estou exportando o banco para um destino em que posso modificar no botão que configurei na home_page.dart
  Future<String> exportDatabase(String exportDirPath) async {
    final dbPath = await databaseFactory.getDatabasesPath();
    final source = File(join(dbPath, 'app_cadastro.db'));
    final destFolder = Directory(exportDirPath);
    if (!await destFolder.exists()) {
      await destFolder.create(recursive: true);
    }
    final destination = File(join(exportDirPath, 'app_cadastro_export.db'));
    await source.copy(destination.path);
    return destination.path;
  }
}
