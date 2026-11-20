# Changelog – redmine_expert_ui

> [English version](CHANGELOG.md) · 🇩🇪 Deutsche Version
>
> Maßgeblich ist die englische Fassung — daraus werden die Release-Notes erzeugt.

## [Unreleased]

## [0.2.0] - 2026-11-20

### Hinzugefügt

- Theme pro Benutzer: ein Feld „Theme“ unter „Mein Konto“ (und im Benutzerformular für
  Administratoren). Stylesheets, Bilder, Favicon, Icons und das JavaScript des Themes folgen der
  Wahl des Benutzers; wer nichts wählt, behält das globale Theme, ebenso anonyme Seiten wie die
  Anmeldeseite.
- Plugin-Einstellungen dazu: ein Schalter und eine Liste der angebotenen Themes (keines angehakt:
  alle installierten). Eine Wahl, die nicht mehr installiert ist oder nicht mehr angeboten wird,
  fällt auf das globale Theme zurück.
- Abbrechen-Schutz: Würde „Abbrechen“ unter dem Ticketformular (auch für Helpdesk-Antworten) oder
  unter einer bearbeiteten Notiz geänderten Text verwerfen, wird vorher nachgefragt. Pro Projekt
  über das Modul „Abbrechen-Schutz“ aktiviert, kein globaler Schalter. Varianten: Bestätigen
  (Standard), Ausweichen, Zum Abbrechen schieben, Auskippen, Gedrückt halten, Schredder und Zufall.
  Die Plugin-Einstellungen legen die Standardvariante fest, Benutzer wählen ihre eigene unter
  „Mein Konto“. Bei reduzierter Bewegung zeigen die animierten Varianten stattdessen den Dialog.

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
