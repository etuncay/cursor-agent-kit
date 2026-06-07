---
name: "senior-secops"
description: Senior SecOps engineer skill for application security, vulnerability management, compliance verification, and secure development practices. Runs SAST/DAST scans, generates CVE remediation plans, checks dependency vulnerabilities, creates security policies, enforces secure coding patterns, and automates compliance checks against SOC2, PCI-DSS, HIPAA, and GDPR. Use when conducting a security review or audit, responding to a CVE or security incident, hardening infrastructure, implementing authentication or secrets management, running penetration test prep, checking OWASP Top 10 exposure, or enforcing security controls in CI/CD pipelines.
---

# Senior SecOps Engineer

Complete toolkit for Security Operations including vulnerability management, compliance verification, secure coding practices, and security automation.

---

## Table of Contents

- [Core Capabilities](#core-capabilities)
- [Workflows](#workflows)
- [Tool Reference](#tool-reference)
- [Security Standards](#security-standards)
- [Compliance Frameworks](#compliance-frameworks)
- [Best Practices](#best-practices)

---

## Core Capabilities

### 1. Security Scanner

Scan source code for security vulnerabilities including hardcoded secrets, SQL injection, XSS, command injection, and path traversal.

```bash
# SAST (code) — secrets, SQLi, XSS, command injection, path traversal
semgrep --config p/owasp-top-ten --config p/secrets .

# Secrets only
gitleaks detect --source . --redact

# Language-focused linters
bandit -r .                      # Python
npx eslint --plugin security .   # JavaScript/TypeScript
```

**Detects:**
- Hardcoded secrets (API keys, passwords, AWS credentials, GitHub tokens, private keys)
- SQL injection patterns (string concatenation, f-strings, template literals)
- XSS vulnerabilities (innerHTML assignment, unsafe DOM manipulation, React unsafe patterns)
- Command injection (shell=True, exec, eval with user input)
- Path traversal (file operations with user input)

### 2. Vulnerability Assessor

Scan dependencies for known CVEs across npm, Python, and Go ecosystems.

```bash
# Dependency CVEs (multi-ecosystem)
osv-scanner -r .

# Ecosystem-native
npm audit --audit-level=high   # npm/pnpm/yarn
pip-audit                      # Python
govulncheck ./...              # Go

# Container / filesystem scan
trivy fs .
```

**Scans:**
- `package.json` and `package-lock.json` (npm)
- `requirements.txt` and `pyproject.toml` (Python)
- `go.mod` (Go)

**Output:**
- CVE IDs with CVSS scores
- Affected package versions
- Fixed versions for remediation
- Overall risk score (0-100)

### 3. Compliance Checker

Verify security compliance against SOC 2, PCI-DSS, HIPAA, and GDPR frameworks.

```bash
# Infra/config misconfiguration (maps to many SOC2/PCI controls)
checkov -d .
trivy config .

# Cloud posture (if applicable)
prowler aws
```

Framework control verification (SOC 2 / PCI-DSS / HIPAA / GDPR) is largely evidence-based: work through the control mappings in [Compliance Frameworks](#compliance-frameworks) and record pass/gap per control.

**Verifies:**
- Access control implementation
- Encryption at rest and in transit
- Audit logging
- Authentication strength (MFA, password hashing)
- Security documentation
- CI/CD security controls

---

## Workflows

### Workflow 1: Security Audit

Complete security assessment of a codebase.

```bash
# Step 1: SAST — code vulnerabilities
semgrep --config p/owasp-top-ten --config p/secrets .
gitleaks detect --source . --redact
# STOP on any critical finding — resolve before continuing
```

```bash
# Step 2: Dependency vulnerabilities
osv-scanner -r .
# STOP on critical/high CVE — patch before continuing
```

```bash
# Step 3: Config / IaC misconfiguration
checkov -d .
trivy config .
# Then verify framework controls against the mappings below
```

```bash
# Step 4: Machine-readable reports for CI artifacts
semgrep --json -o security.json --config p/owasp-top-ten .
osv-scanner --format json -r . > vulns.json
trivy config --format json -o config.json .
```

### Workflow 2: CI/CD Security Gate

Integrate security checks into deployment pipeline.

```yaml
# .github/workflows/security.yml
name: "security-scan"

on:
  pull_request:
    branches: [main, develop]

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: "set-up-python"
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: "sast"
        uses: returntocorp/semgrep-action@v1
        with:
          config: p/owasp-top-ten

      - name: "secrets"
        uses: gitleaks/gitleaks-action@v2

      - name: "dependency-scan"
        run: |
          curl -sSfL https://raw.githubusercontent.com/google/osv-scanner/main/install.sh | sh -s -- -b /usr/local/bin
          osv-scanner -r .
```

Each step fails the pipeline on its respective exit code — no deployment proceeds past a critical finding.

### Workflow 3: CVE Triage

Respond to a new CVE affecting your application.

```
1. ASSESS (0-2 hours)
   - Identify affected systems with `osv-scanner` / `npm audit` / `pip-audit`
   - Check if CVE is being actively exploited
   - Determine CVSS environmental score for your context
   - STOP if CVSS 9.0+ on internet-facing system — escalate immediately

2. PRIORITIZE
   - Critical (CVSS 9.0+, internet-facing): 24 hours
   - High (CVSS 7.0-8.9): 7 days
   - Medium (CVSS 4.0-6.9): 30 days
   - Low (CVSS < 4.0): 90 days

3. REMEDIATE
   - Update affected dependency to fixed version
   - Re-scan to verify the fix (no remaining critical findings)
   - STOP if the scanner still flags the CVE — do not deploy
   - Test for regressions
   - Deploy with enhanced monitoring

4. VERIFY
   - Re-run the dependency scanner (`osv-scanner` / ecosystem audit)
   - Confirm CVE no longer reported
   - Document remediation actions
```

### Workflow 4: Incident Response

Security incident handling procedure.

```
PHASE 1: DETECT & IDENTIFY (0-15 min)
- Alert received and acknowledged
- Initial severity assessment (SEV-1 to SEV-4)
- Incident commander assigned
- Communication channel established

PHASE 2: CONTAIN (15-60 min)
- Affected systems identified
- Network isolation if needed
- Credentials rotated if compromised
- Preserve evidence (logs, memory dumps)

PHASE 3: ERADICATE (1-4 hours)
- Root cause identified
- Malware/backdoors removed
- Vulnerabilities patched (re-scan shows no critical findings)
- Systems hardened

PHASE 4: RECOVER (4-24 hours)
- Systems restored from clean backup
- Services brought back online
- Enhanced monitoring enabled
- User access restored

PHASE 5: POST-INCIDENT (24-72 hours)
- Incident timeline documented
- Root cause analysis complete
- Lessons learned documented
- Preventive measures implemented
- Stakeholder report delivered
```

---

## Tool Reference

| Purpose | Recommended tools |
|---------|-------------------|
| SAST (code) | `semgrep` (`p/owasp-top-ten`, `p/secrets`), `bandit` (Py), `eslint-plugin-security` (JS) |
| Secrets | `gitleaks`, `detect-secrets`, `trufflehog` |
| Dependency CVEs | `osv-scanner`, `npm audit`, `pip-audit`, `govulncheck`, `trivy fs` |
| IaC / config | `checkov`, `trivy config`, `tfsec` |
| Cloud posture | `prowler`, `scoutsuite` |
| SBOM / signing | `syft`, `grype`, `cosign` |

Gate builds on tool exit codes: non-zero on high/critical → fail the job. Treat any critical finding as a hard STOP before deploy.

---

## Security Standards

See the [OWASP Top 10](https://owasp.org/www-project-top-ten/) and [ASVS](https://owasp.org/www-project-application-security-verification-standard/) for full guidance on secure coding, authentication, and API security controls.

### Secure Coding Checklist

```markdown
## Input Validation
- [ ] Validate all input on server side
- [ ] Use allowlists over denylists
- [ ] Sanitize for specific context (HTML, SQL, shell)

## Output Encoding
- [ ] HTML encode for browser output
- [ ] URL encode for URLs
- [ ] JavaScript encode for script contexts

## Authentication
- [ ] Use bcrypt/argon2 for passwords
- [ ] Implement MFA for sensitive operations
- [ ] Enforce strong password policy

## Session Management
- [ ] Generate secure random session IDs
- [ ] Set HttpOnly, Secure, SameSite flags
- [ ] Implement session timeout (15 min idle)

## Error Handling
- [ ] Log errors with context (no secrets)
- [ ] Return generic messages to users
- [ ] Never expose stack traces in production

## Secrets Management
- [ ] Use environment variables or secrets manager
- [ ] Never commit secrets to version control
- [ ] Rotate credentials regularly
```

---

## Compliance Frameworks

Compliance is evidence-based: work through the control mappings below and record pass/gap per control. Use `checkov` / `trivy config` / `prowler` for the technical controls.

### SOC 2 Type II
- **CC6** Logical Access: authentication, authorization, MFA
- **CC7** System Operations: monitoring, logging, incident response
- **CC8** Change Management: CI/CD, code review, deployment controls

### PCI-DSS v4.0
- **Req 3/4**: Encryption at rest and in transit (TLS 1.2+)
- **Req 6**: Secure development (input validation, secure coding)
- **Req 8**: Strong authentication (MFA, password policy)
- **Req 10/11**: Audit logging, SAST/DAST/penetration testing

### HIPAA Security Rule
- Unique user IDs and audit trails for PHI access (164.312(a)(1), 164.312(b))
- MFA for person/entity authentication (164.312(d))
- Transmission encryption via TLS (164.312(e)(1))

### GDPR
- **Art 25/32**: Privacy by design, encryption, pseudonymization
- **Art 33**: Breach notification within 72 hours
- **Art 17/20**: Right to erasure and data portability

---

## Best Practices

### Secrets Management

```python
# BAD: Hardcoded secret
API_KEY = "sk-1234567890abcdef"

# GOOD: Environment variable
import os
API_KEY = os.environ.get("API_KEY")

# BETTER: Secrets manager
from your_vault_client import get_secret
API_KEY = get_secret("api/key")
```

### SQL Injection Prevention

```python
# BAD: String concatenation
query = f"SELECT * FROM users WHERE id = {user_id}"

# GOOD: Parameterized query
cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))
```

### XSS Prevention

```javascript
// BAD: Direct innerHTML assignment is vulnerable
// GOOD: Use textContent (auto-escaped)
element.textContent = userInput;

// GOOD: Use sanitization library for HTML
import DOMPurify from 'dompurify';
const safeHTML = DOMPurify.sanitize(userInput);
```

### Authentication

```javascript
// Password hashing
const bcrypt = require('bcrypt');
const SALT_ROUNDS = 12;

// Hash password
const hash = await bcrypt.hash(password, SALT_ROUNDS);

// Verify password
const match = await bcrypt.compare(password, hash);
```

### Security Headers

```javascript
// Express.js security headers
const helmet = require('helmet');
app.use(helmet());

// Or manually set headers:
app.use((req, res, next) => {
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('X-XSS-Protection', '1; mode=block');
  res.setHeader('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
  res.setHeader('Content-Security-Policy', "default-src 'self'");
  next();
});
```

---

## OWASP Top 10 Quick-Check

Rapid 15-minute assessment — run through each category and note pass/fail. For deep-dive testing, run a dedicated penetration-testing pass following the OWASP Testing Guide.

| # | Category | One-Line Check |
|---|----------|----------------|
| A01 | Broken Access Control | Verify role checks on every endpoint; test horizontal privilege escalation |
| A02 | Cryptographic Failures | Confirm TLS 1.2+ everywhere; no secrets in logs or source |
| A03 | Injection | Run parameterized query audit; check ORM raw-query usage |
| A04 | Insecure Design | Review threat model exists for critical flows |
| A05 | Security Misconfiguration | Check default credentials removed; error pages generic |
| A06 | Vulnerable Components | Run `osv-scanner`; zero critical/high CVEs |
| A07 | Auth Failures | Verify MFA on admin; brute-force protection active |
| A08 | Software & Data Integrity | Confirm CI/CD pipeline signs artifacts; no unsigned deps |
| A09 | Logging & Monitoring | Validate audit logs capture auth events; alerts configured |
| A10 | SSRF | Test internal URL filters; block metadata endpoints (169.254.169.254) |

> **Deep dive needed?** Run a full penetration test using the [OWASP Web Security Testing Guide](https://owasp.org/www-project-web-security-testing-guide/).

---

## Secret Scanning Tools

Choose the right scanner for each stage of your workflow:

| Tool | Best For | Language | Pre-commit | CI/CD | Custom Rules |
|------|----------|----------|:----------:|:-----:|:------------:|
| **gitleaks** | CI pipelines, full-repo scans | Go | Yes | Yes | TOML regexes |
| **detect-secrets** | Pre-commit hooks, incremental | Python | Yes | Partial | Plugin-based |
| **truffleHog** | Deep history scans, entropy | Go | No | Yes | Regex + entropy |

**Recommended setup:** Use `detect-secrets` as a pre-commit hook (catches secrets before they enter history) and `gitleaks` in CI (catches anything that slips through).

```bash
# detect-secrets pre-commit hook (.pre-commit-config.yaml)
- repo: https://github.com/Yelp/detect-secrets
  rev: v1.4.0
  hooks:
    - id: detect-secrets
      args: ['--baseline', '.secrets.baseline']

# gitleaks in GitHub Actions
- name: gitleaks
  uses: gitleaks/gitleaks-action@v2
  env:
    GITLEAKS_LICENSE: ${{ secrets.GITLEAKS_LICENSE }}
```

---

## Supply Chain Security

Protect against dependency and artifact tampering with SBOM generation, artifact signing, and SLSA compliance.

**SBOM Generation:**
- **syft** — generates SBOMs from container images or source dirs (SPDX, CycloneDX formats)
- **cyclonedx-cli** — CycloneDX-native tooling; merge multiple SBOMs for mono-repos

```bash
# Generate SBOM from container image
syft packages ghcr.io/org/app:latest -o cyclonedx-json > sbom.json
```

**Artifact Signing (Sigstore/cosign):**
```bash
# Sign a container image (keyless via OIDC)
cosign sign ghcr.io/org/app:latest
# Verify signature
cosign verify ghcr.io/org/app:latest --certificate-identity=ci@org.com --certificate-oidc-issuer=https://token.actions.githubusercontent.com
```

**SLSA Levels Overview:**
| Level | Requirement | What It Proves |
|-------|-------------|----------------|
| 1 | Build process documented | Provenance exists |
| 2 | Hosted build service, signed provenance | Tamper-resistant provenance |
| 3 | Hardened build platform, non-falsifiable provenance | Tamper-proof build |
| 4 | Two-party review, hermetic builds | Maximum supply-chain assurance |

> **Cross-references:** `dependency-auditor` (license and CVE audit for dependencies).

---

## Reference Documentation

| Topic | Source |
|-------|--------|
| OWASP Top 10 / secure coding | https://owasp.org/www-project-top-ten/ · https://cheatsheetseries.owasp.org |
| CVE triage / CVSS scoring | https://www.first.org/cvss/ · https://osv.dev |
| Compliance control mappings | SOC 2 (AICPA TSC), PCI-DSS v4.0, HIPAA Security Rule, GDPR official texts |
