import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'src/cadastro_repository.dart';
import 'src/home_page.dart';
//Vitor Hugo Evaldt Silveira 20/05/2025
//aplicação crud com flutter e sqlite para desktop
//observações::
// utilizei o VScode com a extensão do flutter para desktop
// e o DB Browser do SQLite para verificar o funcionamento do banco
// na pasta assets tem o arquivo SQL das tabelas e triggers, utilizei a mesma lógica do teste anterior, porém acabei
// não utilizando o arquivo, pois fiz a criação do banco diretamente no código, mas deixei o arquivo para referência


//utilização da interface::
//para efetivar a opercao de update, basta selecionar o registro que deseja alterar (icone de alteração na linha do registro),
// preencher os campos e clicar no botão de update (icone de 'correto' na parte superior direita da tela)
void main() {
  // habilitando SQLite para desktop
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CadastroRepository(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro Flutter Desktop',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}
