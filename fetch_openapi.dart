import 'dart:io';
import 'dart:convert';

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
  
  final httpClient = HttpClient();
  final request = await httpClient.getUrl(Uri.parse('$url/rest/v1/?apikey=$key'));
  final response = await request.close();
  final body = await response.transform(utf8.decoder).join();
  File('openapi.json').writeAsStringSync(body);
  print('Saved OpenAPI spec.'); // ignore: avoid_print
  exit(0);
}
