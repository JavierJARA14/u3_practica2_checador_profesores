import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'materia.dart';
import 'profesor.dart';
import 'horario.dart';
import 'asistencia.dart';

class DBAsistencia {

  static final DBAsistencia instance = DBAsistencia._init();
  static Database? _database;

  DBAsistencia._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('asistencia.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const textType = 'TEXT NOT NULL';
    const intAutoPk = 'INTEGER PRIMARY KEY AUTOINCREMENT';

    await db.execute('''
    CREATE TABLE MATERIA ( 
      NMAT $textType PRIMARY KEY, 
      DESCRIPCION TEXT
      )
    ''');

    await db.execute('''
    CREATE TABLE PROFESOR ( 
      NPROFESOR $textType PRIMARY KEY, 
      NOMBRE $textType, 
      CARRERA $textType
      )
    ''');

    await db.execute('''
    CREATE TABLE HORARIO ( 
      NHORARIO $intAutoPk, 
      NPROFESOR $textType, 
      NMAT $textType, 
      HORA $textType,
      EDIFICIO TEXT,
      SALON TEXT,
      FOREIGN KEY (NPROFESOR) REFERENCES PROFESOR (NPROFESOR) ON DELETE CASCADE,
      FOREIGN KEY (NMAT) REFERENCES MATERIA (NMAT) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
    CREATE TABLE ASISTENCIA ( 
      IDASISTENCIA $intAutoPk, 
      NHORARIO INTEGER NOT NULL,
      FECHA $textType,
      ASISTENCIA INTEGER NOT NULL,
      FOREIGN KEY (NHORARIO) REFERENCES HORARIO (NHORARIO) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> createMateria(Materia materia) async {
    final db = await instance.database;
    return await db.insert('MATERIA', materia.toMap());
  }

  Future<Materia> readMateria(String nmat) async {
    final db = await instance.database;
    final maps = await db.query(
      'MATERIA',
      columns: ['NMAT', 'DESCRIPCION'],
      where: 'NMAT = ?',
      whereArgs: [nmat],
    );

    if (maps.isNotEmpty) {
      return Materia.fromMap(maps.first);
    } else {
      throw Exception('Materia con NMAT $nmat no encontrada');
    }
  }

  Future<List<Materia>> readAllMaterias() async {
    final db = await instance.database;
    final result = await db.query('MATERIA');
    return result.map((json) => Materia.fromMap(json)).toList();
  }

  Future<int> updateMateria(Materia materia) async {
    final db = await instance.database;
    return db.update(
      'MATERIA',
      materia.toMap(),
      where: 'NMAT = ?',
      whereArgs: [materia.nmat],
    );
  }

  Future<int> deleteMateria(String nmat) async {
    final db = await instance.database;
    return await db.delete(
      'MATERIA',
      where: 'NMAT = ?',
      whereArgs: [nmat],
    );
  }


  Future<int> createProfesor(Profesor profesor) async {
    final db = await instance.database;
    return await db.insert('PROFESOR', profesor.toMap());
  }

  Future<Profesor> readProfesor(String nprofesor) async {
    final db = await instance.database;
    final maps = await db.query(
      'PROFESOR',
      where: 'NPROFESOR = ?',
      whereArgs: [nprofesor],
    );

    if (maps.isNotEmpty) {
      return Profesor.fromMap(maps.first);
    } else {
      throw Exception('Profesor $nprofesor no encontrado');
    }
  }

  Future<List<Profesor>> readAllProfesores() async {
    final db = await instance.database;
    final result = await db.query('PROFESOR');
    return result.map((json) => Profesor.fromMap(json)).toList();
  }

  Future<int> updateProfesor(Profesor profesor) async {
    final db = await instance.database;
    return db.update(
      'PROFESOR',
      profesor.toMap(),
      where: 'NPROFESOR = ?',
      whereArgs: [profesor.nprofesor],
    );
  }

  Future<int> deleteProfesor(String nprofesor) async {
    final db = await instance.database;
    return await db.delete(
      'PROFESOR',
      where: 'NPROFESOR = ?',
      whereArgs: [nprofesor],
    );
  }

  Future<int> createHorario(Horario horario) async {
    final db = await instance.database;
    return await db.insert('HORARIO', horario.toMap());
  }

  Future<Horario> readHorario(int nhorario) async {
    final db = await instance.database;
    final maps = await db.query(
      'HORARIO',
      where: 'NHORARIO = ?',
      whereArgs: [nhorario],
    );

    if (maps.isNotEmpty) {
      return Horario.fromMap(maps.first);
    } else {
      throw Exception('Horario $nhorario no encontrado');
    }
  }

  Future<List<Horario>> readAllHorarios() async {
    final db = await instance.database;
    final result = await db.query('HORARIO');
    return result.map((json) => Horario.fromMap(json)).toList();
  }

  Future<int> updateHorario(Horario horario) async {
    final db = await instance.database;
    return db.update(
      'HORARIO',
      horario.toMap(),
      where: 'NHORARIO = ?',
      whereArgs: [horario.nhorario],
    );
  }

  Future<int> deleteHorario(int nhorario) async {
    final db = await instance.database;
    return await db.delete(
      'HORARIO',
      where: 'NHORARIO = ?',
      whereArgs: [nhorario],
    );
  }

  Future<int> createAsistencia(Asistencia asistencia) async {
    final db = await instance.database;
    return await db.insert('ASISTENCIA', asistencia.toMap());
  }

  Future<Asistencia> readAsistencia(int idasistencia) async {
    final db = await instance.database;
    final maps = await db.query(
      'ASISTENCIA',
      where: 'IDASISTENCIA = ?',
      whereArgs: [idasistencia],
    );

    if (maps.isNotEmpty) {
      return Asistencia.fromMap(maps.first);
    } else {
      throw Exception('Asistencia $idasistencia no encontrada');
    }
  }

  Future<List<Asistencia>> readAllAsistencias() async {
    final db = await instance.database;
    final result = await db.query('ASISTENCIA');
    return result.map((json) => Asistencia.fromMap(json)).toList();
  }

  Future<int> updateAsistencia(Asistencia asistencia) async {
    final db = await instance.database;
    return db.update(
      'ASISTENCIA',
      asistencia.toMap(),
      where: 'IDASISTENCIA = ?',
      whereArgs: [asistencia.idasistencia],
    );
  }

  Future<int> deleteAsistencia(int idasistencia) async {
    final db = await instance.database;
    return await db.delete(
      'ASISTENCIA',
      where: 'IDASISTENCIA = ?',
      whereArgs: [idasistencia],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  /// CONSULTA 1
  /// Buscar profesores por hora y edificio.
  /// (Ej. "8am" y "UD")
  Future<List<Profesor>> getProfesoresPorHoraYEdificio(String hora, String edificio) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT P.* FROM PROFESOR P
      JOIN HORARIO H ON P.NPROFESOR = H.NPROFESOR
      WHERE H.HORA LIKE ? AND H.EDIFICIO = ?
    ''', ['%$hora%', edificio]);

    return result.map((json) => Profesor.fromMap(json)).toList();
  }

  /// CONSULTA 2
  /// Mostrar profesores que SÍ asistieron en una fecha específica.
  Future<List<Profesor>> getProfesoresConAsistenciaPorFecha(String fecha) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT DISTINCT P.* FROM PROFESOR P
      JOIN HORARIO H ON P.NPROFESOR = H.NPROFESOR
      JOIN ASISTENCIA A ON H.NHORARIO = A.NHORARIO
      WHERE A.FECHA = ? AND A.ASISTENCIA = 1
    ''', [fecha]);

    return result.map((json) => Profesor.fromMap(json)).toList();
  }

  /// CONSULTA 3
  /// Obtener todos los horarios (con nombre de profesor y materia)
  /// para un edificio y salón específicos.
  Future<List<Map<String, dynamic>>> getHorarioCompletoPorSalon(String edificio, String salon) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT H.HORA, P.NOMBRE, M.DESCRIPCION 
      FROM HORARIO H
      JOIN PROFESOR P ON H.NPROFESOR = P.NPROFESOR
      JOIN MATERIA M ON H.NMAT = M.NMAT
      WHERE H.EDIFICIO = ? AND H.SALON = ?
      ORDER BY H.HORA
    ''', [edificio, salon]);
    return result;
  }


  /// CONSULTA 4
  /// Obtener el historial de asistencias (y faltas) de una materia específica
  /// (por su NMAT, ej. 'ISC-342842')
  Future<List<Asistencia>> getHistorialAsistenciaPorMateria(String nmat) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT A.*
      FROM ASISTENCIA A
      JOIN HORARIO H ON A.NHORARIO = H.NHORARIO
      WHERE H.NMAT = ?
      ORDER BY A.FECHA DESC
    ''', [nmat]);

    return result.map((json) => Asistencia.fromMap(json)).toList();
  }

  /// CONSULTA 5
  /// Contar cuántas clases (Horarios) tiene cada profesor.
  Future<List<Map<String, dynamic>>> getConteoClasesPorProfesor() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT P.NOMBRE, COUNT(H.NHORARIO) as CONTEO_CLASES
      FROM PROFESOR P
      LEFT JOIN HORARIO H ON P.NPROFESOR = H.NPROFESOR
      GROUP BY P.NPROFESOR, P.NOMBRE
      ORDER BY CONTEO_CLASES DESC
    ''');

    return result;
  }
}