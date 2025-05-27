class AuthService {
  bool authenticate(String username, String password) {
    return username == 'admin' && password == '123';
  }
}