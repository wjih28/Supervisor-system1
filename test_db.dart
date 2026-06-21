import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  final supabaseUrl = dotenv.env['SUPABASE_URL']!;
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;
  final client = SupabaseClient(supabaseUrl, supabaseAnonKey);
  
  final res = await client.from('supervisor').select().limit(1);
  if (res.isNotEmpty) {
    print(res.first.keys.toList()); // ignore: avoid_print
  } else {
    print('No rows found'); // ignore: avoid_print
  }
}
