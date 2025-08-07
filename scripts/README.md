# Scripts - Supply Chain Security

Ce dossier contient tous les scripts utilitaires pour le projet.

## Scripts disponibles

### Signature et attestation
- **sign-docker.sh** : Signature d'image Docker avec Cosign
- **sign-docker-local.sh** : Signature locale fonctionnelle (sans Docker Hub)

### Tests et validation
- **test-complete.sh** : Test complet de toutes les fonctionnalités

## Utilisation

### Signature Docker
```bash
# Signature locale (recommandé pour les tests)
./scripts/sign-docker-local.sh

# Signature complète (nécessite Docker Hub)
./scripts/sign-docker.sh
```

### Tests complets
```bash
# Test de toutes les fonctionnalités
./scripts/test-complete.sh
```

## Intégration CI/CD

Ces scripts sont utilisés par le workflow GitHub Actions :
- Génération automatique de SBOM
- Scan de vulnérabilités
- Signature et attestation
- Validation des politiques de sécurité

## Sécurité

- Les scripts utilisent des outils sécurisés (Syft, Grype, Cosign)
- Validation automatique des signatures
- Politiques de sécurité appliquées
- Environnement isolé en CI/CD 