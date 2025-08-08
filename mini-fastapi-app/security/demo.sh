#!/bin/bash

# Script de démonstration pour le projet Supply Chain Security
# Montre le fonctionnement complet du système

echo " Démonstration Supply Chain Security"
echo "====================================="
echo ""

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📋 Étape 1: Vérification de l'environnement${NC}"
echo "----------------------------------------"

# Vérifier Conftest
if command -v conftest &> /dev/null; then
    echo -e "${GREEN} Conftest installé${NC}"
    conftest --version
else
    echo -e "${RED} Conftest non installé${NC}"
    echo "Installation..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install conftest
    else
        echo "Veuillez installer conftest manuellement"
        exit 1
    fi
fi

echo ""
echo -e "${BLUE} Étape 2: Test des politiques de sécurité${NC}"
echo "----------------------------------------"

# Test avec données critiques
echo -e "${YELLOW} Test avec vulnérabilité critique (CVSS 9.1):${NC}"
cat > /tmp/critical-demo.json << EOF
{
  "vulnerabilities": [
    {
      "id": "CVE-DEMO-001",
      "name": "Critical Demo Vulnerability",
      "cvss_score": 9.1,
      "severity": "CRITICAL"
    }
  ],
  "dependencies": []
}
EOF

conftest test /tmp/critical-demo.json --policy security/policies/security.rego --output table

echo ""
echo -e "${YELLOW} Test avec vulnérabilité élevée (CVSS 6.5):${NC}"
cat > /tmp/high-demo.json << EOF
{
  "vulnerabilities": [
    {
      "id": "CVE-DEMO-002",
      "name": "High Demo Vulnerability",
      "cvss_score": 6.5,
      "severity": "HIGH"
    }
  ],
  "dependencies": []
}
EOF

conftest test /tmp/high-demo.json --policy security/policies/security.rego --output table

echo ""
echo -e "${YELLOW} Test avec données sécurisées:${NC}"
cat > /tmp/safe-demo.json << EOF
{
  "vulnerabilities": [
    {
      "id": "CVE-DEMO-003",
      "name": "Low Demo Vulnerability",
      "cvss_score": 2.0,
      "severity": "LOW"
    }
  ],
  "dependencies": [
    {
      "name": "safe-package",
      "version": "1.0.0",
      "license": "MIT",
      "is_deprecated": false
    }
  ]
}
EOF

conftest test /tmp/safe-demo.json --policy security/policies/security.rego --output table

echo ""
echo -e "${BLUE} Étape 3: Test de l'application FastAPI${NC}"
echo "----------------------------------------"

# Vérifier Python et dépendances
if command -v python3 &> /dev/null; then
    echo -e "${GREEN} Python installé${NC}"
    python3 --version
    
    # Installer les dépendances
    echo " Installation des dépendances..."
    pip3 install -r requirements.txt
    
    # Test de l'application
    echo " Test de l'application FastAPI..."
    python3 -c "from app.main import app; print(' Application importée avec succès')"
    
else
    echo -e "${RED} Python non installé${NC}"
fi

echo ""
echo -e "${BLUE} Étape 4: Test Docker${NC}"
echo "----------------------------------------"

# Vérifier Docker
if command -v docker &> /dev/null; then
    echo -e "${GREEN} Docker installé${NC}"
    docker --version
    
    # Construire l'image
    echo " Construction de l'image Docker..."
    docker build -t supply-chain-demo .
    
    # Test de l'image
    echo " Test de l'image Docker..."
    docker run --rm supply-chain-demo python -c "from app.main import app; print('✅ Application Docker fonctionne')"
    
else
    echo -e "${RED} Docker non installé${NC}"
fi

echo ""
echo -e "${BLUE} Étape 5: Simulation CI/CD${NC}"
echo "----------------------------------------"

echo " Simulation d'un pipeline CI/CD..."
echo "1. Validation des politiques de sécurité"
echo "2. Test des vulnérabilités"
echo "3. Construction de l'application"
echo "4. Tests automatisés"

# Simuler un test CI
echo ""
echo -e "${YELLOW} Test de validation CI:${NC}"
if conftest test /tmp/critical-demo.json --policy security/policies/security.rego --output json &> /dev/null; then
    echo -e "${GREEN} CI: Validation réussie${NC}"
else
    echo -e "${RED} CI: Validation échouée (vulnérabilité critique détectée)${NC}"
    echo "   → Le pipeline CI bloquerait cette PR"
fi

echo ""
echo -e "${GREEN} Démonstration terminée !${NC}"
echo "====================================="
echo ""
echo " Résumé:"
echo "- Politiques OPA/Rego créées et testées"
echo "- Conftest fonctionne pour validation locale"
echo "- GitHub Actions configuré pour CI/CD"
echo "- Job échoue automatiquement si CVSS ≥ 7"
echo ""
echo " Prochaines étapes:"
echo "1. Pousser du code pour déclencher le CI"
echo "2. Voir les résultats sur GitHub Actions"
echo "3. Ajuster les politiques selon vos besoins"

# Nettoyage
rm -f /tmp/critical-demo.json /tmp/high-demo.json /tmp/safe-demo.json 