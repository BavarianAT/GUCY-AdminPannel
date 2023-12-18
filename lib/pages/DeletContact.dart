import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:gucy/models/contacts_data.dart';
import 'package:gucy/pages/contact_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteContact extends StatefulWidget {
  const DeleteContact({Key? key}) : super(key: key);

  @override
  _DeleteContactState createState() => _DeleteContactState();
}

class _DeleteContactState extends State<DeleteContact> {
  List<Contacts> contactsList = [];
  bool loading = true;
  List<Contacts> filteredList = [];

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    List<Contacts> tempUsers = await getUsers();
    setState(() {
      contactsList = tempUsers;
      filteredList = contactsList;
      loading = false;
    });
  }

  Future<List<Contacts>> getUsers() async {
    return await getemergencyNums();
  }

  onSearch(String search) {
    setState(() {
      filteredList = contactsList.where((contact) {
        return contact.name.toLowerCase().contains(search.toLowerCase()) ||
            contact.phoneNumber.contains(search);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Contact'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: TextField(
              onChanged: (value) => onSearch(value),
              decoration: InputDecoration(
                filled: true,
                contentPadding: EdgeInsets.all(0),
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
                hintText: "Search Contacts",
              ),
            ),
          ),
          Expanded(
            child: loading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Container(
                    child: filteredList.isNotEmpty
                        ? ListView.builder(
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              return contactComponent(
                                  contact: filteredList[index]);
                            },
                          )
                        : Center(
                            child: Text("No contacts found"),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget contactComponent({required Contacts contact}) {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 20),
                      ),
                      SizedBox(height: 5),
                      Text('Emergency contact',
                        style: TextStyle(
                          color: Color.fromARGB(255, 145, 39, 31) ,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: const Color.fromARGB(255, 145, 34, 26),
                      ),
                      onPressed: () {
                        _showDeleteConfirmationDialog(contact);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(Contacts contact) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete ${contact.name}?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                _deleteContact(contact);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteContact(Contacts contact) {
    setState(() {
      contactsList.remove(contact);
      filteredList = contactsList;
    });
    // Implement the deletion from the database
    deleteData(contact.id);
  }

  Future<void> deleteData(String? x) async {
    // Call the user's CollectionReference to add a new user
    FirebaseFirestore.instance
        .collection('contacts')
        .doc(x)
        .delete()
        .then((value) => print("User deleted"))
        .catchError((error) => print("Failed to delete user: $error"));
  }
}
