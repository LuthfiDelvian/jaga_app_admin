import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class CloudinaryHelper {
  static const String cloudName = 'dp0iysyni';
  static const String apiKey = '153217979944289';
  static const String apiSecret = 'Dpcj8TID2uTvcJExBm9RuK7qSew';

  static Future<bool> deleteImage(String publicId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Perhatikan urutan alfabetis: invalidate, public_id, timestamp
      final signatureString =
          'invalidate=true&public_id=$publicId&timestamp=$timestamp$apiSecret';
      final signature = sha1.convert(utf8.encode(signatureString)).toString();

      final response = await http.post(
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/destroy'),
        body: {
          'public_id': publicId,
          'api_key': apiKey,
          'timestamp': '$timestamp',
          'signature': signature,
          'invalidate': 'true',
        },
      );

      final result = json.decode(response.body);
      debugPrint('Cloudinary delete response: $result');

      return result['result'] == 'ok';
    } catch (e, stack) {
      debugPrint('Cloudinary delete error: $e');
      debugPrint('$stack');
      return false;
    }
  }
}
