import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gucy/models/user_data.dart';
import 'StaffProfilePage.dart';
import '../models/staff_data.dart';

class UserPermission extends StatefulWidget {
  const UserPermission({Key? key}) : super(key: key);

  @override
  _UserPermissionState createState() => _UserPermissionState();
}

class _UserPermissionState extends State<UserPermission> {
  List<UserData> UserList = [];
  List<UserData> filteredList = [];
  bool loading = true;
  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    List<UserData> tempUser = await getUser();
    setState(() {
      UserList = tempUser;
      filteredList = UserList;
      onSearch("");
      loading = false;
    });
  }

  Future<List<UserData>> getUser() async {
    try {
      print("Fetching from DB 1");
      CollectionReference userCollection =
          FirebaseFirestore.instance.collection('users');
      QuerySnapshot userSnapshot = await userCollection.get();
      print("Fetching from DB 2");
      List<UserData> allUser = [];
      if (userSnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot document in userSnapshot.docs) {
          print(document.data());
          Map<String, dynamic> userData =
              document.data() as Map<String, dynamic>;
          UserData user = UserData(
              uid: document.id,
              picture: userData['picture'],
              score: userData['score'],
              name: userData['name'],
              eventPermission: userData['eventPermission']);
          print(user.name);
          allUser.add(user);
        }
      }
      print("ALL User size: " + allUser.length.toString());
      return allUser;
    } catch (e) {
      // Handle any potential errors during data fetching
      print('Error fetching User: $e');
      throw e; // Re-throw the error to propagate it to the calling code
    }
  }

  onSearch(String search) {
    setState(() {
      filteredList = UserList.where((user) {
        return user.name.toLowerCase().contains(search.toLowerCase()) &&
            user.eventPermission.toLowerCase().contains("requested");
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
              hintText: "Search User",
            ),
          ),
        ),
        Expanded(
          child: Container(
            //color: Colors.grey.shade900,
            child: filteredList.isNotEmpty
                ? ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      return UserComponent(user: filteredList[index]);
                    },
                  )
                : Center(
                    child: Text(
                      "No Users found",
                      //style: TextStyle(color: Colors.white),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget UserComponent({required UserData user}) {
    return Container(
        //margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        //padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          //border: Border.all(color: Theme.of(context).colorScheme.primary),
        ),
        child: Column(children: [
          Material(
            //color: Colors.transparent, // Required for tap effect
            child: Container(
              child: Row(
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
                          child: Image.network(user.picture),
                        ),
                      ),
                      SizedBox(width: 10),
                      //rest
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: TextStyle(
                                //color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                                fontSize: 20),
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
                            onPressed: () {
                              permission(user, true);
                            },
                            icon: Icon(Icons.check),
                            color: Color.fromARGB(255, 22, 104, 29)),
                        SizedBox(width: 5),
                        IconButton(
                            onPressed: () {
                              permission(user, false);
                            },
                            icon: Icon(Icons.clear),
                            color: const Color.fromARGB(255, 116, 30, 24)),
                        SizedBox(width: 20)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider()
        ]));
  }

  void permission(UserData user, bool accept) {
    setState(() {
      filteredList.remove(user);
    });
    // Implement the deletion from the database
    updateData(user.uid, accept);
  }

  Future<void> updateData(String? x, bool accept) async {
    // Call the user's CollectionReference to add a new user
    if (accept)
      FirebaseFirestore.instance
          .collection('users')
          .doc(x)
          .update({'eventPermission': "accepted"})
          .then((value) => print("User updated"))
          .catchError((error) => print("Failed to update user: $error"));
    else
      FirebaseFirestore.instance
          .collection('users')
          .doc(x)
          .update({'eventPermission': "rejected"})
          .then((value) => print("User updated"))
          .catchError((error) => print("Failed to update user: $error"));
  }
}
