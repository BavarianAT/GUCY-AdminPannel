import 'package:flutter/material.dart';
import 'package:gucy/models/contacts_data.dart';
import 'package:gucy/models/outlets_data.dart';
// import 'package:gucy/pages/OutletProfilePage.dart';
// import 'package:gucy/pages/outlet_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/outlets_data.dart';

class DeleteOutlet extends StatefulWidget {
  const DeleteOutlet({Key? key}) : super(key: key);

  @override
  _DeleteOutletState createState() => _DeleteOutletState();
}

class _DeleteOutletState extends State<DeleteOutlet> {
  List<Outlet> outletsList = [];

  List<Outlet> filteredList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    print("a");
    loadUsers();
  }

  Future<void> loadUsers() async {
    List<Outlet> tempUsers = await getOutlets();
    print("b");
    setState(() {
      outletsList = tempUsers;
      filteredList = outletsList;
      loading = false;
    });
  }

  Future<List<Outlet>> getOutlets() async {
    print("c");
    try {
      CollectionReference outletsCollection =
          FirebaseFirestore.instance.collection('outlets');
      QuerySnapshot outletSnapshot = await outletsCollection.get();

      List<Outlet> allOutlets = [];
      if (outletSnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot document in outletSnapshot.docs) {
          print("abdosaid00");
          print(document.data());
          Map<String, dynamic> outletData =
              document.data() as Map<String, dynamic>;
          List<dynamic> reviewsData = outletData['reviews'] ?? [];
          List<Review> reviews = reviewsData.map((review) {
            return Review.fromJson(review);
          }).toList();

          Outlet outlet = Outlet(
            id: document.id,
            image: outletData['image'],
            desc: outletData['desc'],
            name: outletData['name'],
            reviews: reviews,
            location: outletData['location'],
          );
          print(outlet.name);
          allOutlets.add(outlet);
        }
      }

      return allOutlets;
    } catch (e) {
      // Handle any potential errors during data fetching
      print('Error fetching outlets: $e');
      throw e; // Re-throw the error to propagate it to the calling code
    }
  }

  onSearch(String search) {
    setState(() {
      filteredList = outletsList.where((outlet) {
        return outlet.name.toLowerCase().contains(search.toLowerCase()) ||
            outlet.desc.toLowerCase().contains(search.toLowerCase()) ||
            outlet.location.toLowerCase().contains(search.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          //color: Colors.grey.shade900,
          child: TextField(
            onChanged: (value) => onSearch(value),
            //style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              //fillColor: Colors.grey[850],
              contentPadding: EdgeInsets.all(0),
              prefixIcon: Icon(
                Icons.search,
                // color: Colors.grey.shade500
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide.none,
              ),
              hintStyle: TextStyle(
                fontSize: 14,
                //color: Colors.grey.shade500,
              ),
              hintText: "Search Outlets",
            ),
          ),
        ),
        Expanded(
          child: loading
              ? Center(
                  child: CircularProgressIndicator(), // Show loading indicator
                )
              : Container(
                  //color: Colors.grey.shade900,
                  child: filteredList.isNotEmpty
                      ? ListView.builder(
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            return outletComponent(outlet: filteredList[index]);
                          },
                        )
                      : Center(
                          child: Text(
                            "No outlets found",
                            //style: TextStyle(color: Colors.white),
                          ),
                        ),
                ),
        ),
      ],
    );
  }

  Widget outletComponent({required Outlet outlet}) {
    return Container(
        //margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        //padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          //border: Border.all(color: Theme.of(context).colorScheme.primary),
        ),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(width: 20),
                  //image
                  Container(
                    width: 60,
                    height: 60,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.network(outlet.image),
                    ),
                  ),
                  SizedBox(width: 10),
                  //rest
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        outlet.name,
                        style: TextStyle(
                            //color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                            fontSize: 20),
                      ),
                      SizedBox(height: 2),
                      _buildRatingStars(outlet.rating),
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
                        color: Colors.red,
                      ),
                      onPressed: () {
                        _showDeleteConfirmationDialog(outlet);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ]));
  }

  Widget _buildRatingStars(double rating) {
    int fullStars = rating.floor(); // Extract the whole number part
    double fraction = rating - fullStars; // Calculate the fractional part

    List<Widget> stars = List.generate(
      fullStars,
      (index) => Icon(
        Icons.star,
        color: Theme.of(context).colorScheme.primary,
        size: 25,
      ),
    );
    int n = 5 - fullStars;
    if (fraction > 0) {
      n = n - 1;
      stars.add(Icon(
        Icons.star_half,
        color: Theme.of(context).colorScheme.primary,
        size: 25,
      ));
    }
    for (int i = 0; i < n; i++) {
      stars.add(Icon(
        Icons.star_outline,
        color: Theme.of(context).colorScheme.primary,
        size: 25,
      ));
    }

    return Row(children: stars);
  }

  Future<void> _showDeleteConfirmationDialog(Outlet outlet) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete ${outlet.name}?'),
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
                _deleteContact(outlet);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteContact(Outlet outlet) {
    setState(() {
      outletsList.remove(outlet);
      deleteData(outlet.id);
      filteredList = outletsList;
    });
    // Implement the deletion from the database
  }

  Future<void> deleteData(String x) async {
    // Call the user's CollectionReference to add a new user
    FirebaseFirestore.instance
        .collection('outlets')
        .doc(x)
        .delete()
        .then((value) => print("User deleted"))
        .catchError((error) => print("Failed to delete user: $error"));
  }
}
