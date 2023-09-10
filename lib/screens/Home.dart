import 'package:flutter/material.dart';
import 'package:heavenhunt/screens/components/search_bar.dart';
import 'package:heavenhunt/screens/components/search_page.dart';
import 'package:heavenhunt/utils/contants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentpageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: const Text("Easy Room"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // showSearch(
              //   context: context,
              //   delegate: CustomSearchDelegate(""),
              // );
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FilterScreen(),
                  ));
            },
          ),
          IconButton(
              onPressed: () async {
                Navigator.pushNamed(context, '/edit-profile');
              
              },
              icon: Icon(Icons.person_2)),
        ],
      ),
      body: Constants.HomeScreenPages.elementAt(currentpageIndex),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (value) {
          setState(() {
            currentpageIndex = value;
          });
        },
        selectedIndex: currentpageIndex,
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.explore),
            icon: Icon(Icons.explore_outlined),
            label: 'Explore',
          ),
          // NavigationDestination(
          //   selectedIcon: Icon(Icons.store_mall_directory),
          //   icon: Icon(Icons.store_mall_directory_outlined),
          //   label: 'Store',
          // ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            label: 'Chats',
          ),
        ],
      ),
    );
  }
}
