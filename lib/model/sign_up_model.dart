class UserInfo {
  final String firstName;
  final String lastName;
  final String gender;
  final int score;
  final String city;
  final String dob;

  UserInfo({
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.score,
    required this.city,
    required this.dob,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return UserInfo(
      firstName: data['first_name'],
      lastName: data['last_name'],
      gender: data['gender'],
      score: data['score'],
      city: data['city'],
      dob: data['dob'],
    );
  }
}
