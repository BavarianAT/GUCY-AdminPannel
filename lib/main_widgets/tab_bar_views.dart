import 'package:flutter/material.dart';
import 'package:gucy/pages/UploadContactPage.dart';
import 'package:gucy/pages/UploadOutletPage.dart';
import 'package:gucy/pages/Uploadstaff.dart';

List<List<Widget>> tabBarViews = [
  [
    UploadStaff(),
  ],
  [
    UploadOutletPage(),
  ],
  [
    UploadContactPage(),
  ]
];
