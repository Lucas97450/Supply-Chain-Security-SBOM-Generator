# Security Module

Ce module contient tous les éléments liés à la sécurité de la chaîne d'approvisionnement.

## Structure

```
security/
├── policies/           # Politiques OPA/Rego
│   └── security.rego   # Règles de validation des vulnérabilités
├── test-data/          # Données de test
│   └── vulnerabilities.json
├── scripts/            # Scripts de test
│   └── test-policies.sh
├── demo.sh             # Script de démonstration complet
├── .conftest.yaml      # Configuration Conftest
└── README.md           # Ce fichier
```

## Politiques de Sécurité

### security.rego
- **Vulnérabilités critiques** : Échoue si CVSS ≥ 7
- **Vulnérabilités élevées** : Avertit si CVSS ≥ 5
- **Dépendances obsolètes** : Échoue si dépendance obsolète
- **Licences non autorisées** : Échoue si licence non autorisée

## Tests

### test-policies.sh
Script pour tester les politiques localement avec Conftest.

### demo.sh
Script de démonstration complet montrant :
- Installation de Conftest
- Tests avec vulnérabilités critiques/élevées/sécurisées
- Test de l'application FastAPI
- Test Docker
- Simulation CI/CD

## Utilisation

```bash
# Test des politiques
./security/scripts/test-policies.sh

# Démonstration complète
./security/demo.sh

# Test avec Conftest directement
conftest test security/test-data/vulnerabilities.json --policy security/policies/security.rego
```

## Intégration CI/CD

Les politiques sont intégrées dans le workflow GitHub Actions principal (`supply-chain.yml`) :
- Validation automatique des vulnérabilités
- Blocage des PR si CVSS ≥ 7
- Génération de rapports de sécurité 