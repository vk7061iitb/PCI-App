class UserData {
  final String? userID;
  final String phoneNumber;
  final String email;

  UserData({
    this.userID,
    required this.phoneNumber,
    required this.email,
  });

  toJson() {
    return {
      'Email_Id': email,
      'Phone_num': phoneNumber,
    };
  }
}
