import 'package:intl/intl.dart';

class ChatFuntions {
  final DateTime time;
  ChatFuntions({required this.time});

  String formattedTime() {
    final timeDiff = calculateDifference(time);
    String messageTime = '';
    if (timeDiff == 0) {
      messageTime = DateFormat.jm().format(time);
    } else if (timeDiff == -1) {
      messageTime = 'Yesterday';
    } else {
      messageTime = DateFormat.yMMMd().format(time);
    }
    return messageTime;
  }
}

//date difference calculation function
int calculateDifference(DateTime date) {
  DateTime now = DateTime.now();
  return DateTime(date.year, date.month, date.day)
      .difference(DateTime(now.year, now.month, now.day))
      .inDays;
}
