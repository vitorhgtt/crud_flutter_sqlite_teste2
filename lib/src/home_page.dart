import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'database_helper.dart';
import 'cadastro_model.dart';
import 'cadastro_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  String _texto = '';
  int _numero = 0;
  Cadastro? _editando;

  @override
  void initState() {
    super.initState();
    context.read<CadastroRepository>().loadAll();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final repo = context.read<CadastroRepository>();

    final cadastro = Cadastro(
      id: _editando?.id,
      texto: _texto,
      numero: _numero,
    );

    try {
      if (_editando == null) {
        await repo.insert(cadastro);
      } else {
        await repo.update(cadastro);
      }
      setState(() => _editando = null);
      _formKey.currentState!.reset();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.toString()}')),
      );
    }
  }

  Future<void> _exportDatabase() async {
    // utilizei o caminho C:\Temp para exportar o banco, durante a utilização fiz todas as operações
    // de inserção, atualização e exclusão, e depois fiz a exportação do banco, 
    // e verifiquei que o banco foi exportado corretamente utilizando o 
    // DB Browser do SQLite e fazendo as querys de SELECT nas tabelas
    const exportPath = r"C:\Temp";
    try {
      final caminho = await DatabaseHelper.instance.exportDatabase(exportPath);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Banco exportado em:\n$caminho')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao exportar banco: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final itens = context.watch<CadastroRepository>().itens;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro Flutter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            tooltip: 'Exportar banco',
            onPressed: _exportDatabase,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Exportar DB',
        onPressed: _exportDatabase,
        child: const Icon(Icons.save_alt),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      initialValue: _editando?.texto,
                      decoration: const InputDecoration(labelText: 'Texto'),
                      validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
                      onSaved: (v) => _texto = v!,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      initialValue: _editando != null ? '${_editando!.numero}' : '',
                      decoration: const InputDecoration(labelText: 'Número'),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Obrigatório';
                        final n = int.tryParse(v);
                        if (n == null || n <= 0) return '> 0';
                        return null;
                      },
                      onSaved: (v) => _numero = int.parse(v!),
                    ),
                  ),
                  IconButton(
                    icon: Icon(_editando == null ? Icons.add : Icons.check),
                    onPressed: _onSubmit,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: itens.length,
                itemBuilder: (_, i) {
                  final c = itens[i];
                  return ListTile(
                    title: Text('${c.texto} (${c.numero})'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            setState(() => _editando = c);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => context.read<CadastroRepository>().delete(c.id!),
                        ),
                      ],
                    ),   
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
