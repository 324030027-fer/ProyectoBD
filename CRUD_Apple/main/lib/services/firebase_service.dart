import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List> getDevice() async {
  List devices = [];
  CollectionReference collectionReferenceDevice = db.collection('HHH1');
  QuerySnapshot queryDevice = await collectionReferenceDevice.get();

  queryDevice.docs.forEach((documento) {
    devices.add(documento.data());
  });

  return devices;
}
