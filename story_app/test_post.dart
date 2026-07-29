import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse(
    'https://www.bdappsdigitalapps.com/NADB26020/verify_otp.php',
  );
  final body = Uri(
    queryParameters: {
      'user_mobile': '01812345678',
      'otp': '000000',
      'referenceNo': 'TEST123',
    },
  ).query;
  print('Body string: ' + body);
  try {
    final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    final resp = await http.post(url, headers: headers, body: body);
    print('Status: ' + resp.statusCode.toString());
    print('Body: ' + resp.body);
  } catch (e) {
    print('Error: ' + e.toString());
  }
}
