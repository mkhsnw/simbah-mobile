class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}

class NoDataException implements Exception {
  final String message;
  NoDataException(this.message);
  
  @override
  String toString() => message;
}