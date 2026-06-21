import 'package:supabase/supabase.dart';
import 'dart:io';

void main() async {
  var env = File('.env').readAsStringSync();
  var url = '';
  var key = '';
  for (var line in env.split('\n')) {
    if (line.startsWith('SUPABASE_URL=')) {
      url = line.split('=')[1].trim().replaceAll('"', '').replaceAll("'", '');
    }
    if (line.startsWith('SUPABASE_ANON_KEY=')) {
      key = line.split('=')[1].trim().replaceAll('"', '').replaceAll("'", '');
    }
  }

  final client = SupabaseClient(url, key);

  // جلب طالب وسجل موجود
  final existing = await client
      .from('student_grades')
      .select('grade_id, id_student, id_group, final_grade')
      .limit(1)
      .maybeSingle();
  
  if (existing != null) {
    print('Existing row: $existing'); // ignore: avoid_print
    final gradeId = existing['grade_id'];

    // تحديث final_grade
    await client.from('student_grades').update({
      'final_grade': 95,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('grade_id', gradeId);

    final updated = await client
        .from('student_grades')
        .select('grade_id, final_grade')
        .eq('grade_id', gradeId)
        .single();
    print('After update: $updated'); // ignore: avoid_print
  } else {
    print('No rows found — testing INSERT...'); // ignore: avoid_print
    final stud = await client.from('student').select('stud_id, id_group').limit(1).single();
    await client.from('student_grades').insert({
      'id_student': stud['stud_id'],
      'id_group': stud['id_group'],
      'final_grade': 88,
      'updated_at': DateTime.now().toIso8601String(),
    });
    print('INSERT success!'); // ignore: avoid_print
  }

  exit(0);
}
