class AddressModel {
  final String id;
  final String addressName;
  final String address;
  final String ward;
  final String province;

  AddressModel({
    required this.id,
    required this.addressName,
    required this.address,
    required this.ward,
    required this.province,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['_id'],
      addressName: json['addressName'],
      address: json['address'],
      ward: json['ward'],
      province: json['province'],
    );
  }
}
