class Cadastro {
  final int? id;
  final String texto;
  final int numero;

  Cadastro({this.id, required this.texto, required this.numero});

  factory Cadastro.fromMap(Map<String, dynamic> m) => Cadastro(
    id: m['id'] as int?,
    texto: m['texto'] as String,
    numero: m['numero'] as int,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'texto': texto,
    'numero': numero,
  };
}
