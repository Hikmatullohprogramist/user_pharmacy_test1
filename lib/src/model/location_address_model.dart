class LocationAddressModel {
  Response response;

  LocationAddressModel({
    required this.response,
  });

  factory LocationAddressModel.fromJson(Map<String, dynamic> json) {
    return LocationAddressModel(
      response: json['response'] != null
          ? Response.fromJson(json['response'])
          : Response.fromJson({}),
    );
  }
}

class Response {
  GeoObjectCollection geoObjectCollection;

  Response({
    required this.geoObjectCollection,
  });

  factory Response.fromJson(Map<String, dynamic> json) {
    return Response(
      geoObjectCollection: json['GeoObjectCollection'] != null
          ? GeoObjectCollection.fromJson(json['GeoObjectCollection'])
          : GeoObjectCollection.fromJson({}),
    );
  }
}

class GeoObjectCollection {
  List<FeatureMember> featureMember;

  GeoObjectCollection({
    required this.featureMember,
  });

  factory GeoObjectCollection.fromJson(Map<String, dynamic> json) {
    return GeoObjectCollection(
      featureMember: json["featureMember"] == null
          ? <FeatureMember>[]
          : List<FeatureMember>.from(
              json["featureMember"].map((x) => FeatureMember.fromJson(x)),
            ),
    );
  }
}

class FeatureMember {
  GeoObject geoObject;

  FeatureMember({required this.geoObject});

  factory FeatureMember.fromJson(Map<String, dynamic> json) {
    return FeatureMember(
      geoObject: json['GeoObject'] != null
          ? GeoObject.fromJson(json['GeoObject'])
          : GeoObject.fromJson({}),
    );
  }
}

class GeoObject {
  String name;

  GeoObject({
    required this.name,
  });

  factory GeoObject.fromJson(Map<String, dynamic> json) {
    return GeoObject(name: json['name'] ?? "");
  }
}
