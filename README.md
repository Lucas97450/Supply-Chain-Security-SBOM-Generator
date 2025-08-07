# Supply Chain Security - SBOM Generator

Application FastAPI pour la génération de SBOM (Software Bill of Materials) avec validation de sécurité automatisée.

## Structure du Projet

```
mini-fastapi-app/
├── app/                    # Application FastAPI
│   ├── __init__.py
│   └── main.py
├── security/               # Module de sécurité
│   ├── policies/           # Politiques OPA/Rego
│   ├── test-data/          # Données de test
│   ├── scripts/            # Scripts de test
│   └── demo.sh             # Démonstration
├── tests/                  # Tests unitaires
├── .github/workflows/      # CI/CD
├── Dockerfile              # Containerisation
├── requirements.txt        # Dépendances Python
└── README.md              # Documentation
```

## Fonctionnalités

- **Génération de SBOM** avec Syft
- **Scan de vulnérabilités** avec Grype
- **Validation de politiques** avec OPA/Rego
- **CI/CD automatisé** avec GitHub Actions
- **Blocage automatique** si CVSS ≥ 7

## Utilisation

```bash
# Installation
pip install -r requirements.txt

# Test des politiques de sécurité
./security/scripts/test-policies.sh

# Démonstration complète
./security/demo.sh

# Lancement de l'application
uvicorn app.main:app --reload
```

## CI/CD

Le workflow GitHub Actions (`supply-chain.yml`) :
1. Génère les SBOM (projet + Docker)
2. Scanne les vulnérabilités
3. Valide les politiques de sécurité
4. Construit et teste l'application
5. Bloque les PR si vulnérabilités critiques détectées