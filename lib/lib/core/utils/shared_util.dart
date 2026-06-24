import 'package:intl/intl.dart';

String castCreatTimeToString(int time) {
  //convert to 21-January-2016 format
  return DateFormat(
    'dd-MMMM-yyyy',
  ).format(DateTime.fromMillisecondsSinceEpoch(time));
}

String castCurrentDayToString(DateTime dateTime) {
  //convert to 21-January-2016 format
  return DateFormat('dd-MMMM-yyyy').format(dateTime);
}
