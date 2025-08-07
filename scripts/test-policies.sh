#!/bin/bash

# Script pour tester les politiques de sécurité avec Conftest
# Étape 4.2: Tester avec Conftest

echo " Test des politiques de sécurité avec Conftest..."
echo "=================================================="

# Vérifier si conftest est installé
if ! command -v conftest &> /dev/null; then
    echo " Conftest n'est pas installé. Installation..."
    # Installation de conftest (macOS)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install conftest
    else
        echo "Veuillez installer conftest manuellement: https://www.conftest.dev/install/"
        exit 1
    fi
fi

echo " Conftest installé"

# Test des vulnérabilités
echo ""
echo " Test des vulnérabilités:"
echo "---------------------------"
conftest test test-data/vulnerabilities.json --policy policies/security.rego --output table

# Test avec des données de test spécifiques
echo ""
echo " Test avec données de test critiques:"
echo "----------------------------------------"
cat > /tmp/critical-test.json << EOF
{
  "vulnerabilities": [
    {
      "id": "CVE-2023-9999",
      "name": "Critical Test",
      "cvss_score": 9.8,
      "severity": "CRITICAL"
    }
  ],
  "dependencies": []
}
EOF

conftest test /tmp/critical-test.json --policy policies/security.rego --output table

# Test avec des données sécurisées
echo ""
echo " Test avec données sécurisées:"
echo "-------------------------------"
cat > /tmp/safe-test.json << EOF
{
  "vulnerabilities": [
    {
      "id": "CVE-2023-0001",
      "name": "Low Test",
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

conftest test /tmp/safe-test.json --policy policies/security.rego --output table

echo ""
echo " Résumé des tests:"
echo "==================="
echo "- Les vulnérabilités CVSS ≥ 7 doivent échouer (deny)"
echo "- Les vulnérabilités CVSS ≥ 5 doivent avertir (warn)"
echo "- Les dépendances obsolètes doivent échouer"
echo "- Les licences non autorisées doivent échouer"

# Nettoyage
rm -f /tmp/critical-test.json /tmp/safe-test.json 