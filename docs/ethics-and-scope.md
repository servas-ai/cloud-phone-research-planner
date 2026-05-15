# Ethik & Scope

## Forschungsrahmen

Dieses Projekt ist akademische Sicherheitsforschung im kontrollierten Lab einer Hochschule. Es untersucht **Detection-Mechanismen**, nicht deren Umgehung gegenueber realen Drittsystemen.

## Klare Grenzen

| Erlaubt im Projekt | Nicht Teil des Projekts |
|---|---|
| Eigene DetectorLab-Suite als Mess-Oracle | Tests gegen TikTok / Instagram / sonstige Live-Plattformen |
| ReDroid in isolierter Lab-Umgebung | Account-Erstellung auf Drittplattformen |
| Hardware-Attestation-Forschung | Kommerzielle Verwertung der Spoofing-Stacks |
| Open-Source-Veroeffentlichung von DetectorLab | Veroeffentlichung gebrauchsfertiger Account-Farm-Anleitungen |
| Layer-by-Layer-Evaluation als Heatmap | Hilfe fuer Plattform-ToS-Verstoesse |

## Rechtsrahmen Deutschland (D-A-CH)

- **§202c StGB (Vorbereitung von Ausspaehen / Abfangen)**: Erstellen und Besitz von "Hacker-Tools" ist strafbar, **wenn** sie zur Begehung von Straftaten bestimmt sind. Reine Forschungs- und Auditierungs-Tools sind ueberwiegende Auffassung legal. DetectorLab faellt klar in den zweiten Bereich.
- **§88 TKG**: Telekommunikationsgeheimnis. Nicht relevant, da kein Drittverkehr abgefangen wird.
- **Technischer Scope**: Das Projekt verarbeitet keine User-Profile,
  keine Accounts und keine Daten von Personen. Messdaten stammen aus
  isolierten Lab-Systemen und selbst kontrollierter Test-Hardware.
- **TMG / DSA**: Keine Kommunikation mit Live-Plattformen.

## Plattform-ToS

TikTok / Instagram ToS untersagen automatisierten Zugriff. Dieses Projekt **fuehrt keinen Zugriff durch**. Die Detection-Methoden werden anhand publizierter Forschung (Decompiled-Code-Analysen, akademische Veroeffentlichungen, OSS-Projekte) rekonstruiert und gegen die eigene DetectorLab-App geprueft.

## IRB / Ethik-Antrag

Antrag bei der Ethik-Kommission der Hochschule mit folgenden Punkten:

1. **Studienziel**: Empirische Evaluation von Detection-Robustheit
2. **Studientyp**: Technische Evaluation, keine Probandenstudie
3. **Datenarten**: Lab-Telemetrie eigener oder universitaerer Hardware,
   keine User-Profile, keine Accounts, keine Personen-Traces
4. **Risiken fuer Dritte**: Keine, da keine Drittsysteme involviert
5. **Veroeffentlichung**: Methodologie + DetectorLab open-source; Spoofing-Stack nur als wissenschaftliche Beschreibung im Paper

Phase 0 darf erst verlassen werden, wenn `registration/approval-log.md`
alle anwendbaren Gates als freigegeben dokumentiert: Ethik-/Scope-Review,
IT-Security, Legal-Gate F21/F22/F23 und OSF-Pre-Registration.

## Disclosure-Policy

Falls im Verlauf eine bisher unbekannte Detection-Schwaeche bei einem konkreten Anbieter identifiziert wird:

1. **90-Tage Coordinated Disclosure**
2. Bericht via Security@-Adresse oder Bug-Bounty-Programm
3. Veroeffentlichung erst nach Patch oder Frist-Ablauf
4. Keine Public-PoC vor Disclosure

## Daten- und Code-Hygiene

- Keine Keyboxen aus illegitimen Quellen
- Keine kommerziellen Spoofing-Tools mit unklarer Provenienz
- Alle OSS-Module aus offiziellen GitHub-Repos, Hash-gepinnt
- Lab-Netz strikt vom Hochschul-Netz isoliert (eigenes VLAN)
- Keine Synchronisation mit persoenlichen Accounts (Google, Samsung, etc.)
