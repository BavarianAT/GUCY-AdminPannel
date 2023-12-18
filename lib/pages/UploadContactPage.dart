import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gucy/models/outlets_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/contacts_data.dart';

class UploadContactPage extends StatefulWidget {
  @override
  _UploadContactPageState createState() => _UploadContactPageState();
}

class _UploadContactPageState extends State<UploadContactPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool isEmergency = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Form'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(child:Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.0),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.0),
              Row(
                children: <Widget>[
                  Text('Is it an emergency?'),
                  Checkbox(
                    value: isEmergency,
                    onChanged: (value) {
                      setState(() {
                        isEmergency = value!;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  _submitContact(context);
                },
                child: Text('Submit'),
              ),
            ],
          ),)
        ),
      ),
    );
  }
  void _submitContact(BuildContext context) async {
    String name = nameController.text;
    String phoneNumber = phoneController.text;

    // Firebase initialization
    CollectionReference emegencyNumbersCollection =
      FirebaseFirestore.instance.collection('contacts');
      Contacts newcontact = Contacts(
      name : name ,
      phoneNumber: phoneNumber,
      isEmergency: isEmergency
    );
    // Push the new contact to Firebase database with an auto-generated ID
    emegencyNumbersCollection.add(newcontact.toJson()).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contact added successfully')),
      );
      // Clear the text fields after submission
      nameController.clear();
      phoneController.clear();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add contact: $error')),
      );
    });
  }
}
