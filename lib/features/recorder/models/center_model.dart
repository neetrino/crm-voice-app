class CenterModel {
  const CenterModel({required this.id, required this.name});

  final String id;
  final String name;

  factory CenterModel.fromJson(Map<String, dynamic> json) {
    return CenterModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}
