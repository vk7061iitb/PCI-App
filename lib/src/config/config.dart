class Config {
  static const String authBaseURL = 'http://13.201.2.105';

  static String getAuthBaseURL() {
    return authBaseURL;
  }

  // Endpoints
  static const String signUpEndpoint = '/signup';
  static const String loginEndPoint = '/login';
}
