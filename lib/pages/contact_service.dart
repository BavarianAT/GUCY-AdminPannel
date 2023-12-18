import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/contacts_data.dart';
// import 'package:gucians/database/database_references.dart';

Future<List<Contacts>> getemergencyNums() async {
  CollectionReference emegencyNumbersCollection =
      FirebaseFirestore.instance.collection('contacts');
  QuerySnapshot emergencyNums = await emegencyNumbersCollection.get();
  List<Contacts> allemergencyNums = [];
  if (emergencyNums.docs.isNotEmpty) {
    for (QueryDocumentSnapshot document in emergencyNums.docs) {
      Map<String, dynamic> emergencyNum =document.data() as Map<String, dynamic>;
      Contacts contact = Contacts(
            id: document.id,
            name: emergencyNum['name'],
            phoneNumber: emergencyNum['phoneNumber']
          );
      allemergencyNums.add(contact);
    }
  }
  return allemergencyNums;
}