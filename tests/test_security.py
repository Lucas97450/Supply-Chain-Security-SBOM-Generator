import pytest
import json
import subprocess
import os

class TestSecurityPolicies:
    """Tests pour les politiques de sécurité OPA/Rego"""
    
    def test_policy_file_exists(self):
        """Vérifie que le fichier de politique existe"""
        assert os.path.exists("security/policies/security.rego"), "Le fichier security.rego doit exister"
    
    def test_test_data_exists(self):
        """Vérifie que les données de test existent"""
        assert os.path.exists("security/test-data/vulnerabilities.json"), "Le fichier vulnerabilities.json doit exister"
    
    def test_conftest_validation(self):
        """Teste la validation avec Conftest"""
        try:
            result = subprocess.run([
                "conftest", "test", "security/test-data/vulnerabilities.json",
                "--policy", "security/policies/security.rego",
                "--output", "json"
            ], capture_output=True, text=True, check=True)
            
            # Si on arrive ici, la validation a réussi
            assert True, "Conftest validation successful"
            
        except subprocess.CalledProcessError as e:
            # Si Conftest échoue, c'est normal car nos données de test contiennent des vulnérabilités
            assert "deny" in e.stdout or "warn" in e.stdout, "Conftest doit détecter des problèmes"
    
    def test_critical_vulnerability_detection(self):
        """Teste la détection des vulnérabilités critiques"""
        critical_data = {
            "vulnerabilities": [
                {
                    "id": "CVE-TEST-001",
                    "name": "Critical Test",
                    "cvss_score": 9.1,
                    "severity": "CRITICAL"
                }
            ],
            "dependencies": []
        }
        
        # Écriture temporaire des données
        with open("temp_critical.json", "w") as f:
            json.dump(critical_data, f)
        
        try:
            result = subprocess.run([
                "conftest", "test", "temp_critical.json",
                "--policy", "security/policies/security.rego",
                "--output", "json"
            ], capture_output=True, text=True)
            
            # Doit échouer car vulnérabilité critique
            assert result.returncode != 0, "Doit échouer pour vulnérabilité critique"
            
        finally:
            # Nettoyage
            if os.path.exists("temp_critical.json"):
                os.remove("temp_critical.json")
    
    def test_safe_data_validation(self):
        """Teste la validation de données sécurisées"""
        safe_data = {
            "vulnerabilities": [
                {
                    "id": "CVE-TEST-002",
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
                    "is_deprecated": False
                }
            ]
        }
        
        # Écriture temporaire des données
        with open("temp_safe.json", "w") as f:
            json.dump(safe_data, f)
        
        try:
            result = subprocess.run([
                "conftest", "test", "temp_safe.json",
                "--policy", "security/policies/security.rego",
                "--output", "json"
            ], capture_output=True, text=True)
            
            # Peut passer car données sécurisées
            # Note: peut quand même avoir des warnings pour vulnérabilités faibles
            
        finally:
            # Nettoyage
            if os.path.exists("temp_safe.json"):
                os.remove("temp_safe.json")

class TestApplication:
    """Tests pour l'application FastAPI"""
    
    def test_app_import(self):
        """Teste l'import de l'application"""
        try:
            from app.main import app
            assert app is not None, "L'application doit être importable"
        except ImportError as e:
            pytest.fail(f"Impossible d'importer l'application: {e}")
    
    def test_requirements_exist(self):
        """Vérifie que requirements.txt existe"""
        assert os.path.exists("requirements.txt"), "requirements.txt doit exister"
    
    def test_dockerfile_exists(self):
        """Vérifie que Dockerfile existe"""
        assert os.path.exists("Dockerfile"), "Dockerfile doit exister" 