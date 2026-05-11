# Software Engineering Projekt

# Ticketline 4.0 – Szenario und User Stories

```
Version 4.
```
### 2. April 2026

##### 1


## Inhaltsverzeichnis


- 1 Projektbeschreibung
- 2 User Stories
   - 2.1 Basis User Stories
      - 2.1.1 Registrierung
      - 2.1.2 Authentifizierung
      - 2.1.3 News
      - 2.1.4 Kunden
      - 2.1.5 Veranstaltungen
      - 2.1.6 Tickets
      - 2.1.7 Rechnungsdruck
   - 2.2 Erweiterte User Stories
      - 2.2.1 Merchandise und Prämien
      - 2.2.2 Benutzerverwaltung
      - 2.2.3 Ticketdruck und Dateneingabe
- 3 Nicht-funktionale Anforderungen
   - 3.1 Anforderungen an Usability
   - 3.2 Anforderungen an Performance
   - 3.3 Anforderungen an Security
      - 3.3.1 SQL-Injection
      - 3.3.2 Berechtigungen
      - 3.3.3 Kryptographie
   - 3.4 Organisatorische und rechtliche Rahmenbedingungen
## 1 Projektbeschreibung

Ticketline ist ein österreichweit tätiges Unternehmen, das sich auf den Verkauf von Tickets
für verschiedene Veranstaltungen (z.B. Kino, Theater, Opern, Konzerte, usw.), sowie den
Verkauf von dazugehörigen Merchandising-Artikeln (beziehungsweise Fan-Artikel) speziali-
siert hat. In den Bundeshauptstädten gibt es hierzu Verkaufsstellen, in denen die Kunden
sich informieren und Karten, sowie Fan-Artikel direkt kaufen können.

Um die Verkaufsaktivitäten zu unterstützen, wurde ein eigenes IT-System namens Ticket-
line Kassa entwickelt, die von den Angestellten in den Verkaufsstellen benutzt wird. Es
wird dabei eine Client-Server-Architektur genutzt. Den Server-Teil bildet ein zentrale Da-
tenbank, die im Rechenzentrum des Unternehmens betrieben wird. Die Clients sind Rich
Client-Applikationen, die auf den Computern der Verkäufer installiert sind und alle auf die
zentrale Datenbank zugreifen.

Da die bestehende Client-Applikation auf einer veralteten Technologie basiert und die War-
tung, sowie Weiterentwicklung zu hohe Kosten verursacht, hat sich das Management ent-
schlossen, die Applikation zu ersetzen. Außerdem wurde beschlossen, dass Ticketline nicht
nur eine firmeninterne Applikation für Mitarbeiter sein soll, sondern auch in Form eines Web-
shops direkt für Kunden verfügbar sein soll. Nach einer Evaluierung verschiedener Technolo-
gien, wurde die Wahl getroffen, Java SE, Spring und Angular als neue Plattform zu nutzen.
Als Server soll ein Apache Tomcat verwendet werden, der die Ticketline-Funktionalitäten
mittels REST-Interfaces zur Verfügung stellt. Wesentliches Ziel bei der Neuentwicklung ist
dabei die Abläufe innerhalb der Applikation zu verbessern, um einen schnellen, reibungslosen
und direkten Verkauf von Tickets und Artikeln an die Kunden zu gewährleisten.


## 2 User Stories
[Hier geht es zu den User Stories](user-stories.md)


## 3 Nicht-funktionale Anforderungen

Im folgenden werden nicht-funktionale Anforderungen beziehungsweise Randbedingungen,
die die Architektur der Applikation beeinflussen, beschrieben. Wichtig dabei ist, dass die
nicht-funktionalen Anforderungen auch messbar sind.

### 3.1 Anforderungen an Usability

Für die Usability sollen Sie eigene Anforderungen ausarbeiten.
Ein Beispiel für eine schlecht formulierte Anforderungwäre: „Das Programm soll einfach zu
bedienen sein.“
Ein Beispiel für eine gut formulierte Anforderungwäre: „Jede Kernfunktionalität (Kaufen
eines Tickets, Kundenregistrierung, ...) soll mit maximal fünf Klicks abgeschlossen werden.“

### 3.2 Anforderungen an Performance

Generell müssen Sie für die Performancetests ein realistisches Set an Testdaten verwenden.
Dieses umfasst mindestens 1000 Kunden, 1000 Verkäufe sowie 200 Veranstaltungen an min-
destens 25 Orten. (Die Testdaten müssen dabei keine „sinnvollen“ Daten sein.)

Weitere Anforderungen an Performance sollen Sie selbst ausarbeiten.
Ein Beispiel für eine schlecht formulierte Anforderungwäre: „Die Anwendung muss schnell
reagieren.“
Ein Beispiel für eine gut formulierte Anforderungwäre: „Jede Operation muss in maximal
drei Sekunden zu einem für den User sichtbaren Ergebnis führen.“

### 3.3 Anforderungen an Security

#### 3.3.1 SQL-Injection

Die Anwendung muss gegen SQL-Injection geschützt sein.

#### 3.3.2 Berechtigungen

Jeder User darf nur die seiner Rolle zugänglichen Operationen ausführen können.

#### 3.3.3 Kryptographie

Weder Passwörter noch Zahlungsinformationen dürfen im Klartext gespeichert werden.


