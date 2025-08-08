#!/bin/bash

# Script pour signer l'image Docker avec Cosign
# Étape 5.2: Signer l'image

echo "Signature de l'image Docker avec Cosign..."
echo "========================================="

# Variables
IMAGE_NAME="supply-chain-security"
IMAGE_TAG="latest"
FULL_IMAGE_NAME="${IMAGE_NAME}:${IMAGE_TAG}"

# Vérifier si l'image existe
if ! docker images | grep -q "${IMAGE_NAME}"; then
    echo "Construction de l'image Docker..."
    docker build -t "${FULL_IMAGE_NAME}" .
fi

echo "Image à signer: ${FULL_IMAGE_NAME}"

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

# Générer des clés si elles n'existent pas
if [ ! -f "cosign.key" ]; then
    echo "Génération d'une paire de clés..."
    cosign generate-key-pair
fi

# Signer l'image
echo "Signature de l'image avec la clé locale..."
cosign sign --key cosign.key "${FULL_IMAGE_NAME}"

# Vérifier la signature
echo "Vérification de la signature..."
cosign verify --key cosign.pub "${FULL_IMAGE_NAME}"

echo ""
echo "Signature terminée!"
echo "Image signée: ${FULL_IMAGE_NAME}"
echo "Clé publique: cosign.pub"
echo "Clé privée: cosign.key (à garder secrète)"

# Afficher les informations de signature
echo ""
echo "Informations de signature:"
cosign tree "${FULL_IMAGE_NAME}" 