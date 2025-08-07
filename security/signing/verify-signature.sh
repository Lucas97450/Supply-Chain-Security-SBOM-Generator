#!/bin/bash

# Script pour vérifier les signatures avec Cosign
# Étape 5.4: Vérifier la signature en CI

echo "Vérification des signatures avec Cosign..."
echo "========================================="

# Variables
IMAGE_NAME="supply-chain-security"
IMAGE_TAG="latest"
FULL_IMAGE_NAME="${IMAGE_NAME}:${IMAGE_TAG}"

# Vérifier si cosign est installé
if ! command -v cosign &> /dev/null; then
    echo "Cosign n'est pas installé. Installation..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install cosign
    else
        wget -O cosign https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64
        chmod +x cosign
        sudo mv cosign /usr/local/bin/
    fi
fi

echo "Vérification de la signature de l'image..."

# Vérifier si la clé publique existe
if [ -f "cosign.pub" ]; then
    echo "Vérification avec la clé publique locale..."
    cosign verify --key cosign.pub "${FULL_IMAGE_NAME}"
else
    echo "Clé publique non trouvée. Vérification avec la clé publique par défaut..."
    cosign verify "${FULL_IMAGE_NAME}"
fi

echo ""
echo "Vérification des attestations..."

# Vérifier les attestations
if [ -f "cosign.pub" ]; then
    echo "Vérification des attestations avec la clé publique locale..."
    cosign verify-attestation --key cosign.pub "${FULL_IMAGE_NAME}"
else
    echo "Vérification des attestations avec la clé publique par défaut..."
    cosign verify-attestation "${FULL_IMAGE_NAME}"
fi

echo ""
echo "Arbre des signatures et attestations..."
cosign tree "${FULL_IMAGE_NAME}"

echo ""
echo "Vérification terminée!"
echo "Si aucune erreur n'est affichée, l'image est valide et signée." 