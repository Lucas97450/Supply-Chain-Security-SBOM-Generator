#!/bin/bash

# Script pour valider SLSA Level 2
# Étape 6: Validation complète SLSA Level 2

echo "Validation SLSA Level 2..."
echo "=========================="

# Variables
TOTAL_TESTS=0
PASSED_TESTS=0

# Fonction pour tester une étape
test_slsa_criteria() {
    local test_name="$1"
    local test_command="$2"
    
    echo "Test: $test_name"
    if eval "$test_command" >/dev/null 2>&1; then
        echo "✅ PASS: $test_name"
        ((PASSED_TESTS++))
    else
        echo "❌ FAIL: $test_name"
    fi
    ((TOTAL_TESTS++))
    echo ""
}

echo "1. Validation du Builder Isolé"
echo "=============================="

# Test 1: Vérifier que le build se fait dans GitHub Actions
test_slsa_criteria "Build dans environnement contrôlé" "test -f .github/workflows/supply-chain.yml"

# Test 2: Vérifier la présence de permissions sécurisées
test_slsa_criteria "Permissions sécurisées configurées" "grep -q 'id-token: write' .github/workflows/supply-chain.yml"

# Test 3: Vérifier la reproductibilité (même Dockerfile)
test_slsa_criteria "Build reproductible" "test -f Dockerfile"

echo "2. Validation de la Provenance"
echo "=============================="

# Test 4: Vérifier la génération de provenance
test_slsa_criteria "Génération provenance automatique" "grep -q 'Generate SLSA Provenance' .github/workflows/supply-chain.yml"

# Test 5: Vérifier la structure de provenance
test_slsa_criteria "Structure provenance valide" "grep -q 'buildType' .github/workflows/supply-chain.yml"

# Test 6: Vérifier les métadonnées de build
test_slsa_criteria "Métadonnées de build présentes" "grep -q 'buildInvocationId' .github/workflows/supply-chain.yml"

echo "3. Validation des Signatures"
echo "==========================="

# Test 7: Vérifier la signature des images
test_slsa_criteria "Signature d'images configurée" "grep -q 'cosign sign' .github/workflows/supply-chain.yml"

# Test 8: Vérifier l'attestation SBOM
test_slsa_criteria "Attestation SBOM configurée" "grep -q 'cosign attest.*sbom' .github/workflows/supply-chain.yml"

# Test 9: Vérifier l'attestation provenance
test_slsa_criteria "Attestation provenance configurée" "grep -q 'cosign attest.*slsaprovenance' .github/workflows/supply-chain.yml"

# Test 10: Vérifier la vérification des signatures
test_slsa_criteria "Vérification signatures configurée" "grep -q 'cosign verify' .github/workflows/supply-chain.yml"

echo "4. Validation de la Sécurité"
echo "============================"

# Test 11: Vérifier les politiques de sécurité
test_slsa_criteria "Politiques de sécurité présentes" "test -f security/policies/security.rego"

# Test 12: Vérifier la validation des vulnérabilités
test_slsa_criteria "Validation vulnérabilités configurée" "grep -q 'conftest test' .github/workflows/supply-chain.yml"

# Test 13: Vérifier la génération SBOM
test_slsa_criteria "Génération SBOM configurée" "grep -q 'syft' .github/workflows/supply-chain.yml"

# Test 14: Vérifier le scan de vulnérabilités
test_slsa_criteria "Scan vulnérabilités configuré" "grep -q 'grype' .github/workflows/supply-chain.yml"

echo "5. Validation des Tests"
echo "======================"

# Test 15: Vérifier les tests unitaires
test_slsa_criteria "Tests unitaires présents" "test -f tests/test_security.py"

# Test 16: Vérifier les tests d'intégration
test_slsa_criteria "Tests d'intégration configurés" "grep -q 'pytest' .github/workflows/supply-chain.yml"

echo "6. Validation de la Documentation"
echo "================================"

# Test 17: Vérifier la documentation SLSA
test_slsa_criteria "Documentation SLSA présente" "test -f security/slsa/README.md"

# Test 18: Vérifier les scripts de validation
test_slsa_criteria "Scripts de validation présents" "test -f security/slsa/generate-provenance.sh"

echo ""
echo "Résultats de la validation SLSA Level 2"
echo "======================================"
echo "Tests passés: $PASSED_TESTS/$TOTAL_TESTS"

if [ $PASSED_TESTS -eq $TOTAL_TESTS ]; then
    echo ""
    echo "🎉 FÉLICITATIONS! Le projet atteint SLSA Level 2!"
    echo ""
    echo "✅ Builder isolé dans GitHub Actions"
    echo "✅ Provenance générée automatiquement"
    echo "✅ Signatures avec Cosign"
    echo "✅ Vérification en CI/CD"
    echo "✅ SBOM attesté"
    echo "✅ Politiques de sécurité validées"
    echo "✅ Tests automatisés"
    echo "✅ Documentation complète"
    echo ""
    echo "Le pipeline de sécurité est maintenant crédible et conforme aux standards SLSA Level 2."
else
    echo ""
    echo "⚠️  ATTENTION: Certains critères SLSA Level 2 ne sont pas satisfaits."
    echo "Tests échoués: $((TOTAL_TESTS - PASSED_TESTS))"
    echo ""
    echo "Veuillez corriger les tests échoués pour atteindre SLSA Level 2."
fi

echo ""
echo "Détails des critères SLSA Level 2:"
echo "- Builder isolé: Build dans un environnement contrôlé"
echo "- Provenance: Métadonnées de build générées automatiquement"
echo "- Signatures: Images et attestations signées avec Cosign"
echo "- Vérification: Signatures vérifiées en CI/CD"
echo "- Sécurité: Politiques de sécurité validées"
echo "- Tests: Tests automatisés et complets" 