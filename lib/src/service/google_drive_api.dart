import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as google_drive;
import 'package:http/http.dart' as http;

class GoogleDriveApiService {
  final GoogleSignIn googleSignIn = GoogleSignIn(
    signInOption: SignInOption.standard,
    scopes: [google_drive.DriveApi.driveFileScope],
  );

  Future<http.Client?> getClient() async {
    GoogleSignInAccount? user = googleSignIn.currentUser;

    user ??= await googleSignIn.signInSilently(
      reAuthenticate: true,
    );
    user ??= await googleSignIn.signIn();
    if (user == null) {
      return null;
    }
    GoogleSignInAuthentication auth = await user.authentication;
    return GoogleAuthClient(auth.accessToken!);
  }

  Future<void> logout() async {
    // await googleSignIn.disconnect();
    await googleSignIn.signOut();
  }
}

// Custom HTTP Client to inject access token
class GoogleAuthClient extends http.BaseClient {
  final String _accessToken;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._accessToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_accessToken';
    return _client.send(request);
  }

  @override
  void close() {
    _client.close();
    super.close();
  }
}
