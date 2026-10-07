#!/bin/bash
set -e

REPORT_DIR="security-reports"
mkdir -p "$REPORT_DIR"

# ---------- 1. OWASP Dependency-Check (deja HTML) ----------
if [ -f dependency-check-report.html ]; then
    cp dependency-check-report.html "$REPORT_DIR/dependency-check.html"
fi

# ---------- 2. Docker Bench Security (log texte -> HTML) ----------
DB_LOG="/tmp/docker-bench-${BUILD_NUMBER}.log"
if [ -f "$DB_LOG" ]; then
    {
      echo "<html><head><meta charset='utf-8'><title>Docker Bench Security</title>"
      echo "<style>body{font-family:monospace;background:#0d1117;color:#c9d1d9;padding:20px;white-space:pre-wrap;font-size:13px}"
      echo "h1{font-family:Arial,sans-serif;color:#58a6ff}</style></head><body>"
      echo "<h1>Docker Bench Security - build #${BUILD_NUMBER}</h1><pre>"
      sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' "$DB_LOG" | sed -r 's/\x1B\[[0-9;]*[a-zA-Z]//g'
      echo "</pre></body></html>"
    } > "$REPORT_DIR/docker-bench.html"
fi

# ---------- 3. SonarQube (lien + resume via API) ----------
SONAR_URL="http://localhost:9000"
SONAR_SUMMARY=$(curl -s "${SONAR_URL}/api/measures/component?component=timesheet-devops&metricKeys=bugs,vulnerabilities,code_smells,security_hotspots" || echo "{}")
{
  echo "<html><head><meta charset='utf-8'><title>SonarQube</title>"
  echo "<style>body{font-family:Arial,sans-serif;background:#0d1117;color:#c9d1d9;padding:20px}"
  echo "h1{color:#58a6ff} a{color:#58a6ff} pre{background:#161b22;padding:15px;border-radius:8px;overflow:auto}</style></head><body>"
  echo "<h1>SonarQube - timesheet-devops</h1>"
  echo "<p>Dashboard complet : <a href='${SONAR_URL}/dashboard?id=timesheet-devops' target='_blank'>${SONAR_URL}/dashboard?id=timesheet-devops</a></p>"
  echo "<h3>Resume des mesures (API SonarQube)</h3>"
  echo "<pre>${SONAR_SUMMARY}</pre>"
  echo "</body></html>"
} > "$REPORT_DIR/sonarqube.html"

# ---------- 4. Trivy (texte -> HTML) ----------
if [ -f trivy-report.txt ]; then
    {
      echo "<html><head><meta charset='utf-8'><title>Trivy Image Scan</title>"
      echo "<style>body{font-family:monospace;background:#0d1117;color:#c9d1d9;padding:20px;white-space:pre-wrap;font-size:12px}"
      echo "h1{font-family:Arial,sans-serif;color:#58a6ff}</style></head><body>"
      echo "<h1>Trivy Image Scan - ${DOCKER_IMAGE}:${IMAGE_TAG}</h1><pre>"
      sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' trivy-report.txt
      echo "</pre></body></html>"
    } > "$REPORT_DIR/trivy.html"
fi

# ---------- 5. OWASP ZAP (deja HTML) ----------
if [ -f zap-output/zap-report.html ]; then
    cp zap-output/zap-report.html "$REPORT_DIR/zap.html"
fi

# ---------- 6. Gauntlt (capture de la console) ----------
if [ -f gauntlt-output.txt ]; then
    {
      echo "<html><head><meta charset='utf-8'><title>Gauntlt</title>"
      echo "<style>body{font-family:monospace;background:#0d1117;color:#c9d1d9;padding:20px;white-space:pre-wrap;font-size:13px}"
      echo "h1{font-family:Arial,sans-serif;color:#58a6ff}</style></head><body>"
      echo "<h1>Gauntlt Security Acceptance Test</h1><pre>"
      sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' gauntlt-output.txt
      echo "</pre></body></html>"
    } > "$REPORT_DIR/gauntlt.html"
fi

# ---------- 7. Lynis (log texte -> HTML) ----------
LYNIS_LOG="lynis-output/lynis-${BUILD_NUMBER}.log"
if [ -f "$LYNIS_LOG" ]; then
    {
      echo "<html><head><meta charset='utf-8'><title>Lynis Security Audit</title>"
      echo "<style>body{font-family:monospace;background:#0d1117;color:#c9d1d9;padding:20px;white-space:pre-wrap;font-size:12px}"
      echo "h1{font-family:Arial,sans-serif;color:#58a6ff}</style></head><body>"
      echo "<h1>Lynis Security Audit - build #${BUILD_NUMBER}</h1><pre>"
      sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' "$LYNIS_LOG"
      echo "</pre></body></html>"
    } > "$REPORT_DIR/lynis.html"
fi

# ---------- 8. Page portail index.html ----------
cat > "$REPORT_DIR/index.html" << HTMLEOF
<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="utf-8">
<title>DevSecOps Security Reports - Build #${BUILD_NUMBER}</title>
<style>
  :root{--bg:#0d1117;--card:#161b22;--border:#30363d;--text:#c9d1d9;--accent:#58a6ff;--ok:#3fb950;--warn:#d29922;}
  body{margin:0;font-family:-apple-system,Segoe UI,Arial,sans-serif;background:var(--bg);color:var(--text);}
  header{padding:32px 40px;border-bottom:1px solid var(--border);}
  header h1{margin:0;font-size:24px;color:#fff;}
  header p{margin:6px 0 0;color:#8b949e;}
  .grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(260px,1fr));gap:20px;padding:32px 40px;}
  .card{background:var(--card);border:1px solid var(--border);border-radius:10px;padding:20px;text-decoration:none;color:var(--text);transition:transform .15s,border-color .15s;}
  .card:hover{transform:translateY(-3px);border-color:var(--accent);}
  .card .icon{font-size:28px;}
  .card h2{font-size:16px;margin:12px 0 4px;color:#fff;}
  .card p{margin:0;font-size:13px;color:#8b949e;}
  footer{padding:20px 40px;color:#6e7681;font-size:12px;border-top:1px solid var(--border);}
</style>
</head>
<body>
<header>
  <h1>DevSecOps Security Reports</h1>
  <p>timesheet-devops &middot; Build #${BUILD_NUMBER} &middot; $(date '+%Y-%m-%d %H:%M')</p>
</header>
<div class="grid">
  <a class="card" href="dependency-check.html"><div class="icon">&#128270;</div><h2>OWASP Dependency-Check</h2><p>Dependances vulnerables (CVE) dans le pom.xml</p></a>
  <a class="card" href="sonarqube.html"><div class="icon">&#128187;</div><h2>SonarQube</h2><p>Qualite de code, bugs, vulnerabilites, code smells</p></a>
  <a class="card" href="trivy.html"><div class="icon">&#128230;</div><h2>Trivy Image Scan</h2><p>Vulnerabilites dans l'image Docker (OS + jar)</p></a>
  <a class="card" href="docker-bench.html"><div class="icon">&#128051;</div><h2>Docker Bench Security</h2><p>Audit CIS Docker Benchmark de l'hote</p></a>
  <a class="card" href="zap.html"><div class="icon">&#9889;</div><h2>OWASP ZAP Baseline</h2><p>Scan dynamique (DAST) de l'application deployee</p></a>
  <a class="card" href="gauntlt.html"><div class="icon">&#128737;</div><h2>Gauntlt</h2><p>Tests d'acceptation securite automatises</p></a>
  <a class="card" href="lynis.html"><div class="icon">&#128270;</div><h2>Lynis Security Audit</h2><p>Audit systeme / conformite (hardening index)</p></a>
</div>
<footer>Genere automatiquement par le pipeline Jenkins DEVSECOPS.</footer>
</body>
</html>
HTMLEOF

echo "Portail genere dans ${REPORT_DIR}/index.html"
ls -la "$REPORT_DIR"
