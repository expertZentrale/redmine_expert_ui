# Changelog – redmine_expert_ui

> [English version](CHANGELOG.md) · 🇩🇪 Deutsche Version
>
> Maßgeblich ist die englische Fassung — daraus werden die Release-Notes erzeugt.

## [Unreleased]

## [0.1.0] - 2026-11-03

### Hinzugefügt

- Schließen-Button auf der Ticketseite, neben „Bearbeiten“ in beiden Aktionsleisten. Er setzt einen
  einstellbaren geschlossenen Status (Standard: der erste geschlossene Status) und % erledigt 100
  und speichert das Bearbeitungsformular, eine dort getippte Notiz geht also mit. Er erscheint
  nur, solange das Ticket offen ist, der Benutzer es bearbeiten darf und der Workflow den Status
  erlaubt.
- Automatisches Aktualisieren für die Ticketliste und „Meine Seite“: ein Link, der herunterzählt
  und die Seite neu lädt, pro Benutzer und Seite eingeschaltet. Das Neuladen wartet, solange der
  Benutzer tippt, Zeilen markiert hat oder ein Dialog bzw. das Kontextmenü offen ist; Tabs im
  Hintergrund laden neu, sobald sie wieder angezeigt werden.
- Aktualisierungs-Intervall pro Benutzer unter „Mein Konto“ (und im Benutzerformular für
  Administratoren), mindestens 10 Sekunden, mit einem Standard in den Plugin-Einstellungen.
- Nutzt die Einstellungen, die `redmine_refresh` gespeichert hat (Intervall, An/Aus pro Seite),
  die Benutzer behalten sie also.
- Jede Funktion bleibt aus, solange das Plugin, das sie ersetzt (`redmine_close_button`,
  `redmine_refresh`), noch installiert ist; die Einstellungsseite sagt das.
- Oberfläche auf Englisch, Deutsch, Spanisch, Französisch, Italienisch und Portugiesisch
  (Portugal, Brasilien).
