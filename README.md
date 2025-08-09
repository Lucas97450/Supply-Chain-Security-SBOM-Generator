# Supply-Chain-Security-SBOM-Generator

### 1) Introduction / Contexte

- **But du projet (1–2 phrases)**: Sécuriser la supply chain d’une application FastAPI conteneurisée en automatisant la génération d’un SBOM, l’analyse de vulnérabilités, le blocage des PR à risque, la signature d’image et l’attestation de provenance (SLSA).
- **Ce que ça montre**: Maîtrise CI/CD + DevSecOps avec Syft (SBOM), Grype (CVE), OPA/Conftest (politiques), Cosign (signature/attestations), SLSA Level 2 (provenance), plus des tests de sécurité automatisés.
- **Public**: Recruteurs, équipes sécurité, plateformes DevOps/DevSecOps.

- **Exemple**: “À chaque commit, le pipeline génère un SBOM (Syft), scanne les vulnérabilités (Grype), applique des politiques OPA et des tests de sécurité, bloque les PR à risque, signe l’image (Cosign) et atteste sa provenance au niveau SLSA 2.”

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

- **Dépendances clés** (versions épinglées dans `requirements.txt`):
  - `fastapi==0.110.0`
  - `uvicorn==0.29.0`
  - `requests==2.31.0`

- **Pourquoi elle sert de support au pipeline**:
  - Dépendances concrètes → SBOM pertinent (Syft).
  - Image conteneur testable → scan CVE (Grype) et politiques OPA.
  - Artefacts simples à signer/attester (Cosign) illustrant SLSA L2.

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

- Base: `python:3.12-slim-bookworm`
- Étapes: `WORKDIR /app` → copier `requirements.txt` → `pip install` → copier `app` → `CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]`.
- Exécution locale:

```bash
docker build -t mini-fastapi-app:dev .
docker run --rm -p 8000:8000 mini-fastapi-app:dev
```

### 5) CI (Intégration Continue)

- Workflow: `.github/workflows/supply-chain.yml`
- Triggers: `push`, `pull_request`
- Secrets/OIDC: `GHCR_TOKEN`, `COSIGN_KEY`/`COSIGN_PASSWORD` ou OIDC
- Chaîne de jobs: build → sbom (Syft) → scan (Grype) → policy (Conftest/OPA) → sign/attest (Cosign) → push (GHCR) → verify

### 6) SBOM avec Syft

- Pourquoi: inventaire des composants, traçabilité, conformité
- Format: CycloneDX JSON
- Commande:

```bash
syft packages docker:<image_tag> -o cyclonedx-json > sbom.json
```

- Emplacement: artefacts CI ou `artifacts/sbom/sbom.json`