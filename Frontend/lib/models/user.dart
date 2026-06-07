class User {
  final int id;
  final String username;
  final String email;
  final String? partnerCode;
  final int? pairedWith;

  User({
    required this.id,
    required this.username,
    required this.email, //for future use
    this.partnerCode,
    this.pairedWith,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      partnerCode: json['partner_code'],
      pairedWith: json['paired_with'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,  //for future use
      'partner_code': partnerCode,
      'paired_with': pairedWith,
    };
  }
}
