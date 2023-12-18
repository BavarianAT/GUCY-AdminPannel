import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final int currentPageIndex;
  final Function(int)? onDestinationSelected;
  const NavBar(
      {super.key,
      required this.currentPageIndex,
      required this.onDestinationSelected});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      onDestinationSelected: onDestinationSelected,
      selectedIndex: currentPageIndex,
      destinations: const <Widget>[
        NavigationDestination(
          selectedIcon: Icon(Icons.people),
          icon: Icon(Icons.people),
          label: 'Staff',
        ),
        NavigationDestination(
          icon: Badge(child: Icon(Icons.home)),
          label: 'Outlets',
        ),
        NavigationDestination(
          icon: Badge(
            label: Text('2'),
            child: Icon(Icons.phone),
          ),
          label: 'Contacts',
        ),
      ],
    );
  }
}
