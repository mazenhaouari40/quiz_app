import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'waiting_room_page.dart';
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
      appBar: AppBar(title: const Text('Enter Your Name')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
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
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitName,
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Continue to Quiz'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitName() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      
      try {

 final participantRef = _firestore
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

      await participantRef.update({
        'userid': participantRef.id, 
      });


        // Navigate to WaitingPage with the entered name
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>  WaitingPage(
            activequizId: widget.activatequizId,
            userId: participantRef.id,
            invitation_code: widget.quizCode,
          ),
          ),
        );
      } catch (e) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}