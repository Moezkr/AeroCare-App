import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/shared_widgets/custom_text_field.dart';
import '../../../core/shared_widgets/premium_dropdown.dart';
import '../../../providers/patient_provider.dart';
import '../../../models/patient.dart';

class CreatePatientScreen extends StatefulWidget {
  final Patient? patientToEdit;
  const CreatePatientScreen({super.key, this.patientToEdit});

  @override
  State<CreatePatientScreen> createState() => _CreatePatientScreenState();
}

class _CreatePatientScreenState extends State<CreatePatientScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _dateDisplayController = TextEditingController();

  DateTime? _selectedDate;
  String _sexe = 'Homme';
  String _profession = 'Actif';
  String _statutMatrimonial = 'Marié(e)';

  @override
  void initState() {
    super.initState();
    if (widget.patientToEdit != null) {
      final p = widget.patientToEdit!;
      _nomController.text = p.nom;
      _prenomController.text = p.prenom;
      _telephoneController.text = p.telephone;
      _sexe = ['Homme', 'Femme'].contains(p.sexe) ? p.sexe : 'Homme';
      _profession = ['Actif', 'Retraité', 'Étudiant', 'Sans activité'].contains(p.profession) ? p.profession : 'Actif';
      _statutMatrimonial = ['Célibataire', 'Marié(e)', 'Divorcé(e)', 'Veuf(ve)'].contains(p.statutMatrimonial) ? p.statutMatrimonial : 'Marié(e)';
      
      try {
        if (p.dateNaissance.isNotEmpty) {
          _selectedDate = DateTime.parse(p.dateNaissance);
          _dateDisplayController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
        }
      } catch (e) {
        print("Date parse error: $e");
      }
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _dateDisplayController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(1960),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateDisplayController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _savePatient() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez sélectionner une date de naissance'), backgroundColor: Colors.red));
        return;
      }

      final newPatient = Patient(
        id: widget.patientToEdit?.id,
        nom: _nomController.text,
        prenom: _prenomController.text,
        telephone: _telephoneController.text,
        sexe: _sexe,
        dateNaissance: _selectedDate!.toIso8601String(),
        profession: _profession,
        statutMatrimonial: _statutMatrimonial,
        bmi: widget.patientToEdit?.bmi ?? 0.0, 
      );

      if (widget.patientToEdit == null) {
        await Provider.of<PatientProvider>(context, listen: false).addPatient(newPatient);
      } else {
        await Provider.of<PatientProvider>(context, listen: false).updatePatient(newPatient);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.patientToEdit == null ? 'Patient ajouté !' : 'Patient mis à jour !'), 
          backgroundColor: Colors.green
        ));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.patientToEdit == null ? 'Nouveau Patient' : 'Modifier le Patient', style: const TextStyle(fontWeight: FontWeight.w600)), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Informations de base', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                CustomTextField(controller: _nomController, label: 'Nom', icon: Icons.person_outline, validator: (v) => v!.isEmpty ? 'Champ requis' : null),
                CustomTextField(controller: _prenomController, label: 'Prénom', icon: Icons.person_outline, validator: (v) => v!.isEmpty ? 'Champ requis' : null),
                CustomTextField(
                  controller: _telephoneController, 
                  label: 'Téléphone', 
                  hint: 'Ex: 22333444', 
                  icon: Icons.phone_outlined, 
                  keyboardType: TextInputType.number, 
                  maxLength: 8,
                  validator: (v) => (v == null || v.length != 8) ? 'Entrez 8 chiffres' : null
                ),
                
                TextFormField(
                  controller: _dateDisplayController, 
                  readOnly: true, 
                  onTap: () => _selectDate(context), 
                  decoration: const InputDecoration(labelText: 'Date de naissance', hintText: 'JJ/MM/AAAA', prefixIcon: Icon(Icons.calendar_today_outlined)), 
                  validator: (v) => v!.isEmpty ? 'Champ requis' : null
                ),
                
                const SizedBox(height: 24),
                const Text('Profil du patient', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                PremiumDropdown(label: 'Sexe', icon: Icons.wc_outlined, items: const ['Homme', 'Femme'], value: _sexe, onChanged: (v) => setState(() => _sexe = v!)),
                PremiumDropdown(label: 'Profession', icon: Icons.work_outline, items: const ['Actif', 'Retraité', 'Étudiant', 'Sans activité'], value: _profession, onChanged: (v) => setState(() => _profession = v!)),
                PremiumDropdown(label: 'Statut Matrimonial', icon: Icons.family_restroom_outlined, items: const ['Célibataire', 'Marié(e)', 'Divorcé(e)', 'Veuf(ve)'], value: _statutMatrimonial, onChanged: (v) => setState(() => _statutMatrimonial = v!)),
                
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _savePatient,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text(widget.patientToEdit == null ? 'Enregistrer le patient' : 'Mettre à jour le patient', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
