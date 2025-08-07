package supply_chain.security

# Règle principale : échoue si une vulnérabilité a un CVSS >= 7
deny contains msg if {
    vuln := input.vulnerabilities[_]
    vuln.cvss_score >= 7
    msg := sprintf("Vulnérabilité critique détectée: %s (CVSS: %v)", [vuln.id, vuln.cvss_score])
}

# Règle pour les vulnérabilités élevées (CVSS >= 5)
warn contains msg if {
    vuln := input.vulnerabilities[_]
    vuln.cvss_score >= 5
    vuln.cvss_score < 7
    msg := sprintf("Vulnérabilité élevée détectée: %s (CVSS: %v)", [vuln.id, vuln.cvss_score])
}

# Règle pour les dépendances obsolètes
deny contains msg if {
    dep := input.dependencies[_]
    dep.is_deprecated == true
    msg := sprintf("Dépendance obsolète détectée: %s", [dep.name])
}

# Règle pour les licences non autorisées
deny contains msg if {
    dep := input.dependencies[_]
    not allowed_license(dep.license)
    msg := sprintf("Licence non autorisée: %s (%s)", [dep.name, dep.license])
}

# Licences autorisées
allowed_license(license) if {
    license == "MIT"
}

allowed_license(license) if {
    license == "Apache-2.0"
}

allowed_license(license) if {
    license == "BSD-3-Clause"
}

allowed_license(license) if {
    license == "ISC"
} 