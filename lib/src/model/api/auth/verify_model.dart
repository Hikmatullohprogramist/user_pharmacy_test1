class VerifyModel {
  String msg;
  int status;
  User user;
  String token;
  bool konkurs;

  VerifyModel({
    required this.msg,
    required this.status,
    required this.user,
    required this.token,
    required this.konkurs,
  });

  factory VerifyModel.fromJson(Map<String, dynamic> json) {
    return VerifyModel(
      msg: json['msg'] ?? "",
      status: json['status'] ?? 0,
      user: json['user'] != null
          ? User.fromJson(json['user'])
          : User.fromJson({}),
      token: json['token'] ?? "",
      konkurs: json['konkurs'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['msg'] = this.msg;
    data['status'] = this.status;
    data['user'] = this.user.toJson();
    data['token'] = this.token;
    return data;
  }
}

class User {
  int id;
  String login;
  String avatar;
  String firstName;
  String lastName;
  String gender;
  String birthDate;
  int complete;

  User({
    required this.id,
    required this.login,
    required this.avatar,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.birthDate,
    required this.complete,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      login: json['login'] ?? "",
      avatar: json['avatar'] ?? "",
      firstName: json['first_name'] ?? "",
      lastName: json['last_name'] ?? "",
      gender: json['gender'] ?? "",
      birthDate: json['birth_date'] ?? "",
      complete: json['complete'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['login'] = this.login;
    data['avatar'] = this.avatar;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['gender'] = this.gender;
    data['birth_date'] = this.birthDate;
    data['complete'] = this.complete;
    return data;
  }
}
