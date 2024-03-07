BEGIN
  FOR cur_tab IN (SELECT table_name FROM user_tables) LOOP
    BEGIN
        EXECUTE IMMEDIATE 'DROP TABLE ' || cur_tab.table_name || ' CASCADE CONSTRAINTS';
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE != -942 THEN
                RAISE;
            END IF;
    END;
  END LOOP;
END;

BEGIN
  FOR cur_triger IN
    (SELECT * FROM ALL_TRIGGERS
    WHERE OWNER = 'XVETLU00' OR OWNER = 'XBORSH00')
    LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP TRIGGER ' || cur_triger.TRIGGER_NAME;
        EXCEPTION
            WHEN OTHERS THEN
                IF SQLCODE != -942 THEN
                    RAISE;
                END IF;
        END;
  END LOOP;
END;

CREATE TABLE obec(

    o_cislo INTEGER PRIMARY KEY NOT NULL,

    nazev VARCHAR(20) NOT NULL

);

CREATE TABLE letiste(
    l_cislo INTEGER PRIMARY KEY NOT NULL,

    o_cislo INTEGER,
    FOREIGN KEY (o_cislo) REFERENCES obec(o_cislo),

    nazev VARCHAR(20) NOT NULL,
    kod CHAR(3) NOT NULL,
    typ_letiste VARCHAR(20)

);

CREATE TABLE letovy_itinerar(

    lt_cislo INTEGER PRIMARY KEY NOT NULL,

    letiste_odletu INTEGER,
    letiste_priletu INTEGER,
    FOREIGN KEY (letiste_odletu) REFERENCES letiste(l_cislo),
    FOREIGN KEY (letiste_priletu) REFERENCES letiste(l_cislo),

    datum_a_cas_priletu TIMESTAMP,
    datum_a_cas_odletu TIMESTAMP,
    posledni_zmena TIMESTAMP,
    stav VARCHAR(20)

);

CREATE TABLE Osoba (

    Osoba_Cislo INTEGER PRIMARY KEY NOT NULL,

    Jmeno VARCHAR(255) NOT NULL,
    Prijmeni VARCHAR(255) NOT NULL,
    Statni_prislusnost VARCHAR(255) NOT NULL,
    Datum_narozeni DATE NOT NULL,
    Cestovni_pas VARCHAR(20) NOT NULL,
    --Y or N
    Vyskyt_v_cerne_listine CHAR(1) NOT NULL

);

 /*
 Pro reprezentaci generalizace jsme si vybrali 1. moznost.
 Vytvorili jsme tabulku nadtypu a tabulku podtypu.
 Podtyp obsahuje primarni klic nadtypu.
*/

CREATE TABLE Registrovana_osoba (

    Osoba_Cislo INTEGER NOT NULL PRIMARY KEY,

    FOREIGN KEY (Osoba_Cislo) REFERENCES Osoba(Osoba_Cislo),

    Telefon VARCHAR(12) NOT NULL,
    Email VARCHAR(320) NOT NULL, --nejdelsi mozny email
    Heslo VARCHAR(255) NOT NULL,
    Token VARCHAR(255) NOT NULL,
    Metoda_platby VARCHAR(20) NOT NULL

);

CREATE TABLE Rezervace (

    Rezervace_Cislo INTEGER NOT NULL PRIMARY KEY,

    Osoba_Cislo INTEGER NOT NULL,
    FOREIGN KEY (Osoba_Cislo) REFERENCES Osoba (Osoba_Cislo),

    Stav VARCHAR(25) NOT NULL

);

CREATE TABLE Letenka (

    Letenka_Cislo INTEGER NOT NULL PRIMARY KEY,

    Rezervace_Cislo INTEGER NOT NULL,
    FOREIGN KEY (Rezervace_Cislo) REFERENCES Rezervace (Rezervace_Cislo),

    Cena INTEGER NOT NULL,
    Stav VARCHAR(15) NOT NULL,
    Covid_doklad VARCHAR(255)

);

CREATE TABLE Spolecnost (

    DICH CHAR (10) NOT NULL PRIMARY KEY,
    CHECK (upper(substr(DICH,1,2)) = 'CZ'),

    Nazev varchar(255) NOT NULL,
    logo VARCHAR(255)

);

CREATE TABLE Letadlo (

    Seriove_cislo INTEGER NOT NULL PRIMARY KEY,

    DICH CHAR (10) NOT NULL,
    FOREIGN KEY (DICH) REFERENCES Spolecnost (DICH),

    Typ_letadla varchar(30)


);

CREATE INDEX Idx_Letadlo ON Letadlo (Typ_letadla);

CREATE TABLE Let (

    Let_cislo INTEGER NOT NULL PRIMARY KEY,

    Seriove_cislo INTEGER NOT NULL,
    lt_cislo INTEGER NOT NULL,
    DICH CHAR(10) NOT NULL,
    FOREIGN KEY (Seriove_cislo) REFERENCES Letadlo (Seriove_cislo),
    FOREIGN KEY (lt_cislo) REFERENCES letovy_itinerar (lt_cislo),
    FOREIGN KEY (DICH) REFERENCES Spolecnost (DICH)

);


CREATE TABLE Palubni_Listek (

    Palubni_Listek_Cislo INTEGER NOT NULL PRIMARY KEY,

    Letenka_Cislo INTEGER NOT NULL,
    Let_cislo INTEGER NOT NULL,
    FOREIGN KEY (Letenka_Cislo) REFERENCES Letenka (Letenka_Cislo),
    FOREIGN KEY (Let_cislo) REFERENCES Let (Let_cislo),

    Check_in CHAR(1) NOT NULL,
    Gate INTEGER NOT NULL

);

CREATE TABLE Sluzba (

    Sluzba_cislo INTEGER NOT NULL PRIMARY KEY,

    Nazev varchar(255) NOT NULL,
    Cena INTEGER NOT NULL,
    Dostupnost_sluzby CHAR(1) NOT NULL

);

CREATE TABLE Trida (

    ID_tridy INTEGER NOT NULL PRIMARY KEY,

    Nazev varchar(7) NOT NULL,
    Pocet_mist INTEGER NOT NULL

);

CREATE TABLE Sedadlo (

    Sedadlo_cislo INTEGER NOT NULL PRIMARY KEY ,

    ID_tridy INTEGER NOT NULL,
    FOREIGN KEY (ID_tridy) REFERENCES Trida (ID_tridy),

    Radek INTEGER NOT NULL,
    Misto CHAR(1) NOT NULL

);


--N to N Tables

CREATE TABLE Pridana_Sluzba (

    Sluzba_cislo INTEGER NOT NULL,
    Letenka_Cislo INTEGER NOT NULL,

    FOREIGN KEY (Sluzba_cislo) REFERENCES Sluzba(Sluzba_cislo),
    FOREIGN KEY (Letenka_Cislo) REFERENCES Letenka(Letenka_Cislo),
    CONSTRAINT PK_Pridana_Sluzba PRIMARY KEY (Sluzba_cislo, Letenka_Cislo),

    Uspesnost varchar(3) NOT NULL,
    Zahrnuto_v_cene varchar(3) NOT NULL,
    Pocet INTEGER NOT NULL

);

CREATE TABLE Osoba_Letenka (

    Osoba_Cislo INTEGER NOT NULL,
    Letenka_Cislo INTEGER NOT NULL,

    FOREIGN KEY (Osoba_Cislo) REFERENCES Osoba(Osoba_Cislo),
    FOREIGN KEY (Letenka_Cislo) REFERENCES Letenka (Letenka_Cislo),
    CONSTRAINT PK_Osoba_Letenka PRIMARY KEY (Osoba_Cislo, Letenka_Cislo)

);

CREATE TABLE Sedadlo_Palubni_listek (

    Sedadlo_Cislo INTEGER NOT NULL,
    Palubni_Listek_Cislo INTEGER NOT NULL,

    FOREIGN KEY (Sedadlo_Cislo) REFERENCES Sedadlo(Sedadlo_cislo),
    FOREIGN KEY (Palubni_Listek_Cislo) REFERENCES Palubni_Listek (Palubni_Listek_Cislo),
    CONSTRAINT PK_Sedadlo_Palubni_Listek PRIMARY KEY (Sedadlo_Cislo, Palubni_Listek_Cislo)

);

CREATE TABLE Trida_Letadlo (

    ID_tridy INTEGER NOT NULL,
    Seriove_cislo INTEGER NOT NULL,
    FOREIGN KEY (ID_tridy) REFERENCES Trida(ID_tridy),
    FOREIGN KEY (Seriove_cislo) REFERENCES Letadlo (Seriove_cislo),
    CONSTRAINT PK_Trida_Letadlo PRIMARY KEY (ID_tridy, Seriove_cislo)

);

CREATE TABLE Spolecnost_Letiste(

    DICH CHAR (10) NOT NULL,
    l_cislo INTEGER NOT NULL,
    FOREIGN KEY (DICH) REFERENCES Spolecnost (DICH) ,
    FOREIGN KEY (l_cislo) REFERENCES Letiste (l_cislo),
    CONSTRAINT PK_Spolecnost_Letiste PRIMARY KEY (DICH, l_cislo)

);


-- Inserting rows into the Osoba table
INSERT INTO Osoba (Osoba_Cislo, Jmeno, Prijmeni, Statni_prislusnost, Datum_narozeni, Cestovni_pas, Vyskyt_v_cerne_listine)
SELECT '1', 'Beren', 'Erhamion', 'Dortonion', TO_DATE('2000-06-10', 'YYYY-MM-DD'), 'Dorton', 'N' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Osoba WHERE Osoba_Cislo = '1')
UNION
SELECT '2', 'Earendil', 'Mariner', 'Gondolin', TO_DATE('2010-05-15', 'YYYY-MM-DD'), 'Gon', 'N' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Osoba WHERE Osoba_Cislo = '2')
UNION
SELECT '3', 'Feanor', 'Curufinwe', 'Valinor', TO_DATE('1960-08-23', 'YYYY-MM-DD'), 'Val', 'N' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Osoba WHERE Osoba_Cislo = '3')
UNION
SELECT '4', 'Hurin', 'Thalion', 'Dor-Lomin', TO_DATE('1995-03-06', 'YYYY-MM-DD'), 'Dol', 'N' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Osoba WHERE Osoba_Cislo = '4')
UNION
SELECT '5', 'Turin', 'Turambar', 'Dor-Lomin', TO_DATE('2000-04-12', 'YYYY-MM-DD'), 'Dol', 'N' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Osoba WHERE Osoba_Cislo = '5');

INSERT INTO Registrovana_osoba (Osoba_Cislo, Telefon, Email, Heslo, Token, Metoda_platby)
SELECT '1', '+3246578912', 'berenlutien@gmail.com', 'Silmaril', 'eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NSIsIm5hbWUiOiJKb2huIEdvbGQiLCJhZG1pbiI6dHJ1ZX0K.LIHjWCBORSWMEibq-tnT8ue_deUqZx1K0XxCOXZRrBI', 'VISA'
FROM dual WHERE NOT EXISTS (SELECT 1 FROM Registrovana_osoba WHERE Osoba_Cislo = '1')
UNION
SELECT '2', '+4946789723', 'earendilsea@gmail.com', 'Vingilote', 'oiJhbGciOiJIUzUxMiIsInR7cCI6IkpXVCJ9.ioJzdWIiOiIxMjM0NSIsIm5hbWUiOiJKb2huIEdgtGQiLCJhZG1pbiI6dHJ1ZX0K.LIHjWCBORSWMEibq-tnT8ue_deUqZx1K0XxCOXZTRGH', 'PayPal'
FROM dual WHERE NOT EXISTS (SELECT 1 FROM Registrovana_osoba WHERE Osoba_Cislo = '2')
UNION
SELECT '3', '+5446879723', 'protectsilmarils@gmail.com', 'Palantir', 'wvJFGHTY6iOiJIUzUxMiIsJGUY65fCI6IkpXVCJ9.ioJzdWIiOiIxMjM0NSIsIm5hbWUiOiJKb2huIEdgtGQiLCJhZG1p45673dHJ1ZX0K.LIHjWCBORSWMEibq-tnT8ue_deUqZx1K0XxCOXZIOyt', 'Mastercard'
FROM dual WHERE NOT EXISTS (SELECT 1 FROM Registrovana_osoba WHERE Osoba_Cislo = '3')
UNION
SELECT '4', '+6765432189', 'liftthecurse@gmail.com', 'Brethil', 'plJhbGciOiJIUzUxMiPOLJR7cCI6IkpXVCJ9.ioJzdWIiOiIxMjM0NSIsIm67ytriOiJKb2huIEdgtGQiLCKLO01pbiI6dHJ1ZX0K.LIHjWCBORSWMEibq-tnT8ue_deUqZx1K0XxCOXZAGT5', 'GooglePay'
FROM dual WHERE NOT EXISTS (SELECT 1 FROM Registrovana_osoba WHERE Osoba_Cislo = '4')
UNION ALL
SELECT '5', '+9061278437', 'glaurung@gmail.com', 'Kullervo', 'ytuiklciOiJIUzUxMiPOLJR7cCI6POI7XVCJ9.ioJzdWIiOiIxMjM0NSIsIm67ytriOiJKb2huAds5tGQiLCKLO01pbiI6dHJ1ZX0K.LIHjWCBORSWMEibq-tnT8ue_deUqZx1K0XxCOXZUOPK', 'ApplePay'
FROM dual WHERE NOT EXISTS (SELECT 1 FROM Registrovana_osoba WHERE Osoba_Cislo = '5');

INSERT INTO Rezervace (Rezervace_Cislo, Osoba_Cislo, Stav)
SELECT '1', '1', 'Reserved' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Rezervace WHERE Rezervace_Cislo = '1')
UNION
SELECT '2', '2', 'Reserved' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Rezervace WHERE Rezervace_Cislo = '2')
UNION
SELECT '3', '3', 'Reserved' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Rezervace WHERE Rezervace_Cislo = '3')
UNION
SELECT '4', '4', 'Not reserved' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Rezervace WHERE Rezervace_Cislo = '4')
UNION
SELECT '5', '5', 'Reserved' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Rezervace WHERE Rezervace_Cislo = '5');

INSERT INTO Letenka (Letenka_Cislo, Rezervace_Cislo, Cena, Stav, Covid_doklad)
SELECT '1', '1', '5000', 'Confirmed', 'Attached' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Letenka WHERE Letenka_Cislo = '1')
UNION
SELECT '2', '2', '7635', 'Not confirmed', 'Attached' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Letenka WHERE Letenka_Cislo = '2')
UNION
SELECT '3', '3', '6345', 'Not confirmed', 'Unattached' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Letenka WHERE Letenka_Cislo = '3')
UNION
SELECT '4', '4', '4200', 'Confirmed', 'Unattached' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Letenka WHERE Letenka_Cislo = '4')
UNION
SELECT '5', '5', '9000', 'Confirmed', 'Attached' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Letenka WHERE Letenka_Cislo = '5');

INSERT INTO obec (o_cislo, nazev)
SELECT '15', 'Doriat' FROM dual WHERE NOT EXISTS (SELECT 1 FROM obec WHERE o_cislo = '15')
UNION
SELECT '6', 'Beleriand' FROM dual WHERE NOT EXISTS (SELECT 1 FROM obec WHERE o_cislo = '6')
UNION
SELECT '29', 'Nargothrond' FROM dual WHERE NOT EXISTS (SELECT 1 FROM obec WHERE o_cislo = '29')
UNION
SELECT '66', 'Numenor' FROM dual WHERE NOT EXISTS (SELECT 1 FROM obec WHERE o_cislo = '66')
UNION
SELECT '93', 'Sirion' FROM dual WHERE NOT EXISTS (SELECT 1 FROM obec WHERE o_cislo = '93');


INSERT INTO letiste (l_cislo, o_cislo, nazev, kod, typ_letiste)
SELECT '3', '15', 'Melian', 'TBD', 'International' FROM dual WHERE NOT EXISTS (SELECT 1 FROM letiste WHERE l_cislo = '3')
UNION
SELECT '4', '6', 'Valinor', 'OUI', 'International' FROM dual WHERE NOT EXISTS (SELECT 1 FROM letiste WHERE l_cislo = '4')
UNION
SELECT '8', '29', 'Finrod', 'UOT', 'Domestic' FROM dual WHERE NOT EXISTS (SELECT 1 FROM letiste WHERE l_cislo = '8')
UNION
SELECT '53', '66', 'Elros', 'SUN', 'International' FROM dual WHERE NOT EXISTS (SELECT 1 FROM letiste WHERE l_cislo = '53')
UNION
SELECT '510', '93', 'Ectelion', 'PRO', 'Domestic' FROM dual WHERE NOT EXISTS (SELECT 1 FROM letiste WHERE l_cislo = '510');

INSERT INTO letovy_itinerar(lt_cislo, letiste_odletu, letiste_priletu, datum_a_cas_priletu, datum_a_cas_odletu, posledni_zmena, stav)
SELECT '12', '3', '4', TO_TIMESTAMP('2022-11-23 8:45:16', 'YYYY-MM-DD HH:MI:SS'), TO_TIMESTAMP('2022-11-23 3:34:23', 'YYYY-MM-DD HH:MI:SS'), TO_TIMESTAMP('2022-11-23 1:48:35', 'YYYY-MM-DD HH:MI:SS'), 'Registration' FROM dual WHERE NOT EXISTS (SELECT 1 FROM letovy_itinerar WHERE lt_cislo = '12')
UNION
SELECT '28', '53', '4', TO_TIMESTAMP('2023-04-15 5:31:12', 'YYYY-MM-DD HH:MI:SS'), TO_TIMESTAMP('2023-04-15 2:25:28', 'YYYY-MM-DD HH:MI:SS'), TO_TIMESTAMP('2022-04-15 1:12:52', 'YYYY-MM-DD HH:MI:SS'), 'Take off' FROM dual WHERE NOT EXISTS (SELECT 1 FROM letovy_itinerar WHERE lt_cislo = '28')
UNION
SELECT '40', '8', '510', TO_TIMESTAMP('2023-02-18 3:20:12', 'YYYY-MM-DD HH:MI:SS'), TO_TIMESTAMP('2023-02-19 1:13:47', 'YYYY-MM-DD HH:MI:SS'), TO_TIMESTAMP('2022-02-17 9:52:41', 'YYYY-MM-DD HH:MI:SS'), 'Boarding' FROM dual WHERE NOT EXISTS (SELECT 1 FROM letovy_itinerar WHERE lt_cislo = '40')
UNION
SELECT '786', '53', '3', TO_TIMESTAMP('2022-09-03 4:11:45', 'YYYY-MM-DD HH:MI:SS'), TO_TIMESTAMP('2022-09-03 8:35:28', 'YYYY-MM-DD HH:MI:SS'), TO_TIMESTAMP('2022-09-03 3:32:13', 'YYYY-MM-DD HH:MI:SS'), 'Registration' FROM dual WHERE NOT EXISTS (SELECT 1 FROM letovy_itinerar WHERE lt_cislo = '786')
UNION
SELECT '63', '510', '8', TO_TIMESTAMP('2022-05-23 1:46:57', 'YYYY-MM-DD HH:MI:SS'), TO_TIMESTAMP('2022-05-23 5:43:21', 'YYYY-MM-DD HH:MI:SS'), TO_TIMESTAMP('2022-05-22 5:34:39', 'YYYY-MM-DD HH:MI:SS'), 'Take off' FROM dual WHERE NOT EXISTS (SELECT 1 FROM letovy_itinerar WHERE lt_cislo = '63');

INSERT INTO Spolecnost (DICH, Nazev, logo)
SELECT 'CZ64532891', 'MiddleEarthAirlines', 'Torondor the Great' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Spolecnost WHERE DICH = 'CZ64532891')
UNION
SELECT 'CZ78465632', 'IluvatarFlights', 'Views of Valinor' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Spolecnost WHERE DICH = 'CZ78465632')
UNION
SELECT 'CZ90256277', 'TurgonPegases', 'Valley of Sirion' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Spolecnost WHERE DICH = 'CZ90256277');

INSERT INTO Letadlo (Seriove_cislo, DICH, Typ_letadla)
SELECT '264', 'CZ64532891', 'Passenger' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Letadlo WHERE Seriove_cislo = '264')
UNION
SELECT '592', 'CZ78465632', 'Personal' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Letadlo WHERE Seriove_cislo = '592')
UNION
SELECT '123', 'CZ64532891', 'Passenger' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Letadlo WHERE Seriove_cislo = '123')
UNION
SELECT '862', 'CZ90256277', 'Passenger' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Letadlo WHERE Seriove_cislo = '862')
UNION
SELECT '478', 'CZ90256277', 'Passenger' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Letadlo WHERE Seriove_cislo = '478');

INSERT INTO Let (Let_cislo, Seriove_cislo, lt_cislo, DICH)
SELECT '50', '264', '12', 'CZ64532891' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Let WHERE Let_cislo = '50')
UNION
SELECT '294', '592', '28', 'CZ78465632' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Let WHERE Let_cislo = '294')
UNION
SELECT '732', '862', '40', 'CZ90256277' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Let WHERE Let_cislo = '732')
UNION
SELECT '663', '123', '63', 'CZ64532891' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Let WHERE Let_cislo = '663');


INSERT INTO Palubni_Listek (Palubni_Listek_Cislo, Letenka_Cislo, Let_cislo, Check_in, Gate)
SELECT '1', '1', '50', 'Y', '25' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Palubni_Listek WHERE Palubni_Listek_Cislo = '1')
UNION
SELECT '2', '2', '294', 'Y', '9' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Palubni_Listek WHERE Palubni_Listek_Cislo = '2')
UNION
SELECT '5', '3', '732', 'N', '16' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Palubni_Listek WHERE Palubni_Listek_Cislo = '5')
UNION
SELECT '10', '4', '663', 'Y', '36' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Palubni_Listek WHERE Palubni_Listek_Cislo = '10');

INSERT INTO Sluzba (Sluzba_cislo, Nazev, Cena, Dostupnost_sluzby)
SELECT '2', 'A song from flight attendant', '500', 'Y' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Sluzba Where Sluzba_cislo = '2')
UNION
SELECT '5', 'Surprise on board', '0', 'Y' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Sluzba Where Sluzba_cislo = '5');

INSERT INTO Trida (ID_tridy, Nazev, Pocet_mist)
SELECT '2', 'ECONOM', '57' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Trida WHERE ID_tridy = '2')
UNION
SELECT '1', 'BUSINES', '12' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Trida WHERE ID_tridy = '1');

INSERT INTO Sedadlo (Sedadlo_cislo, ID_tridy, Radek, Misto)
SELECT '1', '2', '25', 'F' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Sedadlo WHERE Sedadlo_cislo = '1')
UNION
SELECT '2', '1', '5', 'A' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Sedadlo WHERE Sedadlo_cislo = '2')
UNION
SELECT '5', '2', '12', 'C' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Sedadlo WHERE Sedadlo_cislo = '5')
UNION
SELECT '63', '1', '3', 'D' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Sedadlo WHERE Sedadlo_cislo = '63');

INSERT INTO Pridana_Sluzba (Sluzba_cislo, Letenka_Cislo, Uspesnost, Zahrnuto_v_cene, Pocet)
SELECT '2', '1', 'YES', 'YES', '1' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Pridana_Sluzba WHERE Sluzba_cislo = '2' AND Letenka_Cislo = '1')
UNION
SELECT '5', '2', 'YES', 'YES', '1' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Pridana_Sluzba WHERE Sluzba_cislo = '5' AND Letenka_Cislo = '2');

INSERT INTO Osoba_Letenka (Osoba_Cislo, Letenka_Cislo)
SELECT '1', '1' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Osoba_Letenka WHERE Osoba_Cislo = '1' AND Letenka_Cislo = '1')
UNION
SELECT '2', '2' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Osoba_Letenka WHERE Osoba_Cislo = '2' AND Letenka_Cislo = '2');

INSERT INTO Sedadlo_Palubni_listek (Sedadlo_Cislo, Palubni_Listek_Cislo)
SELECT '1', '1' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Sedadlo_Palubni_listek WHERE Sedadlo_Cislo = '1' AND Palubni_Listek_Cislo = '1')
UNION
SELECT '2', '2' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Sedadlo_Palubni_listek WHERE Sedadlo_Cislo = '2' AND Palubni_Listek_Cislo = '2');

INSERT INTO Trida_Letadlo (ID_tridy, Seriove_cislo)
SELECT '2', '264' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Trida_Letadlo WHERE ID_tridy = '2' AND Seriove_cislo = '264')
UNION
SELECT '1', '592' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Trida_Letadlo WHERE ID_tridy = '1' AND Seriove_cislo = '592');

INSERT INTO Spolecnost_Letiste (DICH, l_cislo)
SELECT 'CZ64532891', '3' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Spolecnost_Letiste WHERE DICH = 'CZ64532891' AND l_cislo = '3')
UNION
SELECT 'CZ78465632', '4' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Spolecnost_Letiste WHERE DICH = 'CZ78465632' AND l_cislo = '4')
UNION
SELECT 'CZ90256277', '53' FROM dual WHERE NOT EXISTS (SELECT 1 FROM Spolecnost_Letiste WHERE DICH = 'CZ90256277' AND l_cislo = '53');


-- 3 cast

-- Vybirame letiste odletu a ukazujeme jeho kod a nazev obce ve kterem se nachazi
select lt.LETISTE_ODLETU, letiste.KOD, obec.NAZEV
FROM LETOVY_ITINERAR lt
INNER JOIN LETISTE letiste ON lt.LETISTE_ODLETU = letiste.L_CISLO
INNER JOIN OBEC obec on letiste.O_CISLO = OBEC.O_CISLO;

-- Overujeme jestli nejake letadlo patri do jiz zminene spolecnosti
SELECT Letadlo.DICH
FROM Letadlo
INNER JOIN Spolecnost
ON Letadlo.DICH = Spolecnost.DICH;

-- Vybirame rezervaci a letenku s cenou mensi nez 6000
SELECT Rezervace.Rezervace_Cislo, Letenka.Letenka_Cislo, Letenka.Cena
FROM REZERVACE INNER JOIN LETENKA
ON Rezervace.Rezervace_Cislo = Letenka.Rezervace_Cislo
WHERE Cena < 6000;

-- Vybirame cenu listku podle jeji vyski
SELECT MAX(Cena)
FROM Letenka
GROUP BY Cena
ORDER BY Cena DESC;

-- Vybirame osoby se zadanou statni prislusnosti
SELECT  COUNT (Osoba_Cislo) as pocet_osob
FROM Osoba
WHERE Statni_prislusnost = 'Dor-Lomin'
GROUP BY Osoba_Cislo;

-- Overujeme jestli zadane letadlo a spolecnost provadi specifikovany let
SELECT *
FROM Let l
WHERE EXISTS (
  SELECT 1
  FROM Letadlo ld
  WHERE (ld.Seriove_cislo = l.Seriove_cislo OR ld.DICH = l.DICH)
    AND (ld.Seriove_cislo = '592' OR ld.DICH = 'CZ64532891')
);


-- Vybirame veskerou informaci o letenkach, kde nebyl k dispozici doklad o Covidu
SELECT *
FROM Letenka
WHERE Covid_doklad IN (SELECT Covid_doklad FROM Letenka WHERE Covid_doklad = 'Unattached');

-- 4. CAST

-- Overujeme jestli datum narozeni neporusi ultimativni pravidla zivota
CREATE OR REPLACE TRIGGER T_Osoba_datum_narozeni
BEFORE INSERT OR UPDATE ON Osoba
FOR EACH ROW
BEGIN
    IF :NEW.Datum_narozeni > SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20001, 'Datum narození nemůže být v budoucnosti!');
    END IF;
END;

INSERT INTO Osoba (Osoba_Cislo, Jmeno, Prijmeni, Statni_prislusnost, Datum_narozeni, Cestovni_pas, Vyskyt_v_cerne_listine)
VALUES (6, 'Eldarion', 'Aragornson', 'Gondor', TO_DATE('2025-05-05', 'YYYY-MM-DD'), 'Gor', 'N');


--Overujeme jestli email je ve spravnem formatu
CREATE OR REPLACE TRIGGER T_Registrace_email
BEFORE INSERT OR UPDATE ON Registrovana_osoba
FOR EACH ROW
DECLARE
    v_email_regex VARCHAR2(255) := '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
BEGIN
    IF :NEW.Email IS NOT NULL AND REGEXP_LIKE(:NEW.Email, v_email_regex) = FALSE THEN
        RAISE_APPLICATION_ERROR(-20002, 'Spatný format emailu!');
    END IF;
END;

INSERT INTO Registrovana_osoba (Osoba_Cislo, Telefon, Email, Heslo, Token, Metoda_platby)
VALUES ('3', '+5578345629', 'invalidemail@', 'password', 'token', 'Union Pay');

-- Select dotaz pro demonstrci spravnosti pouziti Indexu
-- Vybirame vsechna letadla s typem 'Passenger'
-- Bez pouziti Indexu tento dotaz bude proveden v rozmezi 200-400 ms
-- S indexem interval je 109-148 ms
SELECT COUNT (*)
FROM Letadlo
WHERE Typ_letadla = 'Passenger';

DROP INDEX Idx_Letadlo;

-- Pouziti EXPLAIN PLAN

-- Vybirame kolik letu provadi specifikovana spolecnost a cisla letenek na techto letech
-- Pro urychleni provedeni EXPLAIN PLAN byl zaveden index Idx_Let pro DICH spolecnosti
-- EXPLAIN PLAN zacne tim, ze najde indexy, ktere byly aplikovany na tabulku Let (pro DICH)
-- Pak zjisti, ze podminka pro specifikovany DICH splnena dvema radky (coz je urceno podle indexu)
-- Dale prejde do tabulky Palubni_listek, kde jsou 4 radky
-- Potom budou provedeny Join a Group By a nakonec cely Select Dotaz
SELECT p.Letenka_Cislo, COUNT (l.Let_cislo) AS pocet_letu
FROM Let l
JOIN Palubni_Listek p ON l.Let_cislo = p.Let_cislo
WHERE DICH = 'CZ64532891'
GROUP BY p.Letenka_Cislo;

EXPLAIN PLAN FOR
SELECT p.Letenka_Cislo, COUNT (l.Let_cislo) AS pocet_letu
FROM Let l
JOIN Palubni_Listek p ON l.Let_cislo = p.Let_cislo
WHERE DICH = 'CZ64532891'
GROUP BY p.Letenka_Cislo;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

CREATE INDEX Idx_Let ON Let(DICH);
DROP INDEX Idx_Let;


create PROCEDURE test_proc(
    sercilso LETADLO.Seriove_cislo%TYPE,
    dich_ letadlo.DICH%TYPE
)
IS
    spatny_dich EXCEPTION;
    CURSOR letCur IS
        (SELECT l.DICH,l.SERIOVE_CISLO
        FROM Let l
        WHERE EXISTS (
          SELECT 1
          FROM Letadlo ld
          WHERE (ld.Seriove_cislo = l.Seriove_cislo OR ld.DICH = l.DICH)
            AND (ld.Seriove_cislo = sercilso AND ld.DICH = dich_)
        ));
    data_from_let  letCur%ROWTYPE;
BEGIN
    IF upper(substr(data_from_let.DICH,1,2)) != 'CZ' THEN
        raise spatny_dich;
    END IF;
    OPEN letCur;
    LOOP
        FETCH letCur INTO data_from_let;
        EXIT WHEN letCur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Let, kde bylo použito letadlo sériového čísla ' || data_from_let.SERIOVE_CISLO || ' provádí organizace ' || data_from_let.DICH);
    END LOOP;
    --CLOSE letCur;
EXCEPTION
    WHEN spatny_dich THEN
        DBMS_OUTPUT.PUT_LINE('DICH by měl začínat CZ');
        CLOSE letCur;
END;
/
--dobra funkce
call test_proc('592','CZ78465632');
--funkce s chybou
call test_proc('592','CY78465632');

create procedure test_proc2(
    cislo_letiste_odletu LETOVY_ITINERAR.letiste_odletu%type
)
as
    pocet_letu number;
    cursor lt_cursor is (
    select
        lt.DATUM_A_CAS_PRILETU,
        lt.DATUM_A_CAS_ODLETU,
        l.NAZEV, l.KOD,
        extract(minute from lt.DATUM_A_CAS_PRILETU) - extract(minute from lt.DATUM_A_CAS_ODLETU) as hourstofly
    from LETOVY_ITINERAR lt
        left join LETISTE l on lt.LETISTE_ODLETU = l.L_CISLO
        where lt.LETISTE_ODLETU = cislo_letiste_odletu
    );
    var lt_cursor%rowtype;
begin
    pocet_letu := 0;
    open lt_cursor;

    loop
        FETCH lt_cursor INTO var;
        exit when lt_cursor%notfound;

        DBMS_OUTPUT.PUT_LINE('Let z města ' || var.NAZEV || '('|| var.KOD || ') bude trvat ' || var.hourstofly || ' hodin(y) s odletem v(e) '|| var.DATUM_A_CAS_ODLETU || ' hodin(y) a příletem ' || var.DATUM_A_CAS_PRILETU);
        pocet_letu := pocet_letu + 1;
    end loop;

    IF pocet_letu < 1 THEN
        DBMS_OUTPUT.PUT_LINE('Z tohoto města jsou žádné lety!');
    end if;

    close lt_cursor;
EXCEPTION
    WHEN OTHERS THEN
        close lt_cursor;
end;
/
-- 2 rows
call test_proc2(53);
-- 0 rows
call test_proc2(54);


-- Komplexni SELECT dotaz
-- Vybirame tady celkovou cenu potvrzenych letenek a nepotvrzenych letenek
-- Krome toho, spocitame, kolik rezervaci ma potvrzene letenky a kolik nepotvrzene
WITH Rezervace_stats AS (
  SELECT
    Letenka.Stav,
    COUNT(*) AS pocet_rezervaci,
    SUM(CASE WHEN Letenka.Stav = 'Confirmed' THEN Cena END) AS suma_potvrzenych_letenek,
    SUM (CASE WHEN Letenka.Stav = 'Not confirmed' THEN Cena END) AS suma_nepotvrzenych_letenek
  FROM
    Rezervace
    JOIN Letenka ON Rezervace.Rezervace_Cislo = Letenka.Rezervace_Cislo
  GROUP BY Letenka.Stav
)
SELECT
    Stav,
    pocet_rezervaci,
    suma_potvrzenych_letenek,
    suma_nepotvrzenych_letenek
FROM
  Rezervace_stats
ORDER BY Stav;

GRANT ALL ON Spolecnost TO XVETLU00;
GRANT ALL ON Letadlo TO XVETLU00;

-- material view
CREATE MATERIALIZED VIEW letadlo_mv
BUILD IMMEDIATE
REFRESH FORCE
ON DEMAND
AS
SELECT l.Seriove_cislo, l.Typ_letadla, s.nazev FROM XBORSH00.LETADLO l
    left join XBORSH00.Spolecnost s ON l.dich = s.dich;