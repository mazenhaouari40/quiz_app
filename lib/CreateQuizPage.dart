import 'package:flutter/material.dart';
import 'package:quiz_app/home_page.dart';
import 'widgets/custom_appbar.dart'; // Import the new appbar
import 'services/auth.dart';
import 'services/quiz.dart';
import 'package:fluttertoast/fluttertoast.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  TextEditingController _controller = TextEditingController(text: "My first quiz");

  List<String> questions = ["What does HIPAA protect?"];
  List<List<String>> options = [
    ["Doctor credentials", "Patient data", "Hospital policies"]
  ];
  List<Set<int>> correctAnswers = [{1}]; // Index of correct options
  List<int> questionMarks = [1]; // Stores marks for each question
  int selectedQuestion = 0;

  void addNewQuestion() {
    setState(() {
      questions.add("New Question");
      options.add(["Option 1", "Option 2", "Option 3"]);
      correctAnswers.add({});
      questionMarks.add(1);
    });
  }

  void submitQuiz() {
    try {
      final user = Auth().currentUser?.uid;
      String quizName = _controller.text;  // Get the quiz name from the TextField

      Map<String, dynamic> quizData = {
        'quizName': quizName, // Use the quizName from the controller
        'user': user, // Replace with actual user ID
        'questions': []
      };

      for (int i = 0; i < questions.length; i++) {
        quizData['questions'].add({
          'question': questions[i],
          'options': options[i],
          'correctAnswers': correctAnswers[i].toList(),
          'marks': questionMarks[i]
        });
      }

      QuizService().saveNewQuiz(quizData); 
      
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );    
    } catch (e) {
      Fluttertoast.showToast(msg: "Error submitting quiz: $e");
    }
  }

  void addNewOption() {
    setState(() {
      if (options[selectedQuestion].length < 5) {
        options[selectedQuestion].add("New Option");
      }
    });
  }

  void removeOption(int index) {
    setState(() {
      if (options[selectedQuestion].length > 3) {
        options[selectedQuestion].removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Create quiz app",
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                  // Quiz Name Text on the Left
                Expanded(
child: TextField(
  controller: _controller,
  decoration: InputDecoration(
    hintText: "Quiz Name",
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.blue, width: 2),
    ),
  ),
  style: TextStyle(fontSize: 12), // Smaller font for the quiz name
),
                ),
                SizedBox(width: 10), // Adds space between TextField and ElevatedButton
                // Submit Button on the Right
                ElevatedButton(
                  onPressed: submitQuiz,
                  child: Text("Submit Quiz"),
                ),



              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 250,
                  color: Colors.white,
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: addNewQuestion,
                        child: Text("+ New Slide"),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: questions.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                              decoration: BoxDecoration(
                                color: selectedQuestion == index ? Colors.black : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.black),
                              ),
                              child: ListTile(
                                title: Text(
                                  questions[index],
                                  style: TextStyle(
                                    color: selectedQuestion == index ? Colors.white : Colors.black,
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedQuestion = index;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: TextEditingController(text: questions[selectedQuestion]),
                                  onChanged: (value) {
                                    setState(() {
                                      questions[selectedQuestion] = value;
                                    });
                                  },
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(border: UnderlineInputBorder()),
                                ),
                              ),
                              DropdownButton<int>(
                                value: questionMarks[selectedQuestion],
                                onChanged: (int? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      questionMarks[selectedQuestion] = newValue;
                                    });
                                  }
                                },
                                items: [1, 2, 3, 4].map((int value) {
                                  return DropdownMenuItem<int>(
                                    value: value,
                                    child: Text("${value} points"),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Column(
                            children: List.generate(options[selectedQuestion].length, (index) {
                              return Row(
                                children: [
                                  Checkbox(
                                    value: correctAnswers[selectedQuestion].contains(index),
                                    onChanged: (bool? value) {
                                      setState(() {
                                        if (value == true) {
                                          correctAnswers[selectedQuestion].add(index);
                                        } else {
                                          correctAnswers[selectedQuestion].remove(index);
                                        }
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: TextEditingController(text: options[selectedQuestion][index]),
                                      onChanged: (value) {
                                        setState(() {
                                          options[selectedQuestion][index] = value;
                                        });
                                      },
                                      decoration: InputDecoration(border: OutlineInputBorder()),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close, color: Colors.red),
                                    onPressed: () => removeOption(index),
                                  ),
                                ],
                              );
                            }),
                          ),
                          if (options[selectedQuestion].length < 5)
                            Center(
                              child: ElevatedButton(
                                onPressed: addNewOption,
                                child: Text("New Option"),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
