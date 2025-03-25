import 'package:flutter/material.dart';

class JoinQuizWidget extends StatelessWidget {
  const JoinQuizWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                labelText: "Enter a code to join a quiz live",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(minimumSize: Size(0, 60)),
            child: Text("Join"),
          ),
        ],
      ),
    );
  }
}
