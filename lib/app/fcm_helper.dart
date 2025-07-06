import 'dart:convert';
import 'package:http/http.dart' as http;

const String apiUrl = 'https://jagafcmapi-production.up.railway.app/send-fcm';

Future<void> sendFcmToToken(
  String fcmToken,
  String title,
  String body, {
  Map<String, dynamic>? data,
}) async {
  final bodyData = {
    'fcmToken': fcmToken,
    'title': title,
    'body': body,
    'data': data ?? {},
  };
  print('PAYLOAD DARI FLUTTER: ${jsonEncode(bodyData)}');
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(bodyData),
  );

  // final response = await http.post(
  //   Uri.parse(apiUrl),
  //   headers: {'Content-Type': 'application/json'},
  //   body: jsonEncode({
  //     'fcmToken': fcmToken,
  //     'title': title,
  //     'body': body,
  //     'data': data ?? {},
  //   }),
  // );
  if (response.statusCode != 200) {
    print('API ERROR: ${response.body}');
  } else {
    print('Notifikasi terkirim: ${response.body}');
  }
}
