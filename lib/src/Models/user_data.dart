// UserData model class
// This model class is used to store the user data in the database

class UserData {
  final String userRole;
  final String? userID;
  final String phoneNumber;
  final String email;

  UserData({
    this.userID,
    required this.userRole,
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
