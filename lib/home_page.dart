
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/auth.dart';
import 'CreateQuizPage.dart';
import 'UpdateQuiz.dart'; // Add this import
import 'widgets/custom_appbar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> quizzes = [];

  @override
  void initState() {
    super.initState();
    _fetchQuizzes();
  }

 Future<void> _fetchQuizzes() async {
  final currentUser = Auth().currentUser;
  if (currentUser == null) return; // Exit if no user is logged in

  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('quizzes')
        .where('createdBy', isEqualTo: currentUser.uid) // Filter by user ID
        .get();

    setState(() {
      quizzes = snapshot.docs.map((doc) => {
        'id': doc.id,
        'name': doc['quizName'] as String,
      }).toList();
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error loading quizzes: ${e.toString()}')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "HomePage",
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => QuizPage()),
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
                Expanded(child: SizedBox.shrink()),
                SizedBox(
                  width: 200,
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
                  childAspectRatio: 1.5, // Adjusted for buttons
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: quizzes.length,
                itemBuilder: (context, index) {
                  final quiz = quizzes[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            quiz['name']!,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Play Button (Red)
                              ElevatedButton(
                                onPressed: () {
                                  // Add play functionality
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                ),
                                child: Text(
                                  "Play",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              // Update Button
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UpdateQuiz(
                                        quizId: quiz['id']!,
                                      ),
                                    ),
                                  );
                                },
                                child: Text("Update"),
                              ),
                            ],
                          ),
                        ],
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

       


       
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