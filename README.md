# Kenku Brett

Ein schlanker, mobil-freundlicher Web-Proxy für das [Kenku](https://www.kenku.fm/)-Soundboard.  
Er dient als einfache Web-Oberfläche, über die du Sounds aus Kenku auslösen kannst – z. B. vom Handy am Spieltisch.

## Was macht das Projekt?

Kenku selbst bietet einen lokalen Remote-API-Server auf Port `3333`. Dieser Container liefert eine kleine HTML-Oberfläche aus und leitet API-Aufrufe an Kenku weiter.

## Voraussetzungen

- Docker (oder ein Container-Runner deiner Wahl)
- Kenku ist installiert und der **Kenku Remote / API-Server** ist aktiviert
- Der Rechner, auf dem Kenku läuft, ist im selben lokalen Netzwerk erreichbar wie der Docker-Host

## Kenku einrichten

1. Öffne Kenku.
2. Aktiviere unter **Settings → Remote** den Remote-Server (Port `3333`).
3. Notiere dir die angezeigte **lokale IPv4-Adresse**.

### Woher bekomme ich die IP?

Die IP ist die Adresse deines Computers im lokalen Netzwerk, **nicht** `localhost` oder `127.0.0.1`.

Unter **Windows** (PowerShell):

```powershell
Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '127.*' }
```

Unter **macOS / Linux**:

```bash
ipconfig getifaddr en0
# alternativ:
hostname -I
```

Ein typisches Beispiel wäre:

```
192.168.178.42
```

Diese IP muss beim Starten des Containers übergeben werden, damit Nginx die API-Aufrufe an Kenku weiterleiten kann.

## Image aus GitHub Packages verwenden

Das Image wird automatisch über GitHub Actions zu GitHub Packages (GitHub Container Registry) gepusht:

```text
ghcr.io/mehtrick/kenku-brett
```

## Container starten

Der entscheidende Teil ist die Umgebungsvariable `KENKU_IP`. Sie muss die zuvor ermittelte **lokale IP-Adresse** des Kenku-Rechners enthalten.

> **Achtung Reihenfolge:** Alle Docker-Optionen (`-d`, `--name`, `-p`, `-e`) müssen **vor** dem Image-Namen stehen. Alles nach dem Image-Namen wird als Container-Befehl interpretiert und führt zu Fehlern wie `illegal option -p`.

```bash
docker run -d \
  --name kenku-brett \
  -p 8080:80 \
  -e KENKU_IP=192.168.178.42 \
  ghcr.io/mehtrick/kenku-brett:latest
```

Danach ist die Oberfläche unter `http://DOCKER_HOST_IP:8080` erreichbar.

### Mit Docker Compose

```yaml
services:
  kenku-brett:
    image: ghcr.io/mehtrick/kenku-brett:latest
    ports:
      - "8080:80"
    environment:
      KENKU_IP: "192.168.178.42"
    restart: unless-stopped
```

## Wichtige Hinweise zur IP

- `KENKU_IP` darf **nicht** `localhost` oder `127.0.0.1` sein, wenn Kenku außerhalb des Containers läuft.
- Innerhalb eines Docker-Containers bezeichnet `localhost` den Container selbst, nicht den Host-Rechner.
- Deshalb muss die echte **LAN-IP-Adresse** des Kenku-Rechners verwendet werden.
- Wenn sich die IP des Kenku-Rechners ändert (z. B. durch DHCP), muss der Container mit der neuen IP neu gestartet werden.

## Lokales Bauen

Wenn du das Image selbst bauen möchtest:

```bash
docker build -f dockerfile -t kenku-brett .
docker run -d -p 8080:80 -e KENKU_IP=192.168.178.42 kenku-brett
```

## GitHub Actions

Bei jedem Push auf `main`/`master` oder bei Veröffentlichung eines Tags wird ein neues Image gebaut und nach GitHub Packages gepusht.  
Die Workflow-Datei findest du unter `.github/workflows/docker-publish.yml`.
