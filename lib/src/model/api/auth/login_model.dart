class LoginModel {
  LoginModel({
    required this.status,
    required this.msg,
    required this.konkurs,
  });

  int status;
  String msg;
  bool konkurs;

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
        status: json["status"] ?? 0,
        msg: json["msg"] ?? "",
        konkurs: json["konkurs"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "msg": msg,
        "konkurs": konkurs,
      };
}
