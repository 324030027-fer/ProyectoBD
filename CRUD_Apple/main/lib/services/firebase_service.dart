import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener todos los dispositivos
Future<List<Map<String, dynamic>>> getDevices() async {
  final querySnapshot = await FirebaseFirestore.instance.collection('devices').get();
  return querySnapshot.docs.map((doc) {
    final data = doc.data();
    data['id'] = doc.id; // Añadir el ID del documento
    return data;
  }).toList();
}
  // Añadir un nuevo dispositivo
  Future<void> addDevice(Map<String, dynamic> device) async {
    try {
      await _firestore.collection('devices').add(device);
    } catch (e) {
      print("Error al añadir dispositivo: $e");
      rethrow;
    }
  }

  // Actualizar un dispositivo
  Future<void> updateDevice(String id, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('devices').doc(id).update(updates);
    } catch (e) {
      print("Error al actualizar dispositivo: $e");
      rethrow;
    }
  }

  // Eliminar un dispositivo
  Future<void> deleteDevice(String id) async {
    try {
      await _firestore.collection('devices').doc(id).delete();
    } catch (e) {
      print("Error al eliminar dispositivo: $e");
      rethrow;
    }
  }
}