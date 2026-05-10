
class Patient {
  final int? id;
  final String nom;
  final String prenom;
  final String telephone;
  final String sexe;
  final String dateNaissance;
  final String profession;
  final String statutMatrimonial;
  final double bmi; 
  final String createdAt;

  Patient({
    this.id, required this.nom, required this.prenom, required this.telephone,
    required this.sexe, required this.dateNaissance, required this.profession,
    required this.statutMatrimonial, required this.bmi, this.createdAt = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id, 'nom': nom, 'prenom': prenom, 'telephone': telephone,
      'sexe': sexe, 'dateNaissance': dateNaissance, 'profession': profession,
      'statutMatrimonial': statutMatrimonial, 'bmi': bmi.toString(), 
      'createdAt': createdAt.isEmpty ? DateTime.now().toIso8601String() : createdAt,
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'], nom: map['nom'] ?? '', prenom: map['prenom'] ?? '',
      telephone: map['telephone'] ?? '', sexe: map['sexe'] ?? '',
      dateNaissance: map['dateNaissance'] ?? '', profession: map['profession'] ?? '',
      statutMatrimonial: map['statutMatrimonial'] ?? '',
      bmi: map['bmi'] != null ? double.tryParse(map['bmi'].toString()) ?? 0.0 : 0.0,
      createdAt: map['createdAt'] ?? DateTime.now().toIso8601String(),
    );
  }
}
