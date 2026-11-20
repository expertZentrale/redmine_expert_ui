> [English version](README.md) · 🇩🇪 Deutsche Version

# Redmine expert UI

Kleine Verbesserungen für die tägliche Arbeit in Redmine, jede mit eigenem Schalter:

- ein **Schließen-Button** auf der Ticketseite,
- **automatisches Aktualisieren** für die Ticketliste und „Meine Seite“,
- ein **Theme pro Benutzer**, damit jeder sein Aussehen selbst wählt, und
- ein **Abbrechen-Schutz**, pro Projekt aktivierbar, der nachfragt, bevor „Abbrechen“ getippten
  Text verwirft.

Es ersetzt die Plugins `redmine_close_button` und `redmine_refresh` und behält die
Aktualisierungs-Einstellungen aller Benutzer. Es braucht weder Deface noch kopierten Core-Code.
Läuft auf **Redmine 5.1, 6.0, 6.1 und 7.0**.

## Schließen-Button

Ein Button **Schließen** neben „Bearbeiten“ in den Aktionsleisten der Ticketseite (oben und unten).
Ein Klick setzt den Status auf den in den Einstellungen gewählten geschlossenen Status, setzt
% erledigt auf 100, wenn das Feld bearbeitbar ist, und speichert. Was im Bearbeitungsformular
getippt wurde, wird mitgespeichert. Eine Abschlussnotiz landet also im selben Eintrag.

Der Button erscheint nur, wenn er auch funktioniert: Das Ticket ist offen, der Benutzer darf es
bearbeiten, und der Workflow erlaubt ihm diesen Status. Ohne eingestellten Status nimmt er den ersten
geschlossenen Status in Redmines Reihenfolge („Administration » Ticket-Status“).

## Automatisch aktualisieren

Ein Link **Automatisch aktualisieren** oben in der Ticketliste und auf „Meine Seite“. Ein Klick
schaltet das Aktualisieren für diese Seite ein: Der Link zählt herunter („Aktualisierung in 87 s“)
und lädt die Seite bei null neu. Ein weiterer Klick schaltet es wieder aus. Die Wahl wird pro
Benutzer und pro Seite gespeichert.

Das Neuladen wartet, solange es etwas zerstören würde. Es wartet, solange:

- jemand in ein Feld tippt;
- Zeilen für eine Sammelaktion markiert sind;
- ein Dialog oder das Kontextmenü offen ist.

Ein Tab im Hintergrund lädt erst neu, wenn er wieder angezeigt wird.

Jeder Benutzer stellt sein Intervall unter „Mein Konto » Einstellungen“ ein (mindestens 10 Sekunden;
leer heißt Standard). Administratoren können es auch im Benutzerformular setzen.

## Theme pro Benutzer

Redmine kennt ein Theme für alle. Mit dieser Funktion wählt jeder Benutzer sein eigenes unter
„Mein Konto » Einstellungen » Theme“; Administratoren können es auch im Benutzerformular setzen.
Stylesheets, Bilder, Favicon, Icons und das JavaScript des Themes folgen der Wahl.

Wer nichts wählt, behält das Theme aus „Administration » Konfiguration » Anzeige“. Das Einschalten
ändert also nichts, bis jemand ein Theme wählt. So lässt sich ein neues Theme anbieten, ohne alle
auf einmal umzustellen. Die Anmeldeseite und andere anonyme Seiten nutzen immer das globale Theme.

In den Plugin-Einstellungen wird angehakt, welche Themes angeboten werden; ist keines angehakt,
sind es alle installierten. Eine Wahl, die nicht mehr installiert ist oder nicht mehr angeboten
wird, fällt auf das globale Theme zurück.

## Abbrechen-Schutz

„Abbrechen“ unter dem Ticketformular, unter einer Antwort an den Kunden oder unter einer
bearbeiteten Notiz schließt das Formular, ohne den getippten Text zu speichern. Ein Fehlklick, und
eine lange Antwort ist weg. Der Abbrechen-Schutz greift, wenn ein Textfeld dieses Formulars
geänderten Text enthält, und fragt vorher nach. Ohne getippten Text funktioniert „Abbrechen“ wie
immer.

Er läuft in den Projekten, die das Modul **Abbrechen-Schutz** aktivieren („Projekt » Einstellungen
» Module“); einen globalen Schalter gibt es nicht. In den Plugin-Einstellungen steht die
Standardvariante, jeder Benutzer kann unter „Mein Konto » Einstellungen“ eine eigene wählen:

| Variante | Was passiert |
|---|---|
| Bestätigen | Ein Dialog: „Weiterschreiben“ (vorausgewählt, auch Escape) oder „Verwerfen“ |
| Ausweichen | Der Link springt ein- oder zweimal weg, mit frechem Spruch, dann gibt er nach |
| Zum Abbrechen schieben | Ein Schieberegler ersetzt den Link; nur ganz durchgeschoben wird abgebrochen |
| Auskippen | Der Link wird zum vollen Glas. Gedrückt gehalten kippt er und läuft leer (etwa 2,5 Sekunden); früher loslassen stellt ihn wieder auf, der Text bleibt |
| Gedrückt halten | Abbruch erst, wenn der Link (oder Enter/Leertaste) 1,5 Sekunden gehalten wird |
| Schredder | Der Text läuft über dem Feld durch einen Schredder; „Stopp!“ rettet ihn |
| Zufall | Jedes Mal eine der fünf verspielten Varianten |

Escape oder ein Klick daneben behält den Text immer. Ist im Betriebssystem „Bewegung reduzieren“
eingestellt, zeigen die animierten Varianten (Ausweichen, Auskippen, Schredder) stattdessen den
Dialog. Der Schutz funktioniert mit beiden Helpdesk-Plugins, weil deren Antworten im Notizfeld des
Ticketformulars geschrieben werden.

## Einstellungen

„Administration » Plugins » Redmine expert UI » Konfigurieren“:

| Einstellung | Standard | Bedeutung |
|---|---|---|
| Schließen-Button anzeigen | an | Schaltet den Schließen-Button ein oder aus |
| Status, den der Button setzt | erster geschlossener Status | Welchen geschlossenen Status der Button setzt |
| Automatisches Aktualisieren anbieten | an | Schaltet den Link und das Intervall-Feld ein oder aus |
| Standard-Intervall | 120 Sekunden | Für Benutzer ohne eigenes Intervall |
| Benutzer wählen ihr Theme selbst | an | Schaltet das Theme-Feld unter „Mein Konto“ ein oder aus |
| Angebotene Themes | keines angehakt | Die Themes, die Benutzer wählen dürfen; keines angehakt heißt alle installierten |
| Abbrechen-Schutz: Standardvariante | Bestätigen | Die Variante für Benutzer ohne eigene Wahl; eingeschaltet wird der Schutz pro Projekt |

## Umstieg von redmine_close_button und redmine_refresh

Beide dürfen zunächst installiert bleiben: Solange eines davon da ist, bleibt die passende Funktion
hier aus, und die Einstellungsseite sagt das. Zum Umstellen:

1. Dieses Plugin installieren und neu starten. Noch ändert sich nichts.
2. `plugins/redmine_close_button` und `plugins/redmine_refresh` entfernen und neu starten. Auch
   `plugins/redmine_base_deface` entfernen, wenn nichts anderes es braucht, und damit das Gem
   `deface`.
3. In den Einstellungen den geschlossenen Status wählen, den der Button setzen soll.
   `redmine_close_button` hat immer den Status mit der ID 5 gesetzt.

`redmine_refresh` hat Intervall und An/Aus jedes Benutzers in dessen Einstellungen gespeichert.
Dieses Plugin liest dieselben Werte, jeder Benutzer behält sie also.

## Sprachen

Oberfläche auf Englisch, Deutsch, Spanisch, Französisch, Italienisch und Portugiesisch (Portugal und
Brasilien); andere Sprachen fallen auf Englisch zurück.

## Installation

```bash
cd /path/to/redmine/plugins
git clone https://github.com/expertZentrale/redmine_expert_ui.git
# Redmine neu starten
```

Keine Migrationen, keine zusätzlichen Gems.

## Tests

```bash
bundle exec rake redmine:plugins:test NAME=redmine_expert_ui RAILS_ENV=test
```

Die CI führt sie gegen Redmine 5.1, 6.0, 6.1 und 7.0 auf MariaDB aus, gegen 5.1 und 7.0 zusätzlich
auf MySQL und PostgreSQL. Außerdem startet sie die offiziellen Redmine-Docker-Images mit
eingebundenem Plugin und prüft Ticketliste und „Meine Seite“.

## Lizenz

GNU General Public License v2 oder später, siehe [LICENSE](LICENSE).
