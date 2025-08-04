import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:main/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apple Store CRUD',
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Función para obtener el ícono según el tipo de dispositivo
  IconData _getDeviceIcon(String? tipo) {
    switch (tipo?.toLowerCase()) {
      case 'celular':
        return Icons.phone_iphone;
      case 'computadora':
      case 'mac':
        return Icons.laptop_mac;
      case 'tablet':
        return Icons.tablet_mac;
      case 'audifonos':
      case 'auriculares':
        return Icons.headset;
      case 'smartwatch':
      case 'watch':
        return Icons.watch;
      default:
        return Icons.devices_other;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apple Store CRUD')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getDevices(),
        builder: (context, snapshot) {
          // DEBUG: Imprime el estado completo
          print("""
          🛠️ Estado del FutureBuilder 🛠️
          ConnectionState: ${snapshot.connectionState}
          HasData: ${snapshot.hasData}
          HasError: ${snapshot.hasError}
          Error: ${snapshot.error}
          Data: ${snapshot.data}
          """);

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 50),
                  Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 50),
                  const Text("No se encontraron dispositivos"),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text("Reintentar"),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final device = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: Icon(
                    _getDeviceIcon(device['Tipo']),
                    color: Colors.blue, // Color estilo Apple
                    size: 32,
                  ),
                  title: Text(device['Modelo'] ?? 'Modelo no especificado'),
                  subtitle: Text(
                    "${device['Capacidad'] ?? 'Capacidad no especificada'} - "
                    "\$${device['Precio']?.toString() ?? 'Precio no disponible'}",
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() {}),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}