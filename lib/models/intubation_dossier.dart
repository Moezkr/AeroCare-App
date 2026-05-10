
class IntubationDossier {
  final int? id;
  final int patientId;
  final String dateCreation;
  final int isSynced;

  final int intubationDifficile;
  final int saos;
  final int diabete;
  final int goitre;
  final int maladieRhumatismale;
  final int traumatismeCervical;
  final int brulureFaciale;
  final String brulureLocalisation;
  final int dysmorphieFaciale;
  final String dysmorphieLocalisation;
  final int tumeurFaciale;
  final String tumeurLocalisation;
  final int ronflement;
  final int dysphonie;
  final int dysphagie;

  final String scoreAsa;
  final String mallampati;
  final String dtm;
  final String ouvertureBuccale;
  final String tourDeCou;
  final String mobiliteRachis;
  final int macroglossie;
  final String scoreStopbang;

  final String intubationPrevue;
  final String acteOperatoire;

  final String typeIntubation;
  final String nombreTentatives;
  final int videoLaryngoscope;
  final int guideEichmann;
  final String cormack;
  final int tentative2;

  final String intubationRealisee; 
  final int intubationDifficileSfar;
  final String complications;

  final String? photoFace;
  final String? photoProfil;
  final String? photoBouche;
  final String? photoProfilNeutre;
  final String? photoProfilExt;
  final String? audioA;
  final String? audioKha;
  final String? audioHa;
  final String? audioHaa;
  final String? audioGha;
  final String? audioAaa;

  IntubationDossier({
    this.id, required this.patientId, required this.dateCreation, this.isSynced = 0,
    this.intubationDifficile = 0, this.saos = 0, this.diabete = 0, this.goitre = 0,
    this.maladieRhumatismale = 0, this.traumatismeCervical = 0, this.brulureFaciale = 0,
    this.brulureLocalisation = '', this.dysmorphieFaciale = 0, this.dysmorphieLocalisation = '',
    this.tumeurFaciale = 0, this.tumeurLocalisation = '', this.ronflement = 0,
    this.dysphonie = 0, this.dysphagie = 0, this.scoreAsa = 'I', this.mallampati = 'I',
    this.dtm = '<6 cm', this.ouvertureBuccale = '<35 mm', this.tourDeCou = '<45 cm',
    this.mobiliteRachis = 'Souple', this.macroglossie = 0, this.scoreStopbang = '0',
    this.intubationPrevue = 'Facile', this.acteOperatoire = '', this.typeIntubation = 'Orale',
    this.nombreTentatives = '1', this.videoLaryngoscope = 0, this.guideEichmann = 0,
    this.cormack = 'I', this.tentative2 = 0, this.intubationRealisee = 'Facile',
    this.intubationDifficileSfar = 0, this.complications = '',
    this.photoFace, this.photoProfil, this.photoBouche, this.photoProfilNeutre, this.photoProfilExt,
    this.audioA, this.audioKha, this.audioHa, this.audioHaa, this.audioGha, this.audioAaa,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id, 'patientId': patientId, 'dateCreation': dateCreation, 'is_synced': isSynced,
      'intubationDifficile': intubationDifficile, 'saos': saos, 'diabete': diabete, 'goitre': goitre,
      'maladieRhumatismale': maladieRhumatismale, 'traumatismeCervical': traumatismeCervical,
      'brulureFaciale': brulureFaciale, 'brulureLocalisation': brulureLocalisation,
      'dysmorphieFaciale': dysmorphieFaciale, 'dysmorphieLocalisation': dysmorphieLocalisation,
      'tumeurFaciale': tumeurFaciale, 'tumeurLocalisation': tumeurLocalisation,
      'ronflement': ronflement, 'dysphonie': dysphonie, 'dysphagie': dysphagie,
      'scoreAsa': scoreAsa, 'mallampati': mallampati, 'dtm': dtm, 'ouvertureBuccale': ouvertureBuccale,
      'tourDeCou': tourDeCou, 'mobiliteRachis': mobiliteRachis, 'macroglossie': macroglossie,
      'scoreStopbang': scoreStopbang, 'intubationPrevue': intubationPrevue, 'acteOperatoire': acteOperatoire,
      'typeIntubation': typeIntubation, 'nombreTentatives': nombreTentatives,
      'videoLaryngoscope': videoLaryngoscope, 'guideEichmann': guideEichmann, 'cormack': cormack,
      'tentative2': tentative2, 'intubationRealisee': intubationRealisee,
      'intubationDifficileSfar': intubationDifficileSfar, 'complications': complications,
      'photoFace': photoFace, 'photoProfil': photoProfil, 'photoBouche': photoBouche,
      'photoProfilNeutre': photoProfilNeutre, 'photoProfilExt': photoProfilExt,
      'audioA': audioA, 'audioKha': audioKha, 'audioHa': audioHa, 'audioHaa': audioHaa,
      'audioGha': audioGha, 'audioAaa': audioAaa,
    };
  }

  factory IntubationDossier.fromMap(Map<String, dynamic> map) {
    return IntubationDossier(
      id: map['id'], patientId: map['patientId'], dateCreation: map['dateCreation'] ?? '',
      isSynced: map['is_synced'] ?? 0, intubationDifficile: map['intubationDifficile'] ?? 0,
      saos: map['saos'] ?? 0, diabete: map['diabete'] ?? 0, goitre: map['goitre'] ?? 0,
      maladieRhumatismale: map['maladieRhumatismale'] ?? 0, traumatismeCervical: map['traumatismeCervical'] ?? 0,
      brulureFaciale: map['brulureFaciale'] ?? 0, brulureLocalisation: map['brulureLocalisation'] ?? '',
      dysmorphieFaciale: map['dysmorphieFaciale'] ?? 0, dysmorphieLocalisation: map['dysmorphieLocalisation'] ?? '',
      tumeurFaciale: map['tumeurFaciale'] ?? 0, tumeurLocalisation: map['tumeurLocalisation'] ?? '',
      ronflement: map['ronflement'] ?? 0, dysphonie: map['dysphonie'] ?? 0, dysphagie: map['dysphagie'] ?? 0,
      scoreAsa: map['scoreAsa'] ?? 'I', mallampati: map['mallampati'] ?? 'I', dtm: map['dtm'] ?? '<6 cm',
      ouvertureBuccale: map['ouvertureBuccale'] ?? '<35 mm', tourDeCou: map['tourDeCou'] ?? '<45 cm',
      mobiliteRachis: map['mobiliteRachis'] ?? 'Souple', macroglossie: map['macroglossie'] ?? 0,
      scoreStopbang: map['scoreStopbang'] ?? '0', intubationPrevue: map['intubationPrevue'] ?? 'Facile',
      acteOperatoire: map['acteOperatoire'] ?? '', typeIntubation: map['typeIntubation'] ?? 'Orale',
      nombreTentatives: map['nombreTentatives'] ?? '1', videoLaryngoscope: map['videoLaryngoscope'] ?? 0,
      guideEichmann: map['guideEichmann'] ?? 0, cormack: map['cormack'] ?? 'I',
      tentative2: map['tentative2'] ?? 0, intubationRealisee: map['intubationRealisee'] ?? 'Facile',
      intubationDifficileSfar: map['intubationDifficileSfar'] ?? 0, complications: map['complications'] ?? '',
      photoFace: map['photoFace'], photoProfil: map['photoProfil'], photoBouche: map['photoBouche'],
      photoProfilNeutre: map['photoProfilNeutre'], photoProfilExt: map['photoProfilExt'],
      audioA: map['audioA'], audioKha: map['audioKha'], audioHa: map['audioHa'],
      audioHaa: map['audioHaa'], audioGha: map['audioGha'], audioAaa: map['audioAaa'],
    );
  }
}
