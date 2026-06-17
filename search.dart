import 'dart:io';
void main() {
  var lines = File('lib/services/supabase_service.dart').readAsLinesSync();
  var i = lines.indexWhere((l) => l.contains('saveStudentGrades'));
  if (i >= 0) {
    for (var j = i; j < i + 30 && j < lines.length; j++) {
      print(lines[j]);
    }
  } else {
    print('Not found');
  }
}
