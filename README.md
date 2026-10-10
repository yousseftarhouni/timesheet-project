# Timesheet DevSecOps Pipeline

An end-to-end **DevSecOps CI/CD pipeline** built around a Spring Boot application,
demonstrating how to embed security into every stage of the software delivery
lifecycle — from the developer's keyboard to a running Kubernetes deployment.

> **Academic project — ESPRIT, DevSecOps module (class 5NIDS3).**
> **Authors:** Youssef Tarhouni, Mohamed Aymen Ladhari · **Supervisor:** Mrs. Nawel Hammemi.

---

## 1. What is this project?

This repository contains a small **timesheet / user-management REST API**
(Spring Boot + MySQL) that serves as the *target application* for a complete
**DevSecOps pipeline** orchestrated by Jenkins.

The application itself is intentionally simple — the real deliverable is the
**pipeline around it**: a chain of 20 automated stages that builds, tests,
scans, deploys, and monitors the app, with a dedicated **security control at
every phase** (the *shift-left* principle).

### What it is designed for
- To show how **security is integrated into DevOps** rather than bolted on at the end.
- To map the four DevSecOps phases — **Development, Acceptance, Production, Operations** — to concrete, working open-source tools.
- To **prove detection works**: two vulnerabilities are injected on purpose and caught by the pipeline's tools.
- To **centralise every security report** into a single HTML portal, archived on each build.

---

## 2. Architecture

Everything runs on a single machine (Ubuntu under WSL2). Jenkins runs as a
system service; the supporting tools run as Docker containers; the application
is deployed on a local Kubernetes cluster (Minikube).

```
GitHub ──push──> Jenkins (CI/CD) ──> Docker Hub (image registry)
                      │
                      ├─> SonarQube  (code quality / SAST)
                      ├─> Nexus      (artifact repository, versioned .jar)
                      ├─> Prometheus ──> Grafana (monitoring)
                      │
                      └─> Minikube (Kubernetes): MySQL pod + Timesheet app pod
                                                  (NodePort 30082)
```

---

## 3. The DevSecOps pipeline

The pipeline is a declarative Jenkinsfile. Security controls are placed in the
phase that matches what they inspect (code, dependencies, image, running app,
host).

| Phase | Stage / Tool | Type | What it does |
|-------|--------------|------|--------------|
| **Development — pre-commit** | Git pre-commit hook (HMRC security-git-hooks) | Prevention | Blocks secrets & sensitive files **before** the commit (runs on the dev machine) |
| **Development — commit** | JUnit (Mockito) | Unit tests | Runs the application unit tests |
| **Development — commit** | OWASP Dependency-Check | SCA | Scans Maven libraries for known CVEs (NVD database) |
| **Development — commit** | Docker Bench Security | Compliance | Audits Docker configuration against the CIS Benchmark |
| **Development — commit** | SonarQube | SAST | Static analysis of the source code (bugs, vulnerabilities, hotspots) + Quality Gate |
| **Build / Production** | Maven `package` | Build | Produces the executable `.jar` |
| **Build / Production** | Nexus (`mvn deploy`) | Artifact mgmt | Publishes the versioned `.jar` to the Nexus repository |
| **Build / Production** | Docker Build | Containerisation | Builds the Docker image |
| **Production** | Trivy | Image scan | Scans the image (OS + `.jar`) for HIGH/CRITICAL CVEs |
| **Production** | Docker Push | Release | Pushes the image to Docker Hub |
| **Deploy** | Kubernetes (`kubectl`) | Deployment | Deploys MySQL + the app, rolling restart |
| **Deploy** | Secrets Management Check | Verification | Ensures no clear-text password in the Deployment (uses a Kubernetes Secret) |
| **Acceptance** | Gauntlt | Attack test | Runs an attack against the app's SQL-injection endpoint |
| **Acceptance** | OWASP ZAP | DAST | Baseline security scan of the deployed application |
| **Operations** | Prometheus | Monitoring | Scrapes Jenkins metrics every 15s |
| **Operations** | Lynis | System audit | Audits/hardens the host (hardening index) |
| **Operations** | Grafana | Monitoring | Dashboards fed by Prometheus |
| **Reporting** | Collect Reports | Centralisation | Gathers every report into `security-reports/` and builds an HTML portal |

---

## 4. The security scenario (proof of detection)

To demonstrate the pipeline actually catches vulnerabilities, **two flaws are
injected on purpose**:

1. **Vulnerable dependency — Log4Shell**
   `org.apache.logging.log4j:log4j-core:2.14.1` is added to `pom.xml`.
   → Detected by **Trivy** (image scan) and **OWASP Dependency-Check** (source) as **CVE-2021-44228 (CRITICAL)**.

2. **SQL Injection (CWE-89)**
   The endpoint `/user/search-by-name` builds a native SQL query by string
   concatenation (`"... WHERE first_name = '" + name + "'"`).
   → Flagged by **SonarQube** as a security hotspot (rule `java:S2077`) and
   proven live by **Gauntlt**: a normal name returns HTTP 200, while an injected
   single quote (`name=x'`) returns HTTP 500 — proving the input reaches the SQL engine.

> ⚠️ **This repository intentionally contains insecure code for educational
> purposes.** Do not deploy it to a real environment. The vulnerable dependency
> and endpoint exist only to demonstrate security detection.

---

## 5. Tech stack

**Application:** Java (Spring Boot 2.5.4), Maven, MySQL
**CI/CD & DevOps:** Git / GitHub, Jenkins, Nexus, Docker / Docker Hub, Kubernetes (Minikube)
**Security (DevSecOps):** pre-commit (HMRC security-git-hooks), OWASP Dependency-Check, Docker Bench Security, SonarQube, Trivy, Gauntlt, OWASP ZAP, Lynis
**Monitoring:** Prometheus, Grafana

---

## 6. Repository structure

```
timesheet-project/
├── src/                      # Spring Boot application (Java)
├── k8s/                      # Kubernetes manifests (MySQL + app deployment, Secret)
├── security-tests/gauntlt/   # Gauntlt attack scenarios (SQLi test)
├── .pre-commit-config.yaml   # Pre-commit security hooks (secret scanning)
├── generate_portal.sh        # Builds the centralised HTML security-report portal
├── Dockerfile                # Builds the application image
├── docker-compose.yml        # Supporting services
└── pom.xml                   # Maven build + Nexus distribution
```

> The Jenkins pipeline itself is defined in the Jenkins job configuration
> (declarative pipeline script).

---

## 7. How to run

**Prerequisites:** Jenkins, Docker, Minikube/kubectl, SonarQube, Nexus,
Prometheus and Grafana running (containers), plus the required Jenkins
credentials (`github-token`, `dockerhub-creds`, `nvd-api-key`, `nexus-creds`).

1. Start the environment (SonarQube, Minikube, Prometheus/Grafana, etc.).
2. In Jenkins, run the **DEVSECOPS** pipeline job (**Build Now**).
3. When the build finishes, open **Security Reports Portal** from the build page
   to see all tool reports in one place.
4. The application is exposed on the Minikube NodePort:
   `http://<minikube-ip>:30082/timesheet-devops`.

---

## 8. Authors

- **Youssef Tarhouni**
- **Mohamed Aymen Ladhari**

Supervised by **Mrs. Nawel Hammemi** — ESPRIT, DevSecOps module.
