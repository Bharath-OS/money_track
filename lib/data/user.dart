class AppUser {
  String? uid;
  String? username;
  String? email;
  String? photoURL;
  String? password;
  AppUser({
    required this.uid,
    this.username = '',
    this.email = '',
    this.photoURL = '',
    this.password = '',
  });
}
