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
  
  try {
    await client.from('sprvsr_grades').delete().eq('grade_id', 4);
    print('Deleted row.'); // ignore: avoid_print
  } catch (e) {
    print('error: $e'); // ignore: avoid_print
  }
  
  exit(0);
}
