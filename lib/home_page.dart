
/*
class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _title() {
    return const Text("Home page");
  }

  Widget _userUid() {
    return Text(user?.email ?? 'User Email');
  }

  Widget _signOutButton() {
    return ElevatedButton(onPressed: signOut, child: const Text('Sign Out'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: _title()), // AppBar
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[_userUid(), _signOutButton()],
        ), // Column
      ), // Container
    ); // Scaffold
  }



}*/

import 'services/auth.dart';
import 'package:flutter/material.dart';
import 'CreateQuizPage.dart'; // Add this at the top of your file
import 'widgets/custom_appbar.dart'; // Import the new appbar

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String quizName = "My Quiz";
  final TextEditingController _searchController = TextEditingController();
  List<String> quizzes = ["Math Quiz"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "HomePage",
        // Optional: You can pass a custom sign out function
        // onSignOut: () => yourCustomSignOutLogic(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

Row(
  children: [
    // Small New Quiz Button on the Left
    SizedBox(
      height: 40,
      child: ElevatedButton(
         onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateQuizPage()),
          );
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 12),
        ),
        child: Text(
          "New Quiz",
          style: TextStyle(fontSize: 14),
        ),
      ),
    ),
    
    // Flexible space between button and search
    Expanded(child: SizedBox.shrink()),
    
    // Small Search Field on the Right
    SizedBox(
      width: 200, // Fixed width for search field
      height: 40,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search",
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.all(10),
          prefixIcon: Icon(Icons.search, size: 20),
        ),
      ),
    ),
  ],
),
            SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: quizzes.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Center(
                      child: Text(
                        quizzes[index],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
