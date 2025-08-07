#!/bin/bash

# Script pour attester le SBOM et la provenance avec Cosign
# Étape 5.3: Attester le SBOM & provenance

echo "Attestation du SBOM et de la provenance avec Cosign..."
echo "====================================================="

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

# Générer des clés si elles n'existent pas
if [ ! -f "cosign.key" ]; then
    echo "Génération d'une paire de clés..."
    cosign generate-key-pair
fi

# Créer un SBOM si il n'existe pas
if [ ! -f "sbom.json" ]; then
    echo "Génération du SBOM..."
    if command -v syft &> /dev/null; then
        syft . -o json > sbom.json
    else
        echo "Syft n'est pas installé. Installation..."
        curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
        syft . -o json > sbom.json
    fi
fi

# Créer un fichier de provenance
echo "Création du fichier de provenance..."
cat > provenance.json << EOF
{
  "buildType": "https://github.com/sigstore/cosign",
  "builder": {
    "id": "github-actions"
  },
  "buildConfig": {
    "steps": [
      {
        "command": ["docker", "build", "-t", "${FULL_IMAGE_NAME}", "."],
        "env": ["DOCKER_BUILDKIT=1"]
      },
      {
        "command": ["syft", ".", "-o", "json"],
        "env": []
      }
    ]
  },
  "metadata": {
    "completeness": {
      "parameters": true,
      "environment": true,
      "materials": true
    },
    "reproducible": false
  },
  "materials": [
    {
      "uri": "git+https://github.com/Lucas97450/Supply-Chain-Security-SBOM-Generator",
      "digest": {
        "sha1": "$(git rev-parse HEAD)"
      }
    }
  ]
}
EOF

echo "Attestation du SBOM..."
cosign attest --key cosign.key --type sbom --predicate sbom.json "${FULL_IMAGE_NAME}"

echo "Attestation de la provenance..."
cosign attest --key cosign.key --type slsaprovenance --predicate provenance.json "${FULL_IMAGE_NAME}"

echo ""
echo "Attestations créées!"
echo "Types d'attestation:"
echo "- SBOM attestation"
echo "- SLSA provenance attestation"

# Vérifier les attestations
echo ""
echo "Vérification des attestations..."
cosign verify-attestation --key cosign.pub "${FULL_IMAGE_NAME}"

echo ""
echo "Attestations disponibles:"
cosign tree "${FULL_IMAGE_NAME}" 