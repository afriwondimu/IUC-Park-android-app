class AuthService {
  bool authenticate(String username, String password) {
    return username == 'iuc' && password == '123';
  }
}
