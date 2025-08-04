import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List<Map<String, dynamic>>> getDevices() async {
  try {
    print("Obteniendo dispositivos de Firestore...");
    final querySnapshot = await FirebaseFirestore.instance
        .collection('HHH1') // Ajusta este nombre a tu colección real
        .get();

    print("Número de documentos obtenidos: ${querySnapshot.docs.length}");
    
    if (querySnapshot.docs.isEmpty) {
      print("La colección está vacía");
      return [];
    }

    final devices = querySnapshot.docs.map((doc) {
      print("Documento ID: ${doc.id}");
      print("Datos del documento: ${doc.data()}");
      return doc.data();
    }).toList();

    return devices;
  } catch (e) {
    print("🔥 Error fatal al obtener dispositivos: $e 🔥");
    return [];
  }
}