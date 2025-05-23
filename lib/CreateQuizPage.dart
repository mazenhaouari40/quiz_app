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
  TextEditingController _controller = TextEditingController(
    text: "My first quiz",
  );

  List<String> questions = ["What does HIPAA protect?"];
  List<List<String>> options = [
    ["Doctor credentials", "Patient data", "Hospital policies"],
  ];
  List<Set<int>> correctAnswers = [
    {1},
  ];

  List<int> tempsQuestion = [5000];
  int selectedQuestion = 0;

  void addNewQuestion() {
    setState(() {
      questions.add("New Question");
      options.add(["Option 1", "Option 2", "Option 3"]);
      correctAnswers.add({});
      tempsQuestion.add(5000);
    });
  }

  void submitQuiz() {
    try {
      final user = Auth().currentUser?.uid;
      String quizName = _controller.text;

      Map<String, dynamic> quizData = {
        'quizName': quizName,
        'user': user,
        'questions': [],
      };

      for (int i = 0; i < questions.length; i++) {
        quizData['questions'].add({
          'question': questions[i],
          'options': options[i],
          'correctAnswers': correctAnswers[i].toList(),
          'tempsquestion': tempsQuestion[i],
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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: CustomAppBar(
        title: "Create new quiz",
        backgroundColor: Colors.white,
        elevation: 2,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(
              16.0,
            ), // Increased padding for better spacing
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Quiz Name TextField
                    Container(
                      width:
                          constraints.maxWidth *
                          0.2, // Takes 60% of available width
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: "Quiz Name",
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.blue,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.blueAccent,
                              width: 1.5,
                            ),
                          ),
                        ),
                        style: TextStyle(
                          fontSize:
                              14, // Slightly larger for better readability
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // Submit Button
                    Container(
                      width:
                          constraints.maxWidth *
                          0.1, // Takes 30% of available width
                      child: ElevatedButton(
                        onPressed: submitQuiz,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // Primary color
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          "Submit Quiz",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          Expanded(
            child: Row(
              children: [
                Container(
                  width: 250,
                  margin: EdgeInsets.all(
                    12,
                  ), // Added margin around the entire container
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Added border radius to container
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 18,
                        ), // Added horizontal margin to button
                        child: ElevatedButton(
                          onPressed: addNewQuestion,
                          child: Text("+ New Slide"),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(
                              double.infinity,
                              48,
                            ), // Full width button
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(
                            vertical: 8,
                          ), // Added vertical padding to list
                          itemCount: questions.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 18,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    selectedQuestion == index
                                        ? Colors.black
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.black),
                              ),

                              child: Stack(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    width: double.infinity,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedQuestion = index;
                                        });
                                      },
                                      child: Text(
                                        questions[index],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color:
                                              selectedQuestion == index
                                                  ? Colors.white
                                                  : Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        if (questions.length != 1) {
                                          setState(() {
                                            questions.removeAt(index);
                                            options.removeAt(index);
                                            correctAnswers.removeAt(index);
                                            tempsQuestion.removeAt(index);

                                            if (selectedQuestion >=
                                                questions.length) {
                                              selectedQuestion =
                                                  questions.length - 1;
                                            }
                                          });
                                        }
                                      },
                                      child: Icon(
                                        Icons.close,
                                        size: 18, // small icon
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
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
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Row(
                              children: [
                                // Question Container - takes most of the space
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                      right: 16.0,
                                    ), // Space between containers
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: TextField(
                                      textDirection:
                                          TextDirection
                                              .ltr, // Explicitly set LTR

                                      controller: TextEditingController(
                                          text: questions[selectedQuestion],
                                        )
                                        ..selection = TextSelection.collapsed(
                                          offset:
                                              questions[selectedQuestion]
                                                  .length,
                                        ),
                                      onChanged: (value) {
                                        setState(() {
                                          questions[selectedQuestion] = value;
                                        });
                                      },
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Enter question",
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),

                                Container(
                                  width: 120, // Fixed width for points selector
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),

                                  child: DropdownButton<int>(
                                    value:
                                        tempsQuestion[selectedQuestion], // Nouvelle variable "tempsQuestion"

                                    onChanged: (int? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          tempsQuestion[selectedQuestion] =
                                              newValue;
                                        });
                                      }
                                    },
                                    items:
                                        [5000, 10000, 15000, 20000].map((
                                          int value,
                                        ) {
                                          // Valeurs en ms
                                          return DropdownMenuItem<int>(
                                            value: value,
                                            child: Text(
                                              "${value ~/ 1000} sec",
                                            ), // Convertir en secondes pour affichage
                                          );
                                        }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                          Column(
                            children: List.generate(
                              options[selectedQuestion].length,
                              (index) {
                                return Container(
                                  margin: EdgeInsets.only(
                                    top: 12.0,
                                  ), // Add top margin to each row
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: correctAnswers[selectedQuestion]
                                            .contains(index),
                                        onChanged: (bool? value) {
                                          setState(() {
                                            if (value == true) {
                                              correctAnswers[selectedQuestion]
                                                  .add(index);
                                            } else {
                                              correctAnswers[selectedQuestion]
                                                  .remove(index);
                                            }
                                          });
                                        },
                                      ),
                                      Expanded(
                                        child: TextField(
                                          controller: TextEditingController(
                                              text:
                                                  options[selectedQuestion][index],
                                            )
                                            ..selection = TextSelection.collapsed(
                                              offset:
                                                  options[selectedQuestion][index]
                                                      .length,
                                            ),
                                          onChanged: (value) {
                                            setState(() {
                                              options[selectedQuestion][index] =
                                                  value;
                                            });
                                          },
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.close,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => removeOption(index),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          if (options[selectedQuestion].length < 5)
                            Container(
                              margin: EdgeInsets.only(
                                top: 16.0,
                              ), // Add top margin
                              child: Center(
                                child: ElevatedButton(
                                  onPressed: addNewOption,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.green, // Green background
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius
                                              .zero, // No border radius (square)
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Text(
                                    "+ New Option",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
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
