class CheckError {
  CheckError({
    required this.error,
    required this.msg,
  });

  int error;
  String msg;

  factory CheckError.fromJson(Map<String, dynamic> json) => CheckError(
        error: json["error"] ?? 0,
        msg: json["msg"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "error": error,
        "msg": msg,
      };
}
