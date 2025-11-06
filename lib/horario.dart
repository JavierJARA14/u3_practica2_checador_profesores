class Horario {
  final int? nhorario;
  final String nprofesor;
  final String nmat;
  final String hora;
  final String edificio;
  final String salon;

  Horario({
    this.nhorario,
    required this.nprofesor,
    required this.nmat,
    required this.hora,
    required this.edificio,
    required this.salon,
  });

  Map<String, dynamic> toMap() {
    return {
      'NHORARIO': nhorario,
      'NPROFESOR': nprofesor,
      'NMAT': nmat,
      'HORA': hora,
      'EDIFICIO': edificio,
      'SALON': salon,
    };
  }

  factory Horario.fromMap(Map<String, dynamic> map) {
    return Horario(
      nhorario: map['NHORARIO'],
      nprofesor: map['NPROFESOR'],
      nmat: map['NMAT'],
      hora: map['HORA'],
      edificio: map['EDIFICIO'],
      salon: map['SALON'],
    );
  }
}