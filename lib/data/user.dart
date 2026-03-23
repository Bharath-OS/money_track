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

  AppUser? copyWith({
    String? username,
    String? email,
    String? password,
    String? photoURL,
  }) {
    return AppUser(
      uid: uid,
      username: username ?? this.username,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
      password: password ?? this.password,
    );
  }
}
