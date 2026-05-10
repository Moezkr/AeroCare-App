<h1 align="center"> 🏥 AeroCare : Application Médicale de Gestion d'Intubation 🏥 </h1>

**AeroCare** est une application mobile développée en Flutter, spécialement conçue pour les médecins en anesthésie-réanimation. Conformément aux exigences du bloc opératoire, elle permet d'évaluer, d'exécuter et d'assurer une traçabilité complète des intubations trachéales grâce à une architecture robuste et 100% hors-ligne (Offline-First).

---

## 🚀 Fonctionnalités Principales (Basées sur le Cahier des Charges)

### 🩺 Parcours Médecin (Utilisateur Exclusif)

* **🔒 Authentification Sécurisée :**
    * Connexion et inscription sécurisées pour restreindre l'accès aux professionnels de santé.
* **📊 Dashboard Centralisé :**
    * Point d'entrée rapide : Nouveau patient, liste des patients, recherche instantanée et synchronisation.
    * Accès direct aux derniers dossiers créés (statut Brouillon / Synchronisé).
* **🗂️ Gestion des Patients :**
    * Création et suivi des fiches patients (Nom, Prénom, Sexe, Âge, Calcul automatique du BMI).
* **📝 Formulaire Clinique d'Intubation (6 Étapes) :**
    * **Étape 1 :** Antécédents médicaux (SAOS, Diabète, Traumatisme cervical...).
    * **Étape 2 :** Évaluation clinique (Score ASA, Mallampati, DTM, Ouverture buccale...).
    * **Étape 3 :** Évaluation du risque (Intubation prévue : facile ou difficile).
    * **Étape 4 :** Données per-intubation (Type, Nombre de tentatives, Cormack, Matériel utilisé).
    * **Étape 5 :** Difficultés et complications (SFAR, description libre).
    * **Étape 6 :** Données complémentaires (Photos cliniques multi-angles et enregistrements vocaux phonétiques).
* **💾 Sauvegarde & Partage (Architecture Offline-First) :**
    * Enregistrement instantané en base de données locale **SQLite** (Disponibilité garantie sans réseau).
    * Génération de rapports médicaux au format **PDF**.
    * Partage rapide via Email ou WhatsApp.
    * Synchronisation asynchrone des données vers un serveur central (VPS) lorsque le réseau est disponible.

---

## ⚙️ Architecture Technique


<img width="1536" height="1024" alt="ChatGPT Image May 10, 2026, 03_23_31 PM" src="https://github.com/user-attachments/assets/6ea8fd48-b8e4-4ec3-af6c-fe762fa4fc71" />



* **Frontend Mobile :** Flutter (Dart), State Management avec `Provider`.
* **Base de données Mobile :** SQLite (Persistance locale critique).
* **Backend & Cloud (VPS Hostinger) :** Node.js, Express, Nginx (HTTPS/SSL).
* **Base de données Cloud :** PostgreSQL hébergé dans un environnement Docker sécurisé (Docker Volumes).

---

## 📱 Captures d'Écran (Mobile Flow)

*Interface ergonomique, mode sombre/clair adapté au bloc opératoire et navigation séquentielle fluide.*

<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/23793452-d952-452b-b98a-43a21189fbee" width="250"/></td>
    <td><img src="https://github.com/user-attachments/assets/11539384-0b53-4f97-930a-79b5239fd0e4" width="250"/></td>
    <td><img src="https://github.com/user-attachments/assets/cf1ecfb6-febb-4001-ab99-2ed413287864" width="250"/></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/99ceb8d2-aa53-4168-9f72-fe4d1b893627" width="250"/></td>
    <td><img src="https://github.com/user-attachments/assets/d9874945-3e19-4afe-859a-e7d346fded1b" width="250"/></td>
    <td><img src="https://github.com/user-attachments/assets/693729c0-0ea0-41b6-9155-3c1bbfe323b5" width="250"/></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/bb24a61d-ebdd-48ca-bb16-9ad5327b624b" width="250"/></td>
    <td><img src="https://github.com/user-attachments/assets/2f1ffa91-2699-4a85-8c59-00fecc75ee46" width="250"/></td>
    <td><img src="https://github.com/user-attachments/assets/8ca46648-43b7-4c09-b40d-6df3de2a2044" width="250"/></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/9a977b1c-ff4d-4b44-808a-03bbaff8ca85" width="250"/></td>
    <td><img src="https://github.com/user-attachments/assets/627caa08-8c00-4d7d-91aa-6493848521bf" width="250"/></td>
    <td><img src="https://github.com/user-attachments/assets/a6dc6c30-c5df-49ef-848d-becf9a2929ed" width="250"/></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/9d2e3fcd-cfd5-4728-921f-03988497627d" width="250"/></td>
    <td><img src="https://github.com/user-attachments/assets/be5f9214-c72b-4ddd-b233-04baf9bf196f" width="250"/></td>
    <td><img src="https://github.com/user-attachments/assets/a19de0f4-4207-452c-98e0-8fa54e6213e8" width="250"/></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/8857b086-413f-4e2b-8c3f-3727cfa6a575" width="250"/></td>
    <td><img src="https://github.com/user-attachments/assets/02875ae2-a3df-4f6a-b266-657082da3527" width="250"/></td>
    <td><img src="https://github.com/user-attachments/assets/ff2e3fd4-b110-4b43-b5d5-cc421652d4e7" width="250"/></td>
  </tr>
</table>

<p align="center">
  <i></i>
</p>
