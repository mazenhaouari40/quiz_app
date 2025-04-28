import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'quiz_flow.dart';

class SetNameScreen extends StatefulWidget {
  final String quizCode;
  final String activatequizId;
  //  final String activeId;

  const SetNameScreen({
    Key? key,
    required this.quizCode,
    required this.activatequizId,
    //  required this.activeId,
  }) : super(key: key);

  @override
  _SetNameScreenState createState() => _SetNameScreenState();
}

class _SetNameScreenState extends State<SetNameScreen> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Enter Your Name'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Your Name',
                        border: OutlineInputBorder(),
                        hintText: 'Enter your display name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        if (value.length > 20) {
                          return 'Name must be less than 20 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 200, // Button is smaller than the input
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitName,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          child:
                              _isSubmitting
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text(
                                    'Continue to Quiz',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitName() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      try {
        final participantRef =
            _firestore
                .collection('actived_Quizzes')
                .doc(widget.activatequizId)
                .collection('participants')
                .doc();
        final guestname = _nameController.text;

        await participantRef.set({
          'userid': null,
          'displayName': guestname,
          'score': 0,
        });

        await participantRef.update({'userid': participantRef.id});

        final querySnapshot =
            await _firestore
                .collection('actived_Quizzes')
                .where('id', isEqualTo: widget.activatequizId)
                .limit(1)
                .get();
        final quizid = querySnapshot.docs.first['quizzId'];

        // Navigate to WaitingPage with the entered name
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => WaitingPage(
                  activequizId: widget.activatequizId,
                  userId: participantRef.id,
                  invitation_code: widget.quizCode,
                  quizid: quizid,
                ),
          ),
        );
      } catch (e) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }
}
