import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/staff_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:gucy/providers/user_provider.dart';

class StaffProfilePage extends StatefulWidget {
  final Staff staff;

  const StaffProfilePage({Key? key, required this.staff}) : super(key: key);

  @override
  _StaffProfilePageState createState() => _StaffProfilePageState();
}

class _StaffProfilePageState extends State<StaffProfilePage> {
  TextEditingController _reviewController = TextEditingController();
  double _userRating = 0.0;
  List<Review> _reviews = [];
  bool _isAddingReview = false;
  @override
  void initState() {
    super.initState();
    _reviews = widget.staff.reviews;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.staff.name),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    //image
                    Container(
                      width: 60,
                      height: 60,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(widget.staff.image),
                      ),
                    ),
                    SizedBox(width: 10),
                    //rest
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.staff.title,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          widget.staff.name,
                          style: TextStyle(
                              //color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                              fontSize: 20),
                        ),
                        SizedBox(height: 2),
                        _buildRatingStars(widget.staff.rating),
                      ],
                    ),
                  ],
                ),
                // Icon(
                //   Icons.more_vert,
                //   //color: Theme.of(context).colorScheme.primary,
                //   size: 25,
                // ),
              ],
            ),

            // Display staff reviews

            if (_reviews.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(
                    'Reviews',
                    style: TextStyle(fontSize: 20),
                  ),
                  Divider(),
                  //SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildReviewsList(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildReviewsList() {
    List<Widget> widgets = [];
    for (int i = 0; i < _reviews.length; i++) {
      widgets.add(Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(_reviews[i].image),
                ),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  SizedBox(width: 10),
                  Container(
                    width: 150,
                    child: Text(
                      _reviews[i].userName.length > 12
                          ? _reviews[i].userName.substring(0, 10) + ".."
                          : _reviews[i].userName,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  //SizedBox(width: 110),
                  Container(
                    child: _buildRatingStars(_reviews[i].rating),
                  ),
                  Container(
                      width: 20,
                      child: IconButton(
                          icon: Icon(Icons.clear),
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          onPressed: () {
                            setState(() {
                              _showDeleteConfirmationDialog(
                                  context, _reviews[i].userId);
                            });
                          })),
                ]),
                Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: SizedBox(
                        width: 300,
                        child: Text(
                          _reviews[i].body,
                        ))),
              ])
            ],
          )));
    }
    return widgets;
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
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

  void _showDeleteConfirmationDialog(BuildContext context, id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Confirmation'),
          content: Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Perform delete action here
                // Add your delete logic here
                //widget.staff
                setState(() {
                  deleteReview(id);
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteReview(id) async {
    try {
      List newList = [];
      int remove = -1;
      for (int i = 0; i < _reviews.length; i++) {
        if (_reviews[i].userId == id) {
          remove = i;
        } else {
          newList.add(_reviews[i].toJson());
        }
      }
      if(remove>-1)
        _reviews.removeAt(remove);
      print(newList);
      await FirebaseFirestore.instance
          .collection('staff')
          .doc(widget.staff.id)
          .update({'reviews': newList});
      print('Review deleted successfully!');
    } catch (e) {
      print('Error deleting review: $e');
    }
  }
}
