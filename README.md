# Supply-Chain-Security-SBOM-Generator

### 1) Introduction / Contexte

- **But du projet (1–2 phrases)**: Sécuriser la supply chain d’une application FastAPI conteneurisée en automatisant la génération d’un SBOM, l’analyse de vulnérabilités, le blocage des PR à risque, la signature d’image et l’attestation de provenance (SLSA).
- **Ce que ça montre**: Maîtrise CI/CD + DevSecOps avec Syft (SBOM), Grype (CVE), OPA/Conftest (politiques), Cosign (signature/attestations), SLSA Level 2 (provenance), plus des tests de sécurité automatisés.
- **Public**: Recruteurs, équipes sécurité, plateformes DevOps/DevSecOps.

- **Exemple**: “À chaque commit, le pipeline génère un SBOM (Syft), scanne les vulnérabilités (Grype), applique des politiques OPA et des tests de sécurité, bloque les PR à risque, signe l’image (Cosign) et atteste sa provenance au niveau SLSA 2.”


### 2) Architecture / Vue d’ensemble

- **Flux CI/CD (liste rapide)**: push/PR → build image → génération SBOM (Syft) → scan CVE (Grype) → contrôle de politiques (OPA/Conftest, échec si CVSS ≥ 7) → signature + attestation (Cosign) → push vers registre (ex. GHCR) → vérification/validation (SLSA L2).

- **Pourquoi chaque brique**:
  - **Build image**: produit l’image OCI déployable et scannable.
  - **SBOM (Syft)**: inventorie les dépendances pour la traçabilité et l’analyse continue.
  - **Scan CVE (Grype)**: détecte les vulnérabilités connues et calcule les scores CVSS.
  - **OPA/Conftest**: applique des politiques (ex: bloquer si CVSS élevé, dépendances interdites, provenance manquante).
  - **Cosign (signature/attestation)**: garantit l’intégrité et l’authenticité de l’image et atteste le SBOM/provenance.
  - **SLSA L2**: formalise la provenance build (builder, source, matériaux) et ajoute des contrôles de chaîne d’approvisionnement.
  - **Registre (GHCR)**: stockage sécurisé des artefacts signés et attestés.

- **Diagramme**: à insérer ici plus tard (Mermaid/PNG).

- **Mini-lexique**:
  - **Image OCI**: format standard d’image conteneur.
  - **SBOM**: inventaire des composants logiciels d’un artefact.
  - **CVE/CVSS**: identifiant de vulnérabilité et score de sévérité (0–10).
  - **Attestation SLSA**: métadonnées signées décrivant la provenance (qui a construit quoi, quand, avec quels matériaux).

### 3) Mini-app (support)

- **Ce que fait l’app (2–3 endpoints)**:
  - `GET /hello`: renvoie un message simple pour vérifier la disponibilité de l’API.
  - `POST /data`: reçoit un JSON arbitraire et le renvoie tel quel pour simuler une ingestion.

- **Dépendances clés** (versions épinglées dans `mini-fastapi-app/requirements.txt`):
  - `fastapi==0.110.0`: framework web ASGI pour l’API.
  - `uvicorn==0.29.0`: serveur ASGI pour exécuter l’app.
  - `requests==2.31.0`: client HTTP utilisé par les tests/démos.

- **Pourquoi elle sert de support au pipeline**:
  - Fournit des dépendances concrètes → génération de SBOM pertinente (Syft).
  - Produit une image conteneur testable → scan CVE (Grype) et politiques OPA ont du sens.
  - Artefacts simples à signer/attester (Cosign) tout en illustrant la provenance SLSA L2.

- **Snippet d’API** (extrait):

```python
from fastapi import FastAPI, Request

app = FastAPI()

@app.get("/hello")
def say_hello():
    return {"message": "Hello, supply chain world!"}

@app.post("/data")
async def receive_data(request: Request):
    data = await request.json()
    return {"received": data}
```

### 4) Dockerisation (Dockerfile)

- **Base image**: `python:3.12-slim-bookworm` pour une image légère et à jour de Python 3.12 (Debian Bookworm), réduisant la surface d’attaque et la taille.
- **Étapes clés**:
  - `WORKDIR /app`: répertoire de travail standardisé.
  - `COPY requirements.txt .` puis `pip install --no-cache-dir -r requirements.txt`: installation reproductible des dépendances épinglées.
  - `COPY app app`: copie du code applicatif.
  - `CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]`: exécute l’API via Uvicorn.

- **Exécution locale**:

```bash
docker build -t mini-fastapi-app:dev mini-fastapi-app
docker run --rm -p 8000:8000 mini-fastapi-app:dev
```

