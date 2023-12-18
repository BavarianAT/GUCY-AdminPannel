import 'package:flutter/material.dart';
import 'package:gucy/pages/DeletContact.dart';
import 'package:gucy/pages/DeleteOutlet.dart';
import 'package:gucy/pages/UploadContactPage.dart';
import 'package:gucy/pages/UploadOutletPage.dart';
import 'package:gucy/pages/Uploadstaff.dart';
import 'package:gucy/pages/DeleteStaff.dart';
import 'package:gucy/pages/UsersPermission.dart';
List<List<Widget>> tabBarViews = [
  [
    UploadStaff(),
    DelteStaff(),
    UserPermission()
  ],
  [
    UploadOutletPage(),
    DeleteOutlet()
  ],
  [
    UploadContactPage(),
    DeleteContact()
  ]
];
