class Materia {
  final String nmat;
  final String descripcion;

  Materia({required this.nmat, required this.descripcion});

  Map<String, dynamic> toMap() {
    return {
      'NMAT': nmat,
      'DESCRIPCION': descripcion,
    };
  }

  factory Materia.fromMap(Map<String, dynamic> map) {
    return Materia(
      nmat: map['NMAT'],
      descripcion: map['DESCRIPCION'],
    );
  }
}