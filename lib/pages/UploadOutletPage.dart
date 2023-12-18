import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gucy/models/outlets_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/outlets_data.dart';

class UploadOutletPage extends StatefulWidget {
  @override
  _UploadOutletPageState createState() => _UploadOutletPageState();
}

class _UploadOutletPageState extends State<UploadOutletPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Outlet Form'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(child:Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: imageController,
                decoration: InputDecoration(labelText: 'Image URL'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an image URL';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.0),
              TextFormField(
                controller: descController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.0),
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
                controller: locationController,
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  _submitOutlet();
                },
                child: Text('Submit'),
              ),
            ],
          ),)
        ),
      ),
    );
  }

  void _submitOutlet() async {
    if (_formKey.currentState!.validate()) {
      // Form is valid, proceed with data submission
      String image = imageController.text;
      String desc = descController.text;
      String name = nameController.text;
      String location = locationController.text;

      // Firebase initialization
      CollectionReference emegencyNumbersCollection =
      FirebaseFirestore.instance.collection('outlets');
      Outlet newOutlet = Outlet(
        id:"",
        image: image,
        desc: desc,
        name: name,
        reviews: [], 
        // Set reviews to an empty list
        location: location,
      );
    // Push the new contact to Firebase database with an auto-generated ID
    emegencyNumbersCollection.add(newOutlet.toJson()).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Outlet added successfully')),
        );
        // Clear the text fields after submission
        imageController.clear();
        descController.clear();
        nameController.clear();
        locationController.clear();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add outlet: $error')),
        );
      });
    }
  }
}
