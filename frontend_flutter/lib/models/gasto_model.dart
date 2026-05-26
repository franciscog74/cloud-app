class Gasto {
  final String idUsuario;
  final DateTime fechaRegistro;
  final int categoriaId;
  final double monto;

  Gasto({
    required this.idUsuario,
    required this.fechaRegistro,
    required this.categoriaId,
    required this.monto,
  });

  Map<String, dynamic> toJson() => {
        'id_usuario': idUsuario,
        'fecha_registro': fechaRegistro.toIso8601String(),
        'categoria': categoriaId,
        'monto': monto,
      };
}