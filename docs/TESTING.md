# Guide de Test - Supply Chain Security

Ce guide explique comment tester toutes les fonctionnalités du système.

## Test Rapide

### 1. Test complet automatique
```bash
./test-complete.sh
```
Ce script teste automatiquement toutes les fonctionnalités.

### 2. Test par étapes

#### Test de l'application
```bash
# Installation des dépendances
pip install -r requirements.txt

# Test de l'application
python -c "from app.main import app; print('App OK')"

# Lancement de l'application
uvicorn app.main:app --reload
```

#### Test des politiques de sécurité
```bash
# Test des politiques
./security/scripts/test-policies.sh

# Test manuel avec Conftest
conftest test security/test-data/vulnerabilities.json --policy security/policies/security.rego
```

#### Test de génération SBOM
```bash
# Installation de Syft
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin

# Génération SBOM
syft . -o json > sbom.json
syft . -o table
```

#### Test Docker
```bash
# Construction de l'image
docker build -t supply-chain-security .

# Test de l'image
docker run --rm supply-chain-security python -c "import app.main; print('Docker OK')"
```

#### Test de signature avec Cosign
```bash
# Installation de Cosign
brew install cosign  # macOS
# ou
wget -O cosign https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64

# Configuration
./security/signing/setup-cosign.sh

# Signature de l'image
./security/signing/sign-image.sh

# Vérification de la signature
./security/signing/verify-signature.sh
```

#### Test des attestations
```bash
# Attestation du SBOM et provenance
./security/signing/attest-sbom.sh
```

## Test du CI/CD

### 1. Test local du workflow
```bash
# Validation YAML
python -c "import yaml; yaml.safe_load(open('.github/workflows/supply-chain.yml'))"
```

### 2. Test en poussant du code
```bash
# Faire un changement
echo "# Test" >> README.md

# Commit et push
git add README.md
git commit -m "Test CI/CD"
git push origin main
```

### 3. Vérifier sur GitHub
- Aller sur https://github.com/Lucas97450/Supply-Chain-Security-SBOM-Generator/actions
- Voir les résultats du workflow

## Test des vulnérabilités

### 1. Test avec données critiques
```bash
# Créer des données de test critiques
cat > test-critical.json << EOF
{
  "vulnerabilities": [
    {
      "id": "CVE-TEST-001",
      "name": "Critical Test",
      "cvss_score": 9.1,
      "severity": "CRITICAL"
    }
  ]
}
EOF

# Tester - doit échouer
conftest test test-critical.json --policy security/policies/security.rego
```

### 2. Test avec données sécurisées
```bash
# Créer des données de test sécurisées
cat > test-safe.json << EOF
{
  "vulnerabilities": [
    {
      "id": "CVE-TEST-002",
      "name": "Low Test",
      "cvss_score": 2.0,
      "severity": "LOW"
    }
  ]
}
EOF

# Tester - doit passer
conftest test test-safe.json --policy security/policies/security.rego
```

## Démonstration complète

```bash
# Démonstration interactive
./security/demo.sh
```

## Résolution des problèmes

### Conftest non installé
```bash
# macOS
brew install conftest

# Linux
wget https://github.com/open-policy-agent/conftest/releases/latest/download/conftest_0.62.0_Linux_x86_64.tar.gz
tar xzf conftest_0.62.0_Linux_x86_64.tar.gz
sudo mv conftest /usr/local/bin/
```

### Cosign non installé
```bash
# macOS
brew install cosign

# Linux
wget -O cosign https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64
chmod +x cosign
sudo mv cosign /usr/local/bin/
```

### Syft non installé
```bash
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
```

## Vérification finale

Après tous les tests, vous devriez avoir :
- ✅ Application FastAPI fonctionnelle
- ✅ Politiques de sécurité validées
- ✅ SBOM généré
- ✅ Image Docker construite et signée
- ✅ Workflow CI/CD configuré
- ✅ Tests unitaires passants 