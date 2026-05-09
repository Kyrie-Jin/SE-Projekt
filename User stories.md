## 2 User Stories

Die Anforderungen an das zu erstellende Projekt sind zu Beginn in Form von User Stories zu erstellen und zu priorisieren. Über den Projektverlauf sind die User Stories laufend zu aktualisieren. Details zu den User Stories sind in der Prozessbeschreibung zu Scrum aufgeführt.

### 2.1 Basis User Stories

Im Rahmen der Anforderungsanalyse wurden nachfolgende User Stories identifiziert. Beachten Sie, dass es sich hierbei um die Minimalanforderungen an die Applikation handelt. Die User Stories decken daher nicht alle Funktionen ab, die innerhalb der Applikation benötigt werden.

#### 2.1.1 Registrierung

**Registrierung**

„Als Kunde möchte ich mich über ein Formular, in das ich alle relevanten Daten eingebe, registrieren können. Der Kunde soll nach dem Speichern permanent im System erfasst sein.“

#### 2.1.2 Authentifizierung

**Accountsperre nach falscher Passworteingabe**

„Als Kunde möchte ich mich durch Eingabe der E-Mail und des Passwortes einloggen können. Bin ich eingeloggt, möchte ich mich auch wieder ausloggen können. Sollte ich fünfmal hintereinander ein falsches Passwort eingeben, soll mein Account aus Sicherheitsgründen gesperrt werden.“

**Entsperren von Accounts**

„Als Administrator möchte ich gesperrte User anzeigen und entsperren können.“

#### 2.1.3 News

**Aktuelle News anzeigen**

„Als Kunde möchte ich die aktuellen Informationen zu bevorstehenden Veranstaltungen nach erfolgreicher Authentifizierung angezeigt bekommen. Dafür möchte ich direkt nach der Authentifizierung eine Seite sehen, auf der mir die Informationen präsentiert werden. Es sollen dabei nur die Informationen angezeigt werden, die ich noch nicht gesehen habe. Auf der Übersichtsseite soll zumindest der Titel und das Datum sowie eine Kurzzusammenfassung der News angezeigt werden.“

**Detailansicht der News**

„Als Kunde möchte ich eine Detailansicht eines Newseintrags sehen. Dieser soll den kompletten Text, falls vorhanden, ein angezeigtes Bild und alle weiteren Details des Newseintrags enthalten.“

**Frühere News anzeigen**

„Als Kunde möchte ich die Möglichkeit haben, bereits gelesene News erneut anzuzeigen.“

**News erstellen**

„Als Administrator möchte ich neue News erstellen können. Zu jedem Newseintrag möchte ich mindestens ein Bild anhängen können, das in der Detailansicht der News gezeigt wird.“

#### 2.1.4 Kunden

**Kunde bearbeiten**

„Als Kunde möchte ich mein Profil bearbeiten können. Die Änderungen sollen permanent im System erfasst sein.“

**Kunde löschen**

„Als Kunde möchte ich meinen Account unwiderruflich löschen können.“

#### 2.1.5 Veranstaltungen

**Top Ten Veranstaltungen**

„Als Kunde möchte ich mir die Top Ten Veranstaltungen nach verkauften Tickets und Kategorien in einem Monat anzeigen lassen. Die Darstellung soll grafisch in einem Chart erfolgen. In weiterer Folge möchte ich als Kunde Tickets zu dieser Veranstaltung kaufen oder reservieren können.“

**Suchen/Filtern nach Künstlern**

„Als Kunde möchte ich nach Veranstaltungen eines Künstlers suchen können. Dabei möchte ich nach den Kriterien Vorname und Nachname des Künstlers filtern können. Es sollen aber auch Künstler unterstützt werden, die nicht in dieses Schema fallen, wie z. B. Band-Namen oder Künstlernamen. Die Künstler, die den Suchkriterien entsprechen, sollen mir in einer Liste angezeigt werden. Wenn ich einen Künstler auswähle, möchte ich seine Veranstaltungen angezeigt bekommen. In weiterer Folge möchte ich zu einer Aufführung des Künstlers Tickets kaufen oder reservieren können.“

**Suchen/Filtern nach Orten**

„Als Kunde möchte ich nach Aufführungsorten suchen können. Dabei möchte ich nach den Kriterien Bezeichnung, Straße, Ortsname, Land oder PLZ des Ortes filtern können. Die gefundenen Orte sollen mir in einer Tabelle angezeigt werden. Wenn ich einen Ort auswähle, möchte ich die Aufführungen des Ortes angezeigt bekommen. In weiterer Folge möchte ich Tickets zu einer Aufführung an dem Ort kaufen oder reservieren können.“

**Suchen/Filtern nach Veranstaltungen**

„Als Kunde möchte ich nach Veranstaltungen suchen können. Dabei möchte ich einen Suchbegriff eingeben können, der nach den Kriterien Bezeichnung der Veranstaltung, Typ, Dauer (+/- 30 Minuten Toleranz) oder dem Inhalt filtert. Nach der Suche sollen mir die gefundenen Veranstaltungen in einer Tabelle angezeigt werden. Wenn ich eine Veranstaltung auswähle, möchte ich die zugehörigen Aufführungen angezeigt bekommen. In weiterer Folge möchte ich Tickets zu einer Aufführung der Veranstaltung kaufen oder reservieren können.“

**Suchen/Filtern nach Zeit**

„Als Kunde möchte ich nach Aufführungen suchen können. Dabei möchte ich nach den Kriterien Datum/Uhrzeit, Preis (+/- sinnvolle Toleranz), Veranstaltung und Säle filtern können. Nach der Suche sollen mir die gefundenen Aufführungen in einer Tabelle angezeigt werden. In weiterer Folge möchte ich Tickets zu einer gefundenen Aufführung kaufen oder reservieren können.“

**Veranstaltungen erstellen**

„Als Administrator möchte ich neue Veranstaltungen im System anlegen können.“

#### 2.1.6 Tickets

**Saalplan**

„Als Kunde möchte ich eine grafische Darstellung des Saalplans aufrufen können. Hierbei sollen Reihennummer und Platznummer sowie Preiskategorien sichtbar unterschiedlich hervorgehoben werden. Aus der Darstellung soll klar hervorgehen, welche Plätze für eine Veranstaltung noch frei sind und welche bereits belegt sind. Außerdem soll eine Darstellung unterschiedlicher Saal-Layouts möglich sein. (Zum Beispiel: unterschiedliche Platzanzahl pro Reihe)“

**Sektoren**

„Als Kunde möchte ich Tickets für unterschiedliche Arten von Sektoren kaufen. Zumindest sind Sektoren mit Platzwahl (mit der Auswahl von Reihe und Sitzplatz) und Sektoren ohne Platzwahl (z. B. Stehplätze) notwendig. Dabei sollen unterschiedliche Sektoren jeweils unterschiedliche Preiskategorien haben können.“

**Ticketkauf**

„Als Kunde möchte ich Tickets für eine Aufführung kaufen können. Dabei soll der Saalplan für die Platzauswahl grafisch erfolgen und eine Mehrfachauswahl von Sitzplätzen ermöglichen.“

**Ticketreservierung**

„Als Kunde möchte ich Tickets für eine Aufführung reservieren können. Dabei soll mir als Kunde eine Meldung angezeigt werden, dass ich die Tickets 30 Minuten vor Beginn der Aufführung abholen muss, ansonsten verfällt das Ticket. Die Platzauswahl soll über den grafischen Saalplan erfolgen und eine Mehrfachauswahl von Sitzplätzen ermöglichen. Nach erfolgreicher Reservierung soll die Reservierungsnummer angezeigt werden.“

**Bestellübersicht**

„Als Kunde möchte ich alle gekauften und reservierten Tickets in einer Übersicht sehen. Alle gekauften Tickets von sowohl kommenden als auch vergangenen Veranstaltungen sowie alle noch existierenden Reservierungen sollen angezeigt werden.“

**Stornierung von Ticketreservierungen**

„Als Kunde möchte ich reservierte Tickets stornieren. Die stornierten Plätze sollen wieder freigegeben werden.“

**Ticketkauf reservierter Tickets**

„Als Kunde möchte ich zuvor reservierte Tickets kaufen können. Die gekauften Plätze sollen danach als verkauft dargestellt werden. Außerdem möchte ich die Möglichkeit haben, nicht alle Plätze der Reservierung zu kaufen. Die nicht gekauften Plätze sollen wieder freigegeben werden.“

**Stornierung von gekauften Tickets**

„Als Kunde möchte ich gekaufte Tickets stornieren. Die stornierten Plätze sollen wieder freigegeben werden.“

#### 2.1.7 Rechnungsdruck

**PDF-Druck von Rechnungen**

„Als Kunde möchte ich für jeden Kauf eine Rechnung im PDF-Format herunterladen können. Die Rechnung muss den in Österreich gültigen Bestimmungen zur Rechnungslegung entsprechen.“

**PDF-Druck von Stornorechnungen**

„Als Kunde möchte ich für jede Stornierung eine Stornorechnung drucken können. Dazu werden die Kundendaten aus der zu stornierenden Rechnung vorausgefüllt und der Kauf rückabgewickelt.“

### 2.2 Erweiterte User Stories

Zusätzlich zu den Basis User Stories gibt es drei Kategorien von erweiterten User Stories: „Merchandise und Prämien“, „Benutzerverwaltung“, „Ticketkauf und Dateneingabe“. Aus diesen drei Kategorien müssen Sie zwei wählen, die Sie umsetzen möchten.

#### 2.2.1 Merchandise und Prämien

**Kauf von Merchandise**

„Als Kunde möchte ich Merchandise-Artikel mit unterschiedlichen Zahlungsmöglichkeiten kaufen. Dabei sollen mir die verfügbaren Merchandise-Artikel angezeigt werden. Außerdem möchte ich als Kunde Artikel in unterschiedlichen Mengen kaufen können.“

**Prämienübersicht**

„Als Kunde möchte ich die verfügbaren Prämien sehen können. Als Prämien können bestimmte Merchandise-Artikel gewählt werden.“

**Prämienpunktekonto**

„Als Kunde möchte ich meinen aktuellen Punktestand meines Accounts einsehen können.“

**Erhalt von Prämienpunkten**

„Als Kunde möchte ich, dass mir als Stammkunden bei jedem Kauf Prämienpunkte gutgeschrieben werden.“

**Eintausch von Prämienpunkten**

„Als Kunde möchte ich die Punkte meines Accounts gegen eine verfügbare Prämie eintauschen können.“

#### 2.2.2 Benutzerverwaltung

**Nutzer anlegen**

„Als Administrator möchte ich neue User (Kunden/Administratoren) im System anlegen können.“

**Nutzer sperren**

„Als Administrator möchte ich User des Systems sperren sowie gesperrte User wieder aktivieren können. Dabei ist es wichtig, dass sich ein Administrator nicht selbst aus dem System aussperren kann.“

**Administrativ Passwort zurücksetzen**

„Als Administrator möchte ich die Passwörter von anderen Usern zurücksetzen können. Dem User wird dann eine Mail geschickt, welche das Zurücksetzen des Passwortes erlaubt. Als Administrator soll ich zu keinem Zeitpunkt Zugriff auf das Passwort erhalten.“

**Passwort selbst zurücksetzen**

„Als User möchte ich mein eigenes Passwort über eine Passwort-vergessen-Funktion zurücksetzen können. Dabei wird ebenso wie bei der administrativen Variante eine Mail verschickt, die das Zurücksetzen des Passwortes erlaubt.“

#### 2.2.3 Ticketdruck und Dateneingabe

**PDF-Druck von Tickets**

„Als Kunde möchte ich, dass für jeden Ticketkauf ein Ticket ausgedruckt werden kann. Das Ticket muss alle relevanten Informationen der Veranstaltung enthalten. Überlegen Sie, ob Ihnen Sicherheitsmaßnahmen einfallen, die das Ticket ‚fälschungssicher‘ machen.“

**Anlegen von Orten und Saalplänen**

„Als Administrator möchte ich neue Aufführungsorte und Saalpläne anlegen können. Das Erstellen und Editieren der Saalpläne muss grafisch erfolgen.“
