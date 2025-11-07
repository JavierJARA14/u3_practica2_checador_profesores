import 'package:flutter/material.dart';
import 'principal.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control de Asistencia RH',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: const App04(),
    );
  }
}

class App04 extends StatefulWidget {
  const App04({super.key});

  @override
  State<App04> createState() => _App04State();
}

class _App04State extends State<App04> {
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Acceso RH - Asistencia"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 45),
                Icon(
                  Icons.admin_panel_settings,
                  size: 250,
                  color: colors.primary.withOpacity(0.8),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _userController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Usuario (RH)",
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Contraseña",
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 60,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        String user = _userController.text;
                        String password = _passwordController.text;

                        if (user == 'rh_admin' && password == 'escuela123') {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Principal()),
                          );
                        } else {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Container(
                                padding: const EdgeInsets.all(20),
                                height: 100,
                                child: const Center(
                                  child: Text(
                                    "Usuario o contraseña incorrectos",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.red,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.check_box),
                          SizedBox(
                            width: 6,
                          ),
                          Text("Ingresar"),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    TextButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return Container(
                                padding: const EdgeInsets.all(20),
                                height: 100,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.email,
                                      color: colors.primary,
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      "Contacte al administrador.",
                                      style: TextStyle(fontSize: 16),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ));
                          },
                        );
                      },
                      child: const Text("Olvide la contraseña"),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
