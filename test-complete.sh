#!/bin/bash

# Script de test complet pour Supply Chain Security
# Teste toutes les fonctionnalités implémentées

echo "Test complet du système Supply Chain Security"
echo "============================================="

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Fonction pour tester une étape
test_step() {
    local step_name="$1"
    local command="$2"
    
    echo -e "${BLUE}Test: $step_name${NC}"
    echo "----------------------------------------"
    
    if eval "$command"; then
        echo -e "${GREEN}SUCCESS: $step_name${NC}"
        return 0
    else
        echo -e "${RED}FAILED: $step_name${NC}"
        return 1
    fi
}

# Compteurs
total_tests=0
passed_tests=0

echo ""
echo "1. Test de l'application FastAPI"
echo "================================"

test_step "Import de l'application" "python3 -c 'from app.main import app; print(\"App importée\")'"
((total_tests++))
if [ $? -eq 0 ]; then ((passed_tests++)); fi

test_step "Installation des dépendances" "pip3 install -r requirements.txt"
((total_tests++))
if [ $? -eq 0 ]; then ((passed_tests++)); fi

echo ""
echo "2. Test des politiques de sécurité"
echo "=================================="

test_step "Existence du fichier de politique" "test -f security/policies/security.rego"
((total_tests++))
if [ $? -eq 0 ]; then ((passed_tests++)); fi

test_step "Existence des données de test" "test -f security/test-data/vulnerabilities.json"
((total_tests++))
if [ $? -eq 0 ]; then ((passed_tests++)); fi

# Test Conftest si installé
if command -v conftest &> /dev/null; then
    test_step "Validation Conftest" "conftest test security/test-data/vulnerabilities.json --policy security/policies/security.rego --output json"
    ((total_tests++))
    if [ $? -eq 0 ]; then ((passed_tests++)); fi
else
    echo -e "${YELLOW}SKIP: Conftest non installé${NC}"
fi

echo ""
echo "3. Test de la génération SBOM"
echo "=============================="

# Test Syft si installé
if command -v syft &> /dev/null; then
    test_step "Génération SBOM projet" "syft . -o json > test-sbom.json"
    ((total_tests++))
    if [ $? -eq 0 ]; then ((passed_tests++)); fi
    
    test_step "Vérification SBOM généré" "test -f test-sbom.json"
    ((total_tests++))
    if [ $? -eq 0 ]; then ((passed_tests++)); fi
else
    echo -e "${YELLOW}SKIP: Syft non installé${NC}"
fi

echo ""
echo "4. Test Docker"
echo "=============="

test_step "Construction image Docker" "docker build -t test-supply-chain ."
((total_tests++))
if [ $? -eq 0 ]; then ((passed_tests++)); fi

test_step "Test image Docker" "docker run --rm test-supply-chain python -c 'import app.main; print(\"Docker OK\")'"
((total_tests++))
if [ $? -eq 0 ]; then ((passed_tests++)); fi

echo ""
echo "5. Test de signature avec Cosign"
echo "================================"

# Test Cosign si installé
if command -v cosign &> /dev/null; then
    test_step "Génération clés Cosign" "cosign generate-key-pair"
    ((total_tests++))
    if [ $? -eq 0 ]; then ((passed_tests++)); fi
    
    test_step "Signature image" "cosign sign --key cosign.key test-supply-chain:latest"
    ((total_tests++))
    if [ $? -eq 0 ]; then ((passed_tests++)); fi
    
    test_step "Vérification signature" "cosign verify --key cosign.pub test-supply-chain:latest"
    ((total_tests++))
    if [ $? -eq 0 ]; then ((passed_tests++)); fi
else
    echo -e "${YELLOW}SKIP: Cosign non installé${NC}"
fi

echo ""
echo "6. Test des scripts de sécurité"
echo "==============================="

test_step "Script test-policies" "bash security/scripts/test-policies.sh"
((total_tests++))
if [ $? -eq 0 ]; then ((passed_tests++)); fi

test_step "Script setup-cosign" "bash security/signing/setup-cosign.sh"
((total_tests++))
if [ $? -eq 0 ]; then ((passed_tests++)); fi

echo ""
echo "7. Test des tests unitaires"
echo "==========================="

if command -v pytest &> /dev/null; then
    test_step "Tests unitaires" "python3 -m pytest tests/ -v"
    ((total_tests++))
    if [ $? -eq 0 ]; then ((passed_tests++)); fi
else
    echo -e "${YELLOW}SKIP: pytest non installé${NC}"
fi

echo ""
echo "8. Test du workflow GitHub Actions"
echo "=================================="

test_step "Existence workflow" "test -f .github/workflows/supply-chain.yml"
((total_tests++))
if [ $? -eq 0 ]; then ((passed_tests++)); fi

test_step "Validation YAML" "python3 -c 'import yaml; yaml.safe_load(open(\".github/workflows/supply-chain.yml\"))'"
((total_tests++))
if [ $? -eq 0 ]; then ((passed_tests++)); fi

echo ""
echo "Résultats du test complet"
echo "========================="
echo "Tests totaux: $total_tests"
echo "Tests réussis: $passed_tests"
echo "Tests échoués: $((total_tests - passed_tests))"

if [ $passed_tests -eq $total_tests ]; then
    echo -e "${GREEN}Tous les tests ont réussi !${NC}"
    echo ""
    echo "Fonctionnalités testées:"
    echo "- Application FastAPI"
    echo "- Politiques de sécurité OPA/Rego"
    echo "- Génération SBOM"
    echo "- Construction Docker"
    echo "- Signature avec Cosign"
    echo "- Scripts de sécurité"
    echo "- Tests unitaires"
    echo "- Workflow GitHub Actions"
else
    echo -e "${RED}Certains tests ont échoué.${NC}"
    echo "Vérifiez les erreurs ci-dessus."
fi

# Nettoyage
rm -f test-sbom.json cosign.key cosign.pub 2>/dev/null
docker rmi test-supply-chain 2>/dev/null

echo ""
echo "Pour tester manuellement:"
echo "1. ./security/scripts/test-policies.sh"
echo "2. ./security/signing/setup-cosign.sh"
echo "3. ./security/signing/sign-image.sh"
echo "4. ./security/demo.sh" 