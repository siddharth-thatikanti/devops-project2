
#!/usr/bin/env bash
set -Eeuo pipefail

# Jenkins LTS clean reinstall on Ubuntu EC2
# Jenkins web port: 8081
# Preserves Java, Docker, Git, Terraform and project files.

if [[ "$EUID" -ne 0 ]]; then
    echo "Run using: sudo bash install.sh"
    exit 1
fi

echo "WARNING: This deletes all existing Jenkins jobs, credentials,"
echo "plugins and configuration."
read -r -p 'Type DELETE-JENKINS-DATA to continue: ' confirm

if [[ "$confirm" != "DELETE-JENKINS-DATA" ]]; then
    echo "Cancelled."
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

echo "[1/7] Stop Jenkins..."
systemctl stop jenkins 2>/dev/null || true
systemctl disable jenkins 2>/dev/null || true

echo "[2/7] Remove Jenkins package and data..."
apt-get purge -y jenkins || true

rm -rf /var/lib/jenkins
rm -rf /var/cache/jenkins
rm -rf /var/log/jenkins
rm -rf /etc/systemd/system/jenkins.service.d
rm -f /etc/systemd/system/jenkins.service
rm -f /etc/default/jenkins
rm -f /etc/apt/sources.list.d/jenkins.list
rm -f /etc/apt/keyrings/jenkins-keyring.asc

systemctl daemon-reload
systemctl reset-failed jenkins 2>/dev/null || true

echo "[3/7] Verify Java 21 or later..."
if ! command -v java >/dev/null 2>&1; then
    apt-get update
    apt-get install -y openjdk-21-jre
fi

java -version

JAVA_MAJOR="$(
    java -XshowSettings:properties -version 2>&1 |
    awk '/java.specification.version =/ {print $3; exit}'
)"

if [[ -z "$JAVA_MAJOR" ]] || (( JAVA_MAJOR < 21 )); then
    echo "ERROR: Java 21 or later is required."
    exit 1
fi

echo "[4/7] Install required packages..."
apt-get update
apt-get install -y curl ca-certificates fontconfig gnupg

echo "[5/7] Configure official Jenkins LTS repository..."
install -d -m 0755 /etc/apt/keyrings

curl -fsSL \
    https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key \
    -o /etc/apt/keyrings/jenkins-keyring.asc

chmod 0644 /etc/apt/keyrings/jenkins-keyring.asc

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
    > /etc/apt/sources.list.d/jenkins.list

apt-get update

echo "[6/7] Install Jenkins..."
apt-get install -y jenkins

echo "[7/7] Configure Jenkins port 8081..."
mkdir -p /etc/systemd/system/jenkins.service.d

cat > /etc/systemd/system/jenkins.service.d/override.conf <<'OVERRIDE'
[Service]
Environment="JENKINS_PORT=8081"
OVERRIDE

systemctl daemon-reload
systemctl enable jenkins
systemctl reset-failed jenkins || true
systemctl start jenkins

sleep 5

if systemctl is-active --quiet jenkins; then
    echo
    echo "SUCCESS: Jenkins is running."
    systemctl status jenkins --no-pager -l

    echo
    echo "Listening ports:"
    ss -ltnp | grep ':8081' || true

    echo
    echo "Initial administrator password:"
    if [[ -f /var/lib/jenkins/secrets/initialAdminPassword ]]; then
        cat /var/lib/jenkins/secrets/initialAdminPassword
    else
        echo "Password file not ready. Check Jenkins logs."
    fi

    echo
    echo "Access URL: http://YOUR_EC2_PUBLIC_IP:8081"
    echo "Allow TCP 8081 from your IP in the EC2 security group."
else
    echo
    echo "Jenkins failed to start. Diagnostics:"
    journalctl -u jenkins -n 100 --no-pager
    exit 1
fi

