class UserProfile {
  String? id;
  String? displayName;
  String? email;
  String? photoUrl;
  String? phoneNumber;
  bool loggedIn;

  UserProfile(
      {this.id,
      this.displayName,
      this.email,
      this.photoUrl,
      this.phoneNumber,
      this.loggedIn = false});
}
