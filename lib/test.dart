import 'package:intl/intl.dart';

main() {
  String inp = "2017/04/01";
  List inpl = inp.split('/');
  var date = new DateTime(
    int.parse(inpl[0]), int.parse(inpl[1]), int.parse(inpl[2])
  );
  var formatter = new DateFormat('EEEE, MMMM d');
  String formatted = formatter.format(date);
  print(formatted);
}