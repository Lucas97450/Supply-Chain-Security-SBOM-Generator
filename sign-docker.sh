#!/bin/bash

# Script de signature Docker qui fonctionne localement
echo "Signature Docker locale"
echo "====================="

# Variables
IMAGE_NAME="supply-chain-security"
IMAGE_TAG="latest"
FULL_IMAGE_NAME="${IMAGE_NAME}:${IMAGE_TAG}"

# Nettoyer les anciens fichiers
echo "Nettoyage des anciens fichiers..."
rm -f cosign.key cosign.pub *.sig

# Générer de nouvelles clés
echo "Génération des clés Cosign..."
cosign generate-key-pair

# Signer l'image avec la clé locale
echo "Signature de l'image Docker..."
cosign sign --key cosign.key --force "${FULL_IMAGE_NAME}"

# Vérifier la signature
echo "Vérification de la signature..."
cosign verify --key cosign.pub "${FULL_IMAGE_NAME}"

echo ""
echo "Signature terminée !"
echo "Image signée: ${FULL_IMAGE_NAME}"
echo "Clé publique: cosign.pub"
echo "Clé privée: cosign.key" 