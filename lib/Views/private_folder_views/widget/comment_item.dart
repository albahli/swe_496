import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class CommentItem extends StatelessWidget {
  final DateTime _dateTime;
  final String _commentText;

  CommentItem(this._commentText, this._dateTime);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            DateFormat.yMMMd().format(_dateTime),
            style: TextStyle(
              color: Colors.black45,
              fontWeight: FontWeight.w500,
              fontSize: 15.0,
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.007,
          ),
          Material(
            elevation: 5.0,
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            color: Theme.of(context).primaryColorDark,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 20.0,
              ),
              child: Text(
                _commentText,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 17.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
