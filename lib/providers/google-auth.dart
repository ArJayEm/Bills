import 'package:http/http.dart';

class GoogleAuthClient extends BaseClient {
  final Map<String, String> _headers;

  final Client _client = new Client();

  GoogleAuthClient(this._headers);

  Future<StreamedResponse> send(BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
