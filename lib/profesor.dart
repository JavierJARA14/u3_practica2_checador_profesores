class Profesor {
  final String nprofesor;
  final String nombre;
  final String carrera;

  Profesor({required this.nprofesor, required this.nombre, required this.carrera});

  Map<String, dynamic> toMap() {
    return {
      'NPROFESOR': nprofesor,
      'NOMBRE': nombre,
      'CARRERA': carrera,
    };
  }

  factory Profesor.fromMap(Map<String, dynamic> map) {
    return Profesor(
      nprofesor: map['NPROFESOR'],
      nombre: map['NOMBRE'],
      carrera: map['CARRERA'],
    );
  }
}