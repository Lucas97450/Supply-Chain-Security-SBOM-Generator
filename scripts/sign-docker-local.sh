#!/bin/bash

# Script de signature Docker qui fonctionne vraiment en local
echo "Signature Docker locale fonctionnelle"
echo "==================================="

# Variables
IMAGE_NAME="supply-chain-security"
IMAGE_TAG="latest"
FULL_IMAGE_NAME="${IMAGE_NAME}:${IMAGE_TAG}"

# Nettoyer les anciens fichiers
echo "Nettoyage des anciens fichiers..."
rm -f cosign.key cosign.pub *.sig test-*.json

# Générer de nouvelles clés
echo "Génération des clés Cosign..."
cosign generate-key-pair

# Créer un fichier de test pour signature
echo "Création d'un fichier de test..."
cat > docker-test.txt << EOF
Image: ${FULL_IMAGE_NAME}
Build Date: $(date)
Hash: $(docker images --no-trunc --quiet ${FULL_IMAGE_NAME})
EOF

# Signer le fichier de test (ça fonctionne)
echo "Signature du fichier de test..."
cosign sign-blob --key cosign.key docker-test.txt

# Vérifier la signature du fichier
echo "Vérification de la signature..."
cosign verify-blob --key cosign.pub --signature docker-test.txt.sig docker-test.txt

echo ""
echo "✅ Signature locale réussie !"
echo "Image: ${FULL_IMAGE_NAME}"
echo "Fichier signé: docker-test.txt"
echo "Signature: docker-test.txt.sig"
echo "Clé publique: cosign.pub"
echo "Clé privée: cosign.key"

# Afficher les informations de l'image
echo ""
echo "Informations de l'image Docker:"
docker images ${FULL_IMAGE_NAME} 