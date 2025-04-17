import 'package:flutter/material.dart';
import '/services/auth.dart';
import '/services/quiz.dart';
import '/home_page.dart';

class UpdateQuiz extends StatefulWidget {
  final String quizId;
  const UpdateQuiz({Key? key, required this.quizId}) : super(key: key);

  @override
  _UpdateQuizState createState() => _UpdateQuizState();
}

class _UpdateQuizState extends State<UpdateQuiz> {
  late TextEditingController _controller;
  List<String> questions = [];
  List<List<String>> options = [];
  List<Set<int>> correctAnswers = [];
List<int> tempsQuestion = [5000]; // Stocke le temps par question en millisecondes (par défaut 5s)
  int selectedQuestion = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: "Loading...");
    _loadQuizData();
  }

  Future<void> _loadQuizData() async {
    try {
      final quizData = await QuizService().fetchQuizById(widget.quizId);

      setState(() {
        _controller = TextEditingController(
          text: quizData['quizName'] ?? "Untitled Quiz",
        );

        // Initialize questions and options from the loaded data
        questions = List<String>.from(
          quizData['questions']?.map((q) => q['question'] as String) ??
              ["New Question"],
        );

        options = List<List<String>>.from(
          quizData['questions']?.map(
                (q) =>
                    List<String>.from(q['options'] ?? ["Option 1", "Option 2"]),
              ) ??
              [
                ["Option 1", "Option 2"],
              ],
        );

        correctAnswers = List<Set<int>>.from(
          quizData['questions']?.map(
                (q) => Set<int>.from(
                  (q['correctAnswers'] as List<dynamic>?)?.map(
                        (e) => e as int,
                      ) ??
                      [0],
                ),
              ) ??
              [{}],
        );

        tempsQuestion = List<int>.from(
          quizData['questions']?.map((q) => q['tempsquestion'] as int? ?? 1) ?? [1],
        );

        isLoading = false;
      });
    } catch (e) {
      // Fallback to default values if loading fails
      setState(() {
        _controller = TextEditingController(text: "My first quiz");
        questions = ["What does HIPAA protect?"];
        options = [
          ["Doctor credentials", "Patient data", "Hospital policies"],
        ];
        correctAnswers = [
          {1},
        ];
        tempsQuestion = [5000];
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading quiz: ${e.toString()}')),
      );
    }
  }

  void addNewQuestion() {
    setState(() {
      questions.add("New Question");
      options.add(["Option 1", "Option 2", "Option 3"]);
      correctAnswers.add({});
      tempsQuestion.add(5000);
      selectedQuestion = questions.length - 1;
    });
  }

  void updateQuiz() {
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

      QuizService().updateQuiz(quizData, widget.quizId);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error updating quiz: $e")));
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
        // Minimum 2 options
        // Remove any correct answers pointing to this option
        correctAnswers[selectedQuestion].remove(index);
        // Adjust other correct answers if they were after this index
        correctAnswers[selectedQuestion] =
            correctAnswers[selectedQuestion].map((ans) {
              return ans > index ? ans - 1 : ans;
            }).toSet();
        options[selectedQuestion].removeAt(index);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Update Quiz')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Update Quiz')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

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



 Container(
                      width:
                          constraints.maxWidth *
                          0.1, // Takes 30% of available width
                      child: ElevatedButton(
                        onPressed: updateQuiz,
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
                          "update Quiz",
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
                  margin: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 18),
                        child: ElevatedButton(
                          onPressed: addNewQuestion,
                          child: Text("+ New Slide"),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(vertical: 8),
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

/*
                              child: ListTile(
                                title: Text(
                                  questions[index].isNotEmpty
                                      ? questions[index]
                                      : "Untitled Question",
                                  style: TextStyle(
                                    color:
                                        selectedQuestion == index
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedQuestion = index;
                                  });
                                },
                              ),*/
child: Stack(
  children: [
    Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          overflow: TextOverflow.ellipsis, // Shows "..." if too long
          style: TextStyle(
            color: selectedQuestion == index ? Colors.white : Colors.black,
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
          if (questions.length !=1){
          setState(() {
            questions.removeAt(index);
            options.removeAt(index);
            correctAnswers.removeAt(index);
            tempsQuestion.removeAt(index);

            if (selectedQuestion >= questions.length) {
              selectedQuestion = questions.length - 1;
            }
          });}
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
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 16.0),
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
                                  width: 120,
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
                                    value: tempsQuestion[selectedQuestion],
                                    onChanged: (int? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          tempsQuestion[selectedQuestion] =
                                              newValue;
                                        });
                                      }
                                    },
                                    isExpanded: true,
                                    underline: Container(),
                                    items: [5000, 10000, 15000, 20000].map((int value) { // Valeurs en ms
                                      return DropdownMenuItem<int>(
                                        value: value,
                                        child: Text("${value ~/ 1000} sec"), // Convertir en secondes pour affichage
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
                                  margin: EdgeInsets.only(top: 12.0),
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
                              margin: EdgeInsets.only(top: 16.0),
                              child: Center(
                                child: ElevatedButton(
                                  onPressed: addNewOption,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Text(
                                    "New Option",
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
