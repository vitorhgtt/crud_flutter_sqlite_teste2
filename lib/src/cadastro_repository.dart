import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'cadastro_model.dart';

class CadastroRepository extends ChangeNotifier {
  List<Cadastro> _itens = [];
  List<Cadastro> get itens => List.unmodifiable(_itens);

  Future<void> loadAll() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('cadastro');
    _itens = rows.map((r) => Cadastro.fromMap(r)).toList();
    notifyListeners();
  }

  Future<void> insert(Cadastro c) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('cadastro', c.toMap());
    await loadAll();
  }

  Future<void> update(Cadastro c) async {
    final db = await DatabaseHelper.instance.database;
    await db.update('cadastro', c.toMap(),
        where: 'id = ?', whereArgs: [c.id]);
    await loadAll();
  }

  Future<void> delete(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('cadastro', where: 'id = ?', whereArgs: [id]);
    await loadAll();
  }
}
