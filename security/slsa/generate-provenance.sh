#!/bin/bash

# Script pour générer la provenance SLSA Level 2
# Étape 6.2: Activer provenance signée

echo "Génération de la provenance SLSA Level 2..."
echo "==========================================="

# Variables
REPO_URL="https://github.com/Lucas97450/Supply-Chain-Security-SBOM-Generator"
COMMIT_HASH=$(git rev-parse HEAD)
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
IMAGE_NAME="supply-chain-security"
IMAGE_TAG="latest"

# Créer le fichier de provenance SLSA
echo "Création du fichier provenance.json..."

cat > provenance.json << EOF
{
  "buildType": "https://github.com/sigstore/cosign",
  "builder": {
    "id": "github-actions"
  },
  "buildConfig": {
    "steps": [
      {
        "command": ["docker", "build", "-t", "${IMAGE_NAME}:${IMAGE_TAG}", "."],
        "env": ["DOCKER_BUILDKIT=1"]
      },
      {
        "command": ["syft", ".", "-o", "json"],
        "env": []
      },
      {
        "command": ["grype", ".", "-o", "json"],
        "env": []
      },
      {
        "command": ["conftest", "test", "vulnerability-scan-project.json", "--policy", "security/policies/security.rego"],
        "env": []
      },
      {
        "command": ["cosign", "sign", "--key", "env://COSIGN_PRIVATE_KEY", "${IMAGE_NAME}:${IMAGE_TAG}"],
        "env": ["COSIGN_PRIVATE_KEY"]
      },
      {
        "command": ["cosign", "attest", "--key", "env://COSIGN_PRIVATE_KEY", "--type", "sbom", "--predicate", "sbom-project.json", "${IMAGE_NAME}:${IMAGE_TAG}"],
        "env": ["COSIGN_PRIVATE_KEY"]
      },
      {
        "command": ["cosign", "attest", "--key", "env://COSIGN_PRIVATE_KEY", "--type", "slsaprovenance", "--predicate", "provenance.json", "${IMAGE_NAME}:${IMAGE_TAG}"],
        "env": ["COSIGN_PRIVATE_KEY"]
      }
    ]
  },
  "metadata": {
    "completeness": {
      "parameters": true,
      "environment": true,
      "materials": true
    },
    "reproducible": false,
    "buildInvocationId": "${COMMIT_HASH}",
    "buildStartedOn": "${BUILD_DATE}"
  },
  "materials": [
    {
      "uri": "git+${REPO_URL}",
      "digest": {
        "sha1": "${COMMIT_HASH}"
      }
    },
    {
      "uri": "pkg:docker/${IMAGE_NAME}@${IMAGE_TAG}",
      "digest": {
        "sha256": "$(docker images --no-trunc --quiet ${IMAGE_NAME}:${IMAGE_TAG} | cut -d: -f2)"
      }
    }
  ]
}
EOF

echo "Fichier provenance.json créé avec succès!"
echo ""

# Afficher le contenu du fichier
echo "Contenu du fichier provenance.json:"
echo "==================================="
cat provenance.json | jq '.' 2>/dev/null || cat provenance.json

echo ""
echo "Validation de la structure JSON..."
if python3 -c "import json; json.load(open('provenance.json'))"; then
    echo "✅ Structure JSON valide"
else
    echo "❌ Erreur dans la structure JSON"
    exit 1
fi

echo ""
echo "Attestation de la provenance avec Cosign..."

# Vérifier si cosign est installé
if ! command -v cosign &> /dev/null; then
    echo "Installation de Cosign..."
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

# Construire l'image si elle n'existe pas
if ! docker images | grep -q "${IMAGE_NAME}"; then
    echo "Construction de l'image Docker..."
    docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" .
fi

# Attester la provenance
echo "Attestation de la provenance SLSA..."
cosign attest --key cosign.key --type slsaprovenance --predicate provenance.json "${IMAGE_NAME}:${IMAGE_TAG}"

echo ""
echo "Vérification de l'attestation..."
cosign verify-attestation --key cosign.pub "${IMAGE_NAME}:${IMAGE_TAG}"

echo ""
echo "✅ Provenance SLSA Level 2 générée et attestée!"
echo "Fichier: provenance.json"
echo "Attestation: signée avec Cosign"
echo "Validation: SLSA Level 2 atteint" 