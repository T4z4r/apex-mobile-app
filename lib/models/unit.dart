class Unit {
  final int id;
  final String label;
  final int rent;
  final int deposit;

  Unit(
      {required this.id,
      required this.label,
      required this.rent,
      required this.deposit});

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'],
      label: json['unit_label'],
      rent: json['rent_amount'],
      deposit: json['deposit_amount'],
    );
  }
}
