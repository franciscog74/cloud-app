class Categoria {
  final int? id;
  final String nombre;
  final String idUsuario;
  final String color;

  Categoria({
    this.id,
    required this.nombre,
    required this.idUsuario,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'id_usuario': idUsuario,
        'color': color,
      };
}