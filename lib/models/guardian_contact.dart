class GuardianContact {
  String n;
  String p;
  bool star;

  GuardianContact({required this.n, required this.p, this.star = false});

  Map<String, dynamic> toJson() => {
        'n': n,
        'p': p,
        'star': star,
      };

  factory GuardianContact.fromJson(Map<String, dynamic> json) =>
      GuardianContact(
        n: json['n'] as String? ?? '',
        p: json['p'] as String? ?? '',
        star: json['star'] as bool? ?? false,
      );
}