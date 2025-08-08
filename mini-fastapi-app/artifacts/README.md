# Artifacts - Supply Chain Security

Ce dossier contient tous les artifacts générés par le pipeline de sécurité.

## Structure

```
artifacts/
├── sbom/                    # Software Bill of Materials
│   ├── sbom.json           # SBOM du projet
│   ├── docker-sbom.json    # SBOM de l'image Docker
│   ├── sbom-project.json   # SBOM généré en CI/CD
│   └── sbom-docker.json    # SBOM Docker généré en CI/CD
├── vulnerabilities/         # Rapports de vulnérabilités
│   ├── vulnerability-scan.json           # Scan du projet
│   ├── vulnerability-scan-docker.json    # Scan de l'image Docker
│   ├── vulnerability-scan-project.json   # Scan généré en CI/CD
│   └── vulnerability-scan-docker.json    # Scan Docker généré en CI/CD
└── signing/                # Artifacts de signature
    ├── cosign.key          # Clé privée Cosign
    ├── cosign.pub          # Clé publique Cosign
    ├── docker-test.txt     # Fichier de test pour signature
    └── provenance.json     # Provenance SLSA Level 2
```

## Utilisation

### SBOM
Les fichiers SBOM contiennent l'inventaire complet des dépendances :
- **sbom.json** : SBOM du projet local
- **docker-sbom.json** : SBOM de l'image Docker
- **sbom-project.json** : SBOM généré automatiquement en CI/CD
- **sbom-docker.json** : SBOM Docker généré automatiquement en CI/CD

### Vulnérabilités
Les rapports de vulnérabilités identifient les failles de sécurité :
- **vulnerability-scan.json** : Scan du projet local
- **vulnerability-scan-docker.json** : Scan de l'image Docker
- **vulnerability-scan-project.json** : Scan généré automatiquement en CI/CD
- **vulnerability-scan-docker.json** : Scan Docker généré automatiquement en CI/CD

### Signatures
Les artifacts de signature assurent l'intégrité :
- **cosign.key** : Clé privée pour signer (à garder secrète)
- **cosign.pub** : Clé publique pour vérifier
- **docker-test.txt** : Fichier de test pour signature locale
- **provenance.json** : Provenance SLSA Level 2 signée

## Génération automatique

Tous ces artifacts sont générés automatiquement par le workflow GitHub Actions :
1. **SBOM** : Généré avec Syft
2. **Vulnérabilités** : Scannées avec Grype
3. **Signatures** : Créées avec Cosign
4. **Provenance** : Générée selon SLSA Level 2

## Sécurité

- Les clés privées (`cosign.key`) ne doivent jamais être commitées
- Les artifacts sont générés dans un environnement isolé (GitHub Actions)
- Toutes les signatures sont vérifiées automatiquement
- La provenance SLSA Level 2 assure la traçabilité complète 