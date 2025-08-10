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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  void _showAddDeviceDialog() {
    final formKey = GlobalKey<FormState>();
    final Map<String, dynamic> newDevice = {
      'Modelo': '',
      'Tipo': 'Celular',
      'Capacidad': '',
      'Precio': 0.0,
      'Color': 'Space Gray',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir nuevo dispositivo'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: 'Celular',
                  items: const [
                    DropdownMenuItem(value: 'Celular', child: Text('Celular')),
                    DropdownMenuItem(value: 'Mac', child: Text('Mac')),
                    DropdownMenuItem(value: 'iPad', child: Text('iPad')),
                    DropdownMenuItem(value: 'Watch', child: Text('Apple Watch')),
                    DropdownMenuItem(value: 'AirPods', child: Text('AirPods')),
                  ],
                  onChanged: (value) => newDevice['Tipo'] = value,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Modelo'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo requerido' : null,
                  onSaved: (value) => newDevice['Modelo'] = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Capacidad'),
                  onSaved: (value) => newDevice['Capacidad'] = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Precio'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo requerido' : null,
                  onSaved: (value) =>
                      newDevice['Precio'] = double.tryParse(value ?? '0') ?? 0,
                ),
                DropdownButtonFormField<String>(
                  value: 'Space Gray',
                  items: const [
                    DropdownMenuItem(value: 'Space Gray', child: Text('Space Gray')),
                    DropdownMenuItem(value: 'Silver', child: Text('Silver')),
                    DropdownMenuItem(value: 'Gold', child: Text('Gold')),
                    DropdownMenuItem(value: 'Graphite', child: Text('Graphite')),
                    DropdownMenuItem(value: 'Blue', child: Text('Blue')),
                    DropdownMenuItem(value: 'Pink', child: Text('Pink')),
                    DropdownMenuItem(value: 'White', child: Text('White')),
                  ],
                  onChanged: (value) => newDevice['Color'] = value,
                  decoration: const InputDecoration(labelText: 'Color'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                try {
                  await _firebaseService.addDevice(newDevice);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dispositivo añadido')),
                    );
                    setState(() {});
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showDeviceDetails(Map<String, dynamic> device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(device['Modelo'] ?? 'Dispositivo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(_getDeviceIcon(device['Tipo']), size: 40),
              title: Text('Tipo: ${device['Tipo'] ?? 'No especificado'}'),
            ),
            Text('Capacidad: ${device['Capacidad'] ?? 'No especificada'}'),
            Text('Precio: \$${device['Precio']?.toStringAsFixed(2) ?? '0.00'}'),
            Text('Color: ${device['Color'] ?? 'No especificado'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _showEditDeviceDialog(device),
            child: const Text('Editar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

void _showEditDeviceDialog(Map<String, dynamic> device) {
  // 1. Asegurarnos que el dispositivo tiene un ID
  final String deviceId = device['id'] ?? '';
  if (deviceId.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: Dispositivo no tiene ID')),
    );
    return;
  }

  // 2. Crear controladores con los valores actuales
  final TextEditingController modelController = TextEditingController(text: device['Modelo']);
  final TextEditingController capacityController = TextEditingController(text: device['Capacidad']);
  final TextEditingController priceController = TextEditingController(text: device['Precio']?.toString());
  String selectedType = device['Tipo'] ?? 'Celular';
  String selectedColor = device['Color'] ?? 'Space Gray';

  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Editar dispositivo'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedType,
                items: const [
                    DropdownMenuItem(value: 'Celular', child: Text('Celular')),
                    DropdownMenuItem(value: 'Mac', child: Text('Mac')),
                    DropdownMenuItem(value: 'iPad', child: Text('iPad')),
                    DropdownMenuItem(value: 'Watch', child: Text('Apple Watch')),
                    DropdownMenuItem(value: 'AirPods', child: Text('AirPods')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    selectedType = value;
                  }
                },
                decoration: const InputDecoration(labelText: 'Tipo'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: modelController,
                decoration: const InputDecoration(labelText: 'Modelo'),
                validator: (value) => value?.isEmpty ?? true ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: capacityController,
                decoration: const InputDecoration(labelText: 'Capacidad'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedColor,
                items: const [
                    DropdownMenuItem(value: 'Space Gray', child: Text('Space Gray')),
                    DropdownMenuItem(value: 'Silver', child: Text('Silver')),
                    DropdownMenuItem(value: 'Gold', child: Text('Gold')),
                    DropdownMenuItem(value: 'Graphite', child: Text('Graphite')),
                    DropdownMenuItem(value: 'Blue', child: Text('Blue')),
                    DropdownMenuItem(value: 'Pink', child: Text('Pink')),
                    DropdownMenuItem(value: 'White', child: Text('White')),
                  ],
                  onChanged: (value) => device['Color'] = value,
                  decoration: const InputDecoration(labelText: 'Color'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final updates = {
                  'Modelo': modelController.text,
                  'Tipo': device['Tipo'],
                  'Capacidad': capacityController.text,
                  'Precio': double.tryParse(priceController.text) ?? 0,
                  'Color': device['Color'],
                };

                try {
                  await _firebaseService.updateDevice(device['id'], updates);
                  if (mounted) {
                    Navigator.pop(context); // Cerrar diálogo de edición
                    Navigator.pop(context); // Cerrar diálogo de detalles
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dispositivo actualizado')),
                    );
                    setState(() {});
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Guardar'),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final confirm = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmar eliminación'),
                  content: const Text('¿Estás seguro de eliminar este dispositivo?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                try {
                  await _firebaseService.deleteDevice(device['id']);
                  if (mounted) {
                    Navigator.pop(context); // Cerrar diálogo de edición
                    Navigator.pop(context); // Cerrar diálogo de detalles
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dispositivo eliminado')),
                    );
                    setState(() {});
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apple Store CRUD'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar dispositivos',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _firebaseService.getDevices(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 50),
                        Text("Error: ${snapshot.error}"),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text("Reintentar"),
                        ),
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
                          onPressed: _showAddDeviceDialog,
                          child: const Text("Añadir primer dispositivo"),
                        ),
                      ],
                    ),
                  );
                }

                // Filtrar dispositivos según búsqueda
                final filteredDevices = snapshot.data!.where((device) {
                  final searchTerm = _searchController.text.toLowerCase();
                  return device['Modelo']?.toString().toLowerCase().contains(searchTerm) == true ||
                      device['Tipo']?.toString().toLowerCase().contains(searchTerm) == true ||
                      device['Capacidad']?.toString().toLowerCase().contains(searchTerm) == true;
                }).toList();

                if (filteredDevices.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 50),
                        const Text("No se encontraron resultados"),
                        ElevatedButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          child: const Text("Limpiar búsqueda"),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredDevices.length,
                  itemBuilder: (context, index) {
                    final device = filteredDevices[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: Icon(
                          _getDeviceIcon(device['Tipo']),
                          color: Colors.black,
                          size: 32,
                        ),
                        title: Text(
                          device['Modelo'] ?? 'Modelo no especificado',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "${device['Tipo'] ?? 'Tipo no especificado'} • "
                          "${device['Capacidad'] ?? 'Capacidad no especificada'} • "
                          "\$${device['Precio']?.toStringAsFixed(2) ?? '0.00'}",
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showDeviceDetails(device),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDeviceDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}