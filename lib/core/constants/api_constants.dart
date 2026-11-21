class ApiConstance {
  static const String baseUrl = 'https://dummyjson.com';
  static const String accessToken = String.fromEnvironment(
    'DUMMYJSON_ACCESS_TOKEN',
  );
}
