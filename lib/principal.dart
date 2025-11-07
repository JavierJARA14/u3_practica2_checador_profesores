import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Necesario para formatear fechas (agregalo a pubspec.yaml si falla: intl: ^0.18.0)
import 'db_asistencia.dart';
import 'profesor.dart';
import 'materia.dart';
import 'horario.dart';
import 'asistencia.dart';
import 'main.dart';

class Principal extends StatefulWidget {
  const Principal({super.key});

  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  String seccionActual = "Profesores";
  int _index = 0;
  String titulo = "Profesores";

  // --- CONTROLADORES Y VARIABLES GLOBALES ---
  final nProfesorCtrl = TextEditingController();
  final nombreProfCtrl = TextEditingController();
  final carreraProfCtrl = TextEditingController();
  List<Profesor> listaProfesores = [];
  Profesor? profesorSeleccionado; // Para Dropdown

  final nMatCtrl = TextEditingController();
  final descripcionMatCtrl = TextEditingController();
  List<Materia> listaMaterias = [];
  Materia? materiaSeleccionada; // Para Dropdown

  // Controladores Horario
  final horaCtrl = TextEditingController();
  final edificioCtrl = TextEditingController();
  final salonCtrl = TextEditingController();
  List<Horario> listaHorarios = [];

  // Controladores Reportes
  final repHoraCtrl = TextEditingController();
  final repEdificioCtrl = TextEditingController();
  final repFechaCtrl = TextEditingController();
  final repSalonCtrl = TextEditingController();
  final repMateriaCtrl = TextEditingController();

  // Variables para filtros de reportes
  String fHora = "", fEdificio = "", fFecha = "", fSalon = "", fMateria = "";

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  void cargarDatos() async {
    var profs = await DBAsistencia.instance.readAllProfesores();
    var mats = await DBAsistencia.instance.readAllMaterias();
    var hors = await DBAsistencia.instance.readAllHorarios();
    setState(() {
      listaProfesores = profs;
      listaMaterias = mats;
      listaHorarios = hors;
    });
  }

  void limpiarTodo() {
    nProfesorCtrl.clear(); nombreProfCtrl.clear(); carreraProfCtrl.clear();
    nMatCtrl.clear(); descripcionMatCtrl.clear();
    horaCtrl.clear(); edificioCtrl.clear(); salonCtrl.clear();
    profesorSeleccionado = null;
    materiaSeleccionada = null;
  }

  // ==========================================
  // NAVEGACIÓN (DRAWER)
  // ==========================================
  @override
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
            accountName: const Text("RH Admin"),
            accountEmail: const Text("Control de Asistencia"),
            currentAccountPicture: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.admin_panel_settings, size: 40)),
          ),
          _menuItem(Icons.person, "Profesores", "Profesores", 0),
          _menuItem(Icons.book, "Materias", "Materias", 0),
          _menuItem(Icons.calendar_month, "Horarios (Clases)", "Horarios", 0),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text("Operaciones Diarias", style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold)),
          ),
          _menuItem(Icons.check_circle, "Pasar Asistencia", "Asistencia", 0, colorIcon: Colors.green[700]),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text("Consultas", style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold)),
          ),
          _menuItem(Icons.analytics, "Reportes", "Reportes", 0, colorIcon: Colors.indigo),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión'),
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyApp())),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String text, String seccion, int index, {Color? colorIcon}) {
    return ListTile(
      leading: Icon(icon, color: colorIcon),
      title: Text(text),
      onTap: () {
        setState(() { titulo = text; seccionActual = seccion; _index = index; limpiarTodo(); });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo), centerTitle: true),
      drawer: _buildDrawer(),
      body: dinamico(),
      floatingActionButton: (seccionActual == "Profesores" || seccionActual == "Materias" || seccionActual == "Horarios") && _index == 0
          ? FloatingActionButton(
        onPressed: () { setState(() { _index = 1; titulo = "Agregar $seccionActual"; limpiarTodo(); }); },
        child: const Icon(Icons.add),
      )
          : null,
    );
  }

  Widget dinamico() {
    switch (seccionActual) {
      case "Profesores": return _index == 1 ? formProfesor() : listaProfs();
      case "Materias": return _index == 1 ? formMateria() : listaMats();
      case "Horarios": return _index == 1 ? formHorario() : listaHors();
      case "Asistencia": return moduloAsistencia();
      case "Reportes": return moduloReportes();
      default: return const Center(child: Text("Sección no encontrada"));
    }
  }

  // ==========================================
  // MÓDULO 1: PROFESORES
  // ==========================================
  Widget listaProfs() {
    return ListView.builder(
      itemCount: listaProfesores.length,
      itemBuilder: (ctx, i) => ListTile(
        leading: const Icon(Icons.person),
        title: Text(listaProfesores[i].nombre),
        subtitle: Text(listaProfesores[i].carrera),
        trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async {
          await DBAsistencia.instance.deleteProfesor(listaProfesores[i].nprofesor);
          cargarDatos();
        }),
      ),
    );
  }

  Widget formProfesor() {
    return _baseForm([
      _input(nProfesorCtrl, "ID Profesor", const Icon(Icons.badge)),
      _input(nombreProfCtrl, "Nombre Completo", const Icon(Icons.person)),
      _input(carreraProfCtrl, "Carrera", const Icon(Icons.work)),
    ], () async {
      await DBAsistencia.instance.createProfesor(Profesor(nprofesor: nProfesorCtrl.text, nombre: nombreProfCtrl.text, carrera: carreraProfCtrl.text));
      cargarDatos(); setState(() { _index = 0; titulo = "Profesores"; });
    });
  }

  // ==========================================
  // MÓDULO 2: MATERIAS
  // ==========================================
  Widget listaMats() {
    return ListView.builder(
      itemCount: listaMaterias.length,
      itemBuilder: (ctx, i) => ListTile(
        leading: const Icon(Icons.book),
        title: Text(listaMaterias[i].descripcion),
        subtitle: Text("Clave: ${listaMaterias[i].nmat}"),
        trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async {
          await DBAsistencia.instance.deleteMateria(listaMaterias[i].nmat);
          cargarDatos();
        }),
      ),
    );
  }

  Widget formMateria() {
    return _baseForm([
      _input(nMatCtrl, "Clave Materia", const Icon(Icons.vpn_key)),
      _input(descripcionMatCtrl, "Nombre Materia", const Icon(Icons.description)),
    ], () async {
      await DBAsistencia.instance.createMateria(Materia(nmat: nMatCtrl.text, descripcion: descripcionMatCtrl.text));
      cargarDatos(); setState(() { _index = 0; titulo = "Materias"; });
    });
  }

  // ==========================================
  // MÓDULO 3: HORARIOS (Vincula Profe y Materia)
  // ==========================================
  Widget listaHors() {
    if (listaHorarios.isEmpty) return const Center(child: Text("Sin horarios definidos"));
    return ListView.builder(
      itemCount: listaHorarios.length,
      itemBuilder: (ctx, i) {
        // Buscamos los nombres reales usando las FKs
        String nomProf = listaProfesores.firstWhere((p) => p.nprofesor == listaHorarios[i].nprofesor, orElse: () => Profesor(nprofesor: "", nombre: "Desconocido", carrera: "")).nombre;
        String nomMat = listaMaterias.firstWhere((m) => m.nmat == listaHorarios[i].nmat, orElse: () => Materia(nmat: "", descripcion: "Desconocida")).descripcion;
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(child: Text(listaHorarios[i].hora.split(':')[0])), // Muestra la hora
            title: Text("$nomMat - $nomProf"),
            subtitle: Text("${listaHorarios[i].hora} | Edificio: ${listaHorarios[i].edificio} | Salón: ${listaHorarios[i].salon}"),
            trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async {
              await DBAsistencia.instance.deleteHorario(listaHorarios[i].nhorario!);
              cargarDatos();
            }),
          ),
        );
      },
    );
  }

  Widget formHorario() {
    // Dropdowns para garantizar integridad referencial
    return _baseForm([
      DropdownButtonFormField<Profesor>(
        decoration: const InputDecoration(labelText: "Seleccionar Profesor", border: OutlineInputBorder()),
        value: profesorSeleccionado,
        items: listaProfesores.map((p) => DropdownMenuItem(value: p, child: Text(p.nombre))).toList(),
        onChanged: (v) => setState(() => profesorSeleccionado = v),
      ),
      const SizedBox(height: 20),
      DropdownButtonFormField<Materia>(
        decoration: const InputDecoration(labelText: "Seleccionar Materia", border: OutlineInputBorder()),
        value: materiaSeleccionada,
        items: listaMaterias.map((m) => DropdownMenuItem(value: m, child: Text(m.descripcion))).toList(),
        onChanged: (v) => setState(() => materiaSeleccionada = v),
      ),
      const SizedBox(height: 20),
      _input(horaCtrl, "Hora (ej. 08:00)", const Icon(Icons.access_time)),
      _input(edificioCtrl, "Edificio", const Icon(Icons.location_city)),
      _input(salonCtrl, "Salón", const Icon(Icons.room)),
    ], () async {
      if (profesorSeleccionado == null || materiaSeleccionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Seleccione Profesor y Materia")));
        return;
      }
      await DBAsistencia.instance.createHorario(Horario(
          nprofesor: profesorSeleccionado!.nprofesor,
          nmat: materiaSeleccionada!.nmat,
          hora: horaCtrl.text,
          edificio: edificioCtrl.text,
          salon: salonCtrl.text
      ));
      cargarDatos(); setState(() { _index = 0; titulo = "Horarios"; });
    });
  }

  // ==========================================
  // MÓDULO 4: PASAR ASISTENCIA (Funcionalidad Core)
  // ==========================================
  Widget moduloAsistencia() {
    if (listaHorarios.isEmpty) return const Center(child: Text("Primero registre Horarios para poder tomar lista."));

    // Obtener fecha de hoy formato YYYY-MM-DD
    String hoy = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Column(
      children: [
        Padding(padding: const EdgeInsets.all(15), child: Text("Fecha: $hoy", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        Expanded(
          child: ListView.builder(
            itemCount: listaHorarios.length,
            itemBuilder: (ctx, i) {
              var h = listaHorarios[i];
              String nomProf = listaProfesores.firstWhere((p) => p.nprofesor == h.nprofesor, orElse: () => Profesor(nprofesor: "", nombre: "---", carrera: "")).nombre;
              String nomMat = listaMaterias.firstWhere((m) => m.nmat == h.nmat, orElse: () => Materia(nmat: "", descripcion: "---")).descripcion;

              return Card(
                color: Colors.indigo[50],
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text("$nomProf - $nomMat"),
                  subtitle: Text("Hora: ${h.hora} en ${h.edificio}-${h.salon}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton.filled(
                        style: IconButton.styleFrom(backgroundColor: Colors.green),
                        icon: const Icon(Icons.check, color: Colors.white),
                        tooltip: "Asistió",
                        onPressed: () => _registrarAsistencia(h.nhorario!, hoy, true),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        style: IconButton.styleFrom(backgroundColor: Colors.red),
                        icon: const Icon(Icons.close, color: Colors.white),
                        tooltip: "Faltó",
                        onPressed: () => _registrarAsistencia(h.nhorario!, hoy, false),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _registrarAsistencia(int idHorario, String fecha, bool asistio) async {
    try {
      await DBAsistencia.instance.createAsistencia(Asistencia(nhorario: idHorario, fecha: fecha, asistencia: asistio));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(asistio ? "Asistencia registrada ✅" : "Falta registrada ❌")));
    } catch (e) {
      // Opcional: Manejar si ya existe registro ese día para evitar duplicados
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ya se registró asistencia hoy para esta clase")));
    }
  }

  // ==========================================
  // MÓDULO 5: REPORTES (Consultas BD)
  // ==========================================
  Widget moduloReportes() {
    switch (_index) {
      case 0: return _menuReportes();
      case 1: return _repFiltroDoble(repHoraCtrl, repEdificioCtrl, "Hora", "Edificio", Icons.access_time, Icons.location_city, (v1, v2) => setState(() { fHora=v1; fEdificio=v2; }), _listaProfes(DBAsistencia.instance.getProfesoresPorHoraYEdificio(fHora, fEdificio)));
      case 2: return _repFiltroSimple(repFechaCtrl, "Fecha (YYYY-MM-DD)", Icons.calendar_today, (v) => setState(() => fFecha = v), _listaProfes(DBAsistencia.instance.getProfesoresConAsistenciaPorFecha(fFecha)));
      case 3: return _repFiltroDoble(repEdificioCtrl, repSalonCtrl, "Edificio", "Salón", Icons.location_city, Icons.room, (v1, v2) => setState(() { fEdificio=v1; fSalon=v2; }), _listaHorarioSalon());
      case 4: return _repFiltroSimple(repMateriaCtrl, "Clave Materia", Icons.vpn_key, (v) => setState(() => fMateria = v), _listaHistorialMateria());
      case 5: return _listaConteoProfes();
      default: return _menuReportes();
    }
  }

  Widget _menuReportes() {
    return ListView(padding: const EdgeInsets.all(20), children: [
      _btnRep("Profesores por Hora/Edificio", Icons.search, 1),
      _btnRep("Asistencia por Fecha", Icons.calendar_month, 2),
      _btnRep("Horario de Salón", Icons.room, 3),
      _btnRep("Historial por Materia", Icons.history_edu, 4),
      _btnRep("Conteo de Clases", Icons.bar_chart, 5),
    ]);
  }

  Widget _btnRep(String txt, IconData ico, int idx) {
    return Card(child: ListTile(leading: Icon(ico, color: Colors.indigo), title: Text(txt), trailing: const Icon(Icons.arrow_forward), onTap: () => setState(() { _index = idx; titulo = txt; limpiarFiltros(); })));
  }
  void limpiarFiltros() { fHora=""; fEdificio=""; fFecha=""; fSalon=""; fMateria=""; repHoraCtrl.clear(); repEdificioCtrl.clear(); repFechaCtrl.clear(); repSalonCtrl.clear(); repMateriaCtrl.clear(); }

  // --- Widgets Auxiliares Reportes ---
  Widget _repFiltroSimple(TextEditingController ctrl, String lbl, IconData ico, Function(String) onSearch, Widget resultados) {
    return Column(children: [Padding(padding: const EdgeInsets.all(15), child: Row(children: [Expanded(child: _input(ctrl, lbl, Icon(ico))), const SizedBox(width: 10), IconButton.filled(onPressed: () => onSearch(ctrl.text), icon: const Icon(Icons.search))])), Expanded(child: resultados)]);
  }
  Widget _repFiltroDoble(TextEditingController c1, TextEditingController c2, String l1, String l2, IconData i1, IconData i2, Function(String, String) onSearch, Widget resultados) {
    return Column(children: [Padding(padding: const EdgeInsets.all(15), child: Row(children: [Expanded(child: _input(c1, l1, Icon(i1))), const SizedBox(width: 10), Expanded(child: _input(c2, l2, Icon(i2))), const SizedBox(width: 10), IconButton.filled(onPressed: () => onSearch(c1.text, c2.text), icon: const Icon(Icons.search))])), Expanded(child: resultados)]);
  }
  Widget _listaProfes(Future<List<Profesor>> future) {
    return FutureBuilder<List<Profesor>>(future: future, builder: (c, s) {
      if (!s.hasData) return const Center(child: CircularProgressIndicator());
      if (s.data!.isEmpty) return const Center(child: Text("Sin resultados"));
      return ListView.builder(itemCount: s.data!.length, itemBuilder: (c, i) => Card(child: ListTile(title: Text(s.data![i].nombre), subtitle: Text(s.data![i].carrera), leading: const Icon(Icons.person))));
    });
  }
  Widget _listaHorarioSalon() { // Reporte 3
    return FutureBuilder<List<Map<String, dynamic>>>(future: DBAsistencia.instance.getHorarioCompletoPorSalon(fEdificio, fSalon), builder: (c, s) {
      if (!s.hasData || s.data!.isEmpty) return const Center(child: Text("Sin horarios aquí"));
      return ListView.builder(itemCount: s.data!.length, itemBuilder: (c, i) => ListTile(leading: Text(s.data![i]['HORA'], style: const TextStyle(fontWeight: FontWeight.bold)), title: Text(s.data![i]['DESCRIPCION']), subtitle: Text(s.data![i]['NOMBRE'])));
    });
  }
  Widget _listaHistorialMateria() { // Reporte 4
    return FutureBuilder<List<Asistencia>>(future: DBAsistencia.instance.getHistorialAsistenciaPorMateria(fMateria), builder: (c, s) {
      if (!s.hasData || s.data!.isEmpty) return const Center(child: Text("Sin historial"));
      return ListView.builder(itemCount: s.data!.length, itemBuilder: (c, i) => ListTile(title: Text("Fecha: ${s.data![i].fecha}"), trailing: Icon(s.data![i].asistencia ? Icons.check_circle : Icons.cancel, color: s.data![i].asistencia ? Colors.green : Colors.red)));
    });
  }
  Widget _listaConteoProfes() { // Reporte 5
    return FutureBuilder<List<Map<String, dynamic>>>(future: DBAsistencia.instance.getConteoClasesPorProfesor(), builder: (c, s) {
      if (!s.hasData) return const Center(child: CircularProgressIndicator());
      return ListView.builder(itemCount: s.data!.length, itemBuilder: (c, i) => ListTile(leading: CircleAvatar(child: Text("${s.data![i]['CONTEO_CLASES']}")), title: Text(s.data![i]['NOMBRE']), subtitle: const Text("Clases asignadas")));
    });
  }

  // ==========================================
  // UTILIDADES UI
  // ==========================================
  Widget _input(TextEditingController c, String label, Icon icon) => TextField(controller: c, decoration: InputDecoration(labelText: label, prefixIcon: icon, border: const OutlineInputBorder()));
  Widget _baseForm(List<Widget> fields, VoidCallback onSave) {
    return ListView(padding: const EdgeInsets.all(30), children: [...fields.map((f) => Padding(padding: const EdgeInsets.only(bottom: 15), child: f)), const SizedBox(height: 20), Row(mainAxisAlignment: MainAxisAlignment.center, children: [ElevatedButton(onPressed: onSave, child: const Text("Guardar")), const SizedBox(width: 20), TextButton(onPressed: () => setState(() { _index = 0; }), child: const Text("Cancelar"))])]);
  }
}
