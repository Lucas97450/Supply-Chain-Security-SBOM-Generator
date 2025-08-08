#!/bin/bash

# Script pour installer et configurer Cosign
# Étape 5.1: Comprendre Sigstore / Cosign

echo "Installation et configuration de Cosign..."
echo "========================================"

# Vérifier si cosign est installé
if ! command -v cosign &> /dev/null; then
    echo "Installation de Cosign..."
    
    # Installation de Cosign
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        brew install cosign
    else
        # Linux
        wget -O cosign https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64
        chmod +x cosign
        sudo mv cosign /usr/local/bin/
    fi
fi

echo "Cosign version:"
cosign version

echo ""
echo "Configuration des clés..."

# Générer une paire de clés locale pour les tests
echo "Génération d'une paire de clés locale..."
cosign generate-key-pair

# Configuration OIDC pour GitHub Actions
echo ""
echo "Configuration OIDC pour GitHub Actions..."
echo "Pour utiliser OIDC dans GitHub Actions, ajoutez ces permissions:"
echo ""
echo "permissions:"
echo "  id-token: write"
echo "  contents: write"
echo ""

# Afficher les informations de configuration
echo "Configuration terminée!"
echo "Clés générées:"
echo "- cosign.key (clé privée - à garder secrète)"
echo "- cosign.pub (clé publique - à partager)"
echo ""
echo "Pour utiliser OIDC dans CI:"
echo "cosign sign --key env://COSIGN_PRIVATE_KEY"
echo "cosign verify --key env://COSIGN_PUBLIC_KEY" 