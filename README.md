# HDMI_to_TTL

HDMI-Ausgang für das R1gol DS1054Z: Das parallele 24-Bit-RGB-Signal (800 × 480), das vom Mainboard zum internen Display geht, wird abgegriffen und von einem **Tang Nano 9K** (Gowin GW1NR-9C) in ein HDMI-Signal umgewandelt.

*HDMI output for the R1gol DS1054Z: the parallel 24-bit RGB signal (800 × 480) running from the mainboard to the internal display is tapped and converted into an HDMI signal by a **Tang Nano 9K** (Gowin GW1NR-9C).*

Diese Anleitung beschreibt, wie die Platine bestückt und der FPGA programmiert wird.

*This guide describes how to assemble the board and program the FPGA.*

> ⚠️ **Haftungsausschluss:** Nachbau, Programmierung und Einbau erfolgen **auf eigene Gefahr**. Für das Öffnen des Oszilloskops wird ein Eingriff in das Gerät nötig, der zum Verlust der Garantie führen kann. Für Schäden am Oszilloskop, am Tang Nano 9K, an angeschlossenen Geräten oder sonstige Folgeschäden wird **keine Haftung übernommen**.
>
> *⚠️ **Disclaimer:** Building, programming and installing this modification is done **at your own risk**. Opening the oscilloscope requires modifying the device, which may void its warranty. **No liability is accepted** for damage to the oscilloscope, the Tang Nano 9K, connected devices or any other consequential damage.*

---

## Inhalt / *Contents*

1. [Benötigte Teile / *Required parts*](#1-benötigte-teile--required-parts)
2. [Die Platine / *The PCB*](#2-die-platine--the-pcb)
3. [Platine trennen / *Breaking the PCB apart*](#3-platine-trennen--breaking-the-pcb-apart)
4. [Tang Nano 9K bestücken / *Mounting the Tang Nano 9K*](#4-tang-nano-9k-bestücken--mounting-the-tang-nano-9k)
5. [FPGA programmieren / *Programming the FPGA*](#5-fpga-programmieren--programming-the-fpga)
6. [Einbau ins Oszilloskop / *Installation in the oscilloscope*](#6-einbau-ins-oszilloskop--installation-in-the-oscilloscope)
7. [Fehlersuche (LEDs und UART) / *Troubleshooting (LEDs and UART)*](#7-fehlersuche-leds-und-uart--troubleshooting-leds-and-uart)

---

## 1. Benötigte Teile / *Required parts*

| Teil / *Part* | Bemerkung / *Notes* |
|---|---|
| Platine `TTL_to_HDMI`<br>*PCB `TTL_to_HDMI`* | Display-Teil und FPGA-Teil hängen als ein Nutzen zusammen<br>*Display part and FPGA part come as one panel* |
| Tang Nano 9K | Sipeed, FPGA GW1NR-LV9QN88PC6/I5 |
| 2 × Stiftleiste 1 × 24, Raster 2,54 mm<br>*2 × pin header 1 × 24, 2.54 mm pitch* | für den Tang Nano 9K (liegen dem Board meist bei)<br>*for the Tang Nano 9K (usually included with the board)* |
| Buchsenleiste 1 × 2, Raster 2,54 mm<br>*Female header 1 × 2, 2.54 mm pitch* | J1, holt die 5 V von der Stiftleiste des Mainboards<br>*J1, picks up 5 V from the mainboard pin header* |
| FFC-Kabel 50-polig, Raster 0,5 mm<br>*FFC cable 50-pin, 0.5 mm pitch* | verbindet Mainboard und Display-Teil („To Mainboard“)<br>*connects mainboard and display part ("To Mainboard")* |
| FFC-Kabel 35-polig, Raster 0,5 mm<br>*FFC cable 35-pin, 0.5 mm pitch* | verbindet Display-Teil (J5) und FPGA-Teil (J3)<br>*connects display part (J5) and FPGA part (J3)* |
| HDMI-Einbau-Verlängerung mit 90°-Winkelstecker<br>*Panel-mount HDMI extension with 90° angled plug* | Buchse zum Festschrauben im Gehäuse, Stecker in den Tang Nano 9K (siehe [Abschnitt 6.3](#63-hdmi-buchse-im-gehäuse--hdmi-socket-in-the-housing))<br>*socket is screwed into the housing, plug goes into the Tang Nano 9K (see [section 6.3](#63-hdmi-buchse-im-gehäuse--hdmi-socket-in-the-housing))* |
| Isolierband und/oder Kapton-Band<br>*Insulating tape and/or Kapton tape* | zum Fixieren des FPGA-Teils auf dem Mainboard und zum Isolieren des Display-Teils gegen das Metallgehäuse<br>*to fix the FPGA part on the mainboard and to insulate the display part from the metal housing* |
| USB-C-Kabel<br>*USB-C cable* | **nur** zum Programmieren, solange das Board noch nicht eingebaut ist<br>***only** for programming, while the board is not yet installed* |
| PC mit **Gowin EDA / Gowin Programmer**<br>*PC with **Gowin EDA / Gowin Programmer*** | getestet mit Version V1.9.11.03 Education<br>*tested with version V1.9.11.03 Education* |

Die Display-Platine ist bereits mit SMD-Bauteilen bestückt (74HC245-Puffer U4, U6, U7, U8, Widerstände, Kondensatoren, FFC-Stecker).

*The display PCB comes pre-assembled with SMD parts (74HC245 buffers U4, U6, U7, U8, resistors, capacitors, FFC connectors).*

---

## 2. Die Platine / *The PCB*

Die Platine wird als ein Stück geliefert. Links sitzt der FPGA-Teil, rechts der Display-Teil, dazwischen eine Sollbruchstelle.

*The PCB is delivered as one piece. The FPGA part is on the left, the display part on the right, with a break-off line in between.*

**Oberseite** – mit QR-Code, FFC-Steckern und den SMD-Bauteilen:

***Top side** – with QR code, FFC connectors and the SMD parts:*

![Platine Oberseite / PCB top side](Pictures/Ordering_1.png)

**Unterseite** – hier ist die Umrisslinie des Tang Nano 9K inklusive Lage der HDMI-Buchse aufgedruckt:

***Bottom side** – the outline of the Tang Nano 9K, including the position of the HDMI socket, is printed here:*

![Platine Unterseite / PCB bottom side](Pictures/Ordering_2.png)

---

## 3. Platine trennen / *Breaking the PCB apart*

Die beiden Teile an der Sollbruchstelle vorsichtig auseinanderbrechen und die Bruchkante bei Bedarf leicht entgraten.

*Carefully break the two parts apart along the break-off line and deburr the edge slightly if necessary.*

**Display-Teil** – kommt ins Oszilloskop zwischen Mainboard und Display. U1/U2 sind die 50-poligen Display-Stecker, J5 ist der 35-polige Anschluss zum FPGA-Teil:

***Display part** – goes into the oscilloscope between mainboard and display. U1/U2 are the 50-pin display connectors, J5 is the 35-pin connection to the FPGA part:*

![Display-Teil / Display part](Pictures/Break_DISPLAY.png)

**FPGA-Teil** – Oberseite mit J3 (35-polig, zum Display-Teil) und J1 (+5 V / GND):

***FPGA part** – top side with J3 (35-pin, to the display part) and J1 (+5 V / GND):*

![FPGA-Teil Oberseite / FPGA part top side](Pictures/Break_FPGA_2.png)

---

## 4. Tang Nano 9K bestücken / *Mounting the Tang Nano 9K*

Der Tang Nano 9K wird auf der **Unterseite** des FPGA-Teils montiert, also auf der Seite mit der aufgedruckten Umrisslinie (nicht auf der QR-Code-Seite).

*The Tang Nano 9K is mounted on the **bottom side** of the FPGA part, i.e. the side with the printed outline (not the QR code side).*

1. Die beiden Stiftleisten (1 × 24) in den Tang Nano 9K stecken.<br>
   *Insert the two pin headers (1 × 24) into the Tang Nano 9K.*
2. Den Tang Nano 9K so auf die Unterseite der Platine setzen, dass er **in der Umrisslinie** liegt:<br>
   *Place the Tang Nano 9K on the bottom side of the PCB so that it sits **inside the outline**:*
   - die **HDMI-Buchse** zeigt zur Bruchkante (Aufdruck „HDMI“),<br>
     *the **HDMI socket** faces the break-off edge (marking "HDMI"),*
   - die **USB-C-Buchse** zeigt zur Seite mit J1 / J2.<br>
     *the **USB-C socket** faces the side with J1 / J2.*
3. Die Stifte stehen dann auf der Oberseite (QR-Code-Seite) durch und werden dort verlötet.<br>
   *The pins then stick out on the top side (QR code side) and are soldered there.*
4. Zuerst nur je einen Pin an beiden Enden löten, Lage prüfen (Board liegt plan und gerade in der Umrisslinie), dann die restlichen Pins löten.<br>
   *First solder only one pin at each end, check the position (board lies flat and straight inside the outline), then solder the remaining pins.*
5. Überstehende Stifte auf der Oberseite kürzen, damit sie später nichts berühren.<br>
   *Trim the protruding pins on the top side so they don't touch anything later.*

So sieht das bestückte FPGA-Teil aus (Unterseite, noch vor dem Trennen):

*This is what the assembled FPGA part looks like (bottom side, before breaking apart):*

![Tang Nano 9K auf der Platine / Tang Nano 9K on the PCB](Pictures/Populate_FPGA.png)

Und nach dem Trennen:

*And after breaking apart:*

![Bestücktes FPGA-Teil / Assembled FPGA part](Pictures/Break_FPGA_1.png)

6. Die Buchsenleiste **J1** (1 × 2, +5 V / GND) auf derselben Seite wie den Tang Nano 9K einlöten, also auf der Unterseite. Sie wird beim Einbau auf die Stiftleiste des Mainboards gesteckt (siehe [Abschnitt 6.2](#62-fpga-teil-auf-dem-mainboard-befestigen--mounting-the-fpga-part-on-the-mainboard)).<br>
   *Solder the female header **J1** (1 × 2, +5 V / GND) on the same side as the Tang Nano 9K, i.e. the bottom side. During installation it is plugged onto the mainboard pin header (see [section 6.2](#62-fpga-teil-auf-dem-mainboard-befestigen--mounting-the-fpga-part-on-the-mainboard)).*

> **Hinweis:** J2 („ONLY DUMMY“, 2 × 9) wird **nicht** bestückt. Die Löcher dienen nur als Freiraum für die übrigen Pins der Mainboard-Stiftleiste.
>
> ***Note:** J2 ("ONLY DUMMY", 2 × 9) is **not** populated. Its holes only provide clearance for the remaining pins of the mainboard pin header.*

Belegung von J1 (auch auf dem Bestückungsdruck markiert):

*Pinout of J1 (also marked on the silkscreen):*

| J1 Pin | Signal |
|---|---|
| 1 (eckiges Pad / *square pad*) | GND |
| 2 | +5 V |

![Belegung J1 und J2 / Pinout J1 and J2](Pictures/J1_J2_Pinout.png)

---

## 5. FPGA programmieren / *Programming the FPGA*

> ⚠️ **Wichtig:** Der Tang Nano 9K muss **vor dem Einbau** ins Oszilloskop fertig programmiert werden. Programmiert wird ausschließlich außerhalb des Geräts – das FPGA-Teil darf dabei **nicht** mit dem Oszilloskop verbunden sein.
>
> *⚠️ **Important:** The Tang Nano 9K must be fully programmed **before installation** in the oscilloscope. Programming is done exclusively outside the device – the FPGA part must **not** be connected to the oscilloscope while doing so.*

Die fertige Konfigurationsdatei liegt im Repository unter:

*The ready-to-use configuration file is located in the repository at:*

```
Software/hdmi_letzter_Ki_Stand/impl/pnr/hdmi.fs
```

Wer das Projekt selbst neu bauen will, öffnet `Software/hdmi_letzter_Ki_Stand/hdmi.gprj` in der Gowin EDA und führt *Synthesize* und *Place & Route* aus – danach liegt die `hdmi.fs` an derselben Stelle.

*If you want to rebuild the project yourself, open `Software/hdmi_letzter_Ki_Stand/hdmi.gprj` in Gowin EDA and run **Synthesize** and **Place & Route** – the `hdmi.fs` will then be created at the same location.*

### 5.1 Programmer starten und Board erkennen / *Start the programmer and detect the board*

1. Tang Nano 9K per USB-C mit dem PC verbinden.<br>
   *Connect the Tang Nano 9K to the PC via USB-C.*
2. **Gowin Programmer** starten (entweder einzeln oder in der Gowin EDA über *Tools → Programmer*).<br>
   *Start the **Gowin Programmer** (either standalone or in Gowin EDA via **Tools → Programmer**).*
3. Mit dem Lupen-Symbol (**Scan Device**) nach dem Board suchen. Es sollte ein Eintrag mit<br>
   *Search for the board using the magnifying glass icon (**Scan Device**). An entry with*
   - Series: `GW1NR`
   - Device: `GW1NR-9C`

   erscheinen. Standardmäßig steht als Operation `SRAM Program` drin.<br>
   *should appear. By default the operation is set to `SRAM Program`.*

![Gowin Programmer – Board erkannt / board detected](Software/Programming_1.png)

> `SRAM Program` lädt die Konfiguration nur in den flüchtigen Speicher – nach dem Ausschalten ist sie wieder weg. Damit der FPGA die Konfiguration dauerhaft behält, muss in den internen Flash geschrieben werden (nächster Schritt).
>
> *`SRAM Program` only loads the configuration into volatile memory – it is lost after power-off. For the FPGA to keep the configuration permanently, it has to be written to the internal flash (next step).*

### 5.2 Flash-Programmierung einstellen / *Set up flash programming*

1. Doppelklick auf die Zeile (Spalte **Operation**) – das Fenster **Device configuration** öffnet sich.<br>
   *Double-click the row (column **Operation**) – the **Device configuration** window opens.*
2. Einstellen:<br>
   *Set:*
   - **Access Mode:** `Embedded Flash Mode`
   - **Operation:** `embFlash Erase,Program`
3. Unter **File name** die Datei `hdmi.fs` auswählen (Pfad siehe oben).<br>
   *Under **File name**, select the file `hdmi.fs` (path see above).*
4. Mit **Save** bestätigen.<br>
   *Confirm with **Save**.*

![Device configuration – Embedded Flash](Software/Programming_2.png)

### 5.3 Programmieren / *Program*

In der Liste steht jetzt als Operation `embFlash Erase,Program` und als FS File der Pfad zur `hdmi.fs`:

*The list now shows `embFlash Erase,Program` as operation and the path to `hdmi.fs` as FS file:*

![Bereit zum Programmieren / Ready to program](Software/Programming_3.png)

1. Auf das Symbol mit dem grünen Pfeil (**Program/Configure**) klicken.<br>
   *Click the icon with the green arrow (**Program/Configure**).*
2. Warten, bis im Output-Fenster unten die erfolgreiche Programmierung gemeldet wird.<br>
   *Wait until the output window at the bottom reports successful programming.*
3. Fertig – der FPGA startet ab jetzt bei jedem Einschalten mit der HDMI-Konfiguration.<br>
   *Done – from now on the FPGA starts with the HDMI configuration every time it is powered on.*
4. USB-C-Kabel wieder abziehen. Erst jetzt darf das Board eingebaut werden.<br>
   *Unplug the USB-C cable. Only now may the board be installed.*

> **Board wird nicht gefunden?** Unter **USB Cable Setting** prüfen, ob das Kabel erkannt wird, und ggf. *Query/Detect Cable* ausführen. Unter Windows wird ein passender USB-Treiber benötigt (wird mit der Gowin-Software installiert).
>
> ***Board not found?** Check under **USB Cable Setting** whether the cable is detected and run **Query/Detect Cable** if necessary. On Windows a suitable USB driver is required (installed together with the Gowin software).*

---

## 6. Einbau ins Oszilloskop / *Installation in the oscilloscope*

> ⚠️ Der Einbau erfolgt **auf eigene Gefahr**, es wird **keine Haftung** übernommen. Vor dem Öffnen das Oszilloskop ausschalten und vom Netz trennen.
>
> *⚠️ Installation is done **at your own risk**, **no liability** is accepted. Switch off the oscilloscope and disconnect it from mains before opening it.*

Voraussetzung: Der Tang Nano 9K ist fertig programmiert (siehe [Abschnitt 5](#5-fpga-programmieren--programming-the-fpga)) und das USB-C-Kabel ist abgezogen.

*Prerequisite: the Tang Nano 9K is fully programmed (see [section 5](#5-fpga-programmieren--programming-the-fpga)) and the USB-C cable is unplugged.*

### 6.1 Display-Teil einsetzen / *Installing the display part*

Das Display-Teil wird zwischen Display und **Metallgehäuse** gelegt und in die Verbindung zwischen Mainboard und Display eingeschleift.

*The display part is placed between the display and the **metal housing** and inserted into the connection between mainboard and display.*

> ⚠️ Die Seite des Display-Teils, die zum Metallgehäuse zeigt, mit Isolierband oder Kapton-Band abkleben, damit Lötstellen und Bauteile keinen Kurzschluss zum Gehäuse bekommen.
>
> *⚠️ Cover the side of the display part facing the metal housing with insulating tape or Kapton tape, so that solder joints and components cannot short against the housing.*

1. Das originale Display-Flachbandkabel vom Display abziehen.<br>
   *Unplug the original display ribbon cable from the display.*
2. Das neue **50-polige FFC-Kabel** (Raster 0,5 mm) in den Display-Stecker des **Mainboards** und in den oberen 50-poligen Stecker des Display-Teils („To Mainboard“) stecken.<br>
   *Plug the new **50-pin FFC cable** (0.5 mm pitch) into the display connector of the **mainboard** and into the upper 50-pin connector of the display part ("To Mainboard").*
3. Das Kabel des Displays in den mittleren 50-poligen Stecker („To Display“) stecken.<br>
   *Plug the display cable into the middle 50-pin connector ("To Display").*
4. Das 35-polige FFC-Kabel in den unteren Stecker J5 („To FPGA“) stecken und zum FPGA-Teil führen.<br>
   *Plug the 35-pin FFC cable into the lower connector J5 ("To FPGA") and route it to the FPGA part.*
5. Das Display-Teil (Seite zum Metall isoliert) zwischen Display und Metallgehäuse einlegen.<br>
   *Place the display part (side facing the metal insulated) between display and metal housing.*

![Lage des Display-Teils / Position of the display part](Pictures/DISPLAY_PCB.png)

### 6.2 FPGA-Teil auf dem Mainboard befestigen / *Mounting the FPGA part on the mainboard*

Das FPGA-Teil liegt auf dem Mainboard, mit der QR-Code-Seite nach oben (der Tang Nano 9K zeigt also zum Mainboard), und wird mit Isolierband fixiert.

*The FPGA part lies on the mainboard with the QR code side facing up (so the Tang Nano 9K faces the mainboard) and is fixed with insulating tape.*

1. Das andere Ende des 35-poligen FFC-Kabels in J3 des FPGA-Teils stecken.<br>
   *Plug the other end of the 35-pin FFC cable into J3 of the FPGA part.*
2. Das FPGA-Teil an der gezeigten Stelle auf das Mainboard legen und dabei auf die Stiftleiste des Mainboards neben dem Summer stecken (roter Kreis im Bild unten). Die Stiftleiste liegt dann unter J2 und J1 zusammen: Die Löcher von J2 nehmen die übrigen Pins auf, die Buchsenleiste **J1** greift die beiden Pins für **GND** (J1 Pin 1) und **+5 V** (J1 Pin 2) ab. Darüber wird das FPGA-Teil mit 5 V aus dem Oszilloskop versorgt.<br>
   *Place the FPGA part on the mainboard at the position shown, plugging it onto the mainboard pin header next to the buzzer (red circle in the picture below). The pin header then sits under J2 and J1 together: the holes of J2 take the remaining pins, the female header **J1** picks up the two pins for **GND** (J1 pin 1) and **+5 V** (J1 pin 2). This supplies the FPGA part with 5 V from the oscilloscope.*

   > Vor dem ersten Einschalten mit einem Multimeter prüfen, ob die Platine richtig und nicht versetzt aufgesteckt ist und an J1 tatsächlich +5 V gegen GND anliegen.
   >
   > *Before powering on for the first time, use a multimeter to check that the board is plugged on correctly and not offset, and that +5 V against GND is actually present at J1.*
3. Darauf achten, dass die gekürzten Pins und die Bauteile des Tang Nano 9K keinen Kontakt zu Bauteilen oder Leiterbahnen des Mainboards haben.<br>
   *Make sure that the trimmed pins and the components of the Tang Nano 9K do not touch any components or traces of the mainboard.*
4. Das FPGA-Teil mit Isolierband auf dem Mainboard fixieren.<br>
   *Fix the FPGA part on the mainboard with insulating tape.*

![5-V-Abgriff an der Stiftleiste des Mainboards / 5 V tap at the mainboard pin header](Pictures/Eingebaut_5V.png)

![Lage des FPGA-Teils – 3D-Ansicht / Position of the FPGA part – 3D view](Pictures/Eingebaut_1.png)

![Lage des FPGA-Teils – Draufsicht / Position of the FPGA part – top view](Pictures/Eingebaut_2.png)

So sieht es eingebaut aus. Links und rechts hält Isolierband die Platine, unten kommt das FFC-Kabel vom Display-Teil, rechts geht das HDMI-Kabel ab:

*This is what it looks like installed. Insulating tape holds the board on the left and right, the FFC cable from the display part comes in at the bottom, the HDMI cable leaves to the right:*

![FPGA-Teil eingebaut / FPGA part installed](Pictures/Eingebaut.jpg)

### 6.3 HDMI-Buchse im Gehäuse / *HDMI socket in the housing*

Damit das HDMI-Signal nach außen kommt, wird eine kurze HDMI-Einbau-Verlängerung verwendet: Auf der einen Seite ist ein 90°-Winkelstecker, auf der anderen eine Buchse mit zwei Schraublaschen.

*To bring the HDMI signal outside, a short panel-mount HDMI extension is used: one end has a 90° angled plug, the other a socket with two screw tabs.*

![HDMI-Einbau-Verlängerung / Panel-mount HDMI extension](Pictures/HDMI_example.png)

1. Den Winkelstecker in die HDMI-Buchse des Tang Nano 9K stecken.<br>
   *Plug the angled plug into the HDMI socket of the Tang Nano 9K.*
2. Die Position der Buchse in der Gehäuserückwand anzeichnen (oberhalb von USB-B und LAN), Ausschnitt und zwei Bohrungen für die Schrauben anfertigen.<br>
   *Mark the position of the socket on the rear housing (above USB-B and LAN), then make the cut-out and two holes for the screws.*
3. Die Buchse von innen einsetzen und festschrauben.<br>
   *Insert the socket from the inside and screw it in place.*
4. Gehäuse wieder schließen.<br>
   *Close the housing again.*

![HDMI-Buchse in der Gehäuserückwand / HDMI socket in the rear housing](Pictures/Output.jpg)

### 6.4 Inbetriebnahme / *Commissioning*

1. Monitor an die neue HDMI-Buchse anschließen.<br>
   *Connect a monitor to the new HDMI socket.*
2. Oszilloskop einschalten – das Bild erscheint parallel auf dem internen Display und auf dem Monitor.<br>
   *Switch on the oscilloscope – the image appears on the internal display and on the monitor at the same time.*

> ⚠️ **Keine Versorgung über USB-C!** Im eingebauten Zustand darf am Tang Nano 9K **kein USB-C-Kabel** angeschlossen werden. Die 5 V kommen ausschließlich aus dem Oszilloskop über J1. Ein zusätzlich angeschlossenes USB-Kabel würde zwei 5-V-Quellen gegeneinander schalten und kann Oszilloskop, Tang Nano 9K oder den PC beschädigen.
>
> *⚠️ **No power via USB-C!** When installed, **no USB-C cable** may be connected to the Tang Nano 9K. The 5 V come exclusively from the oscilloscope via J1. An additionally connected USB cable would connect two 5 V sources against each other and can damage the oscilloscope, the Tang Nano 9K or the PC.*

Der FPGA erzeugt den HDMI-Takt selbst aus dem 27-MHz-Oszillator des Tang Nano 9K (Ausgabe 1579 × 525 bei 36 MHz Pixeltakt). Das Eingangsbild wird zwischengepuffert, die Bildrate des Oszilloskops bleibt erhalten.

*The FPGA generates the HDMI clock itself from the 27 MHz oscillator of the Tang Nano 9K (output 1579 × 525 at 36 MHz pixel clock). The input image is buffered and the oscilloscope's frame rate is preserved.*

---

## 7. Fehlersuche (LEDs und UART) / *Troubleshooting (LEDs and UART)*

### LEDs auf dem Tang Nano 9K / *LEDs on the Tang Nano 9K*

| LED | leuchtet, wenn … / *lit when …* |
|---|---|
| 0 | Eingangspuffer (74HC245) freigegeben<br>*input buffer (74HC245) enabled* |
| 1 | Pixeltakt (PCLK) vom Oszilloskop vorhanden<br>*pixel clock (PCLK) from the oscilloscope present* |
| 2 | PLL eingerastet<br>*PLL locked* |
| 3 | HSYNC vorhanden<br>*HSYNC present* |
| 4 | Bilder (DE) werden empfangen<br>*frames (DE) are being received* |
| 5 | Testbild-Modus aktiv<br>*test pattern mode active* |

### UART-Konsole / *UART console*

Über den USB-Anschluss des Tang Nano 9K steht eine serielle Konsole zur Verfügung (**115200 Baud, 8N1**). Sie gibt jede Sekunde eine Statuszeile mit den gemessenen Eingangssignalen aus.

*A serial console is available via the USB port of the Tang Nano 9K (**115200 baud, 8N1**). It prints a status line with the measured input signals every second.*

> ⚠️ Die Konsole nur **außerhalb des Oszilloskops** nutzen (Board nur über USB versorgt, nicht mit dem Oszilloskop verbunden) – siehe Warnung in [Abschnitt 6](#6-einbau-ins-oszilloskop--installation-in-the-oscilloscope).
>
> *⚠️ Only use the console **outside the oscilloscope** (board powered via USB only, not connected to the oscilloscope) – see the warning in [section 6](#6-einbau-ins-oszilloskop--installation-in-the-oscilloscope).*

| Befehl / *Command* | Funktion / *Function* |
|---|---|
| `t` | Testbild ein/aus (gleiches HDMI-Timing wie im Normalbetrieb)<br>*test pattern on/off (same HDMI timing as in normal operation)* |
| `?` | Hilfe<br>*help* |

Mit dem Testbild lässt sich vor dem Einbau prüfen, ob die HDMI-Ausgabe funktioniert: Board per USB anschließen, Monitor an HDMI, in der Konsole `t` senden.

*The test pattern lets you check before installation whether the HDMI output works: connect the board via USB, connect a monitor to HDMI, send `t` in the console.*

---

## Links

- GitHub: https://github.com/theBrutzler/HDMI_to_TTL
- Twitch: https://www.twitch.tv/thebrutzler
- Ko-fi: https://ko-fi.com/thebrutzler
