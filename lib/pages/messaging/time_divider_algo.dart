import 'package:intl/intl.dart';

class TimeDividerAlgo {
  static String getTimeDivider(
      DateTime lastDateTime, DateTime currentDateTime) {
    String timeDivider;
    Duration timeDiffDuration =
        currentDateTime.toLocal().difference(lastDateTime.toLocal());
    int timeDiffDays = timeDiffDuration.inDays;
    int timeDiffHours = timeDiffDuration.inHours - (timeDiffDays * 24);
    // print("Time diff days: $timeDiffDays");
    // print("Time diff hours: $timeDiffHours");
    DateFormat format = DateFormat.yMd();
    DateTime lastMessageDate =
        format.parse(format.format(lastDateTime.toLocal()));
    DateTime currentMessageDate =
        format.parse(format.format(currentDateTime.toLocal()));
    Duration dateDiffDuration = currentMessageDate.difference(lastMessageDate);
    int dateDiffDays = dateDiffDuration.inDays;
    // print("lastMessageDate: $lastMessageDate");
    // print("currentMessageDate: $currentMessageDate");
    // print("dateDiffDays: $dateDiffDays");

    if (dateDiffDays >= 1 && dateDiffDays < 2) {
      // today

      timeDivider = "Today";
    } else if (dateDiffDays > 2) {
      DateFormat f = DateFormat.yMd();
      timeDivider = f.format(currentDateTime.toLocal());
    }

    if (timeDiffHours > 2) {
      DateFormat f = DateFormat.MMMd().add_jm();
      String formattedTime = f.format(currentDateTime.toLocal());
      if (currentDateTime
              .toLocal()
              .difference(DateTime.now().toLocal())
              .inDays ==
          0) timeDivider = "Today";
      timeDivider = (timeDivider != null)
          ? timeDivider + " $formattedTime"
          : formattedTime;
    }
    return timeDivider;
  }
}
