--
-- File generated with SQLiteStudio v3.4.3 on Mon Mar 13 11:01:17 2023
--
-- Text encoding used: System
--
PRAGMA foreign_keys = off;
BEGIN TRANSACTION;

-- Table: Item
CREATE TABLE "Item" (
	id INTEGER NOT NULL, 
	name VARCHAR(30) NOT NULL, 
	price INTEGER NOT NULL, 
	barcode VARCHAR(12) NOT NULL, 
	description VARCHAR(1024) NOT NULL, 
	owner INTEGER, 
	PRIMARY KEY (id), 
	UNIQUE (name), 
	UNIQUE (barcode), 
	UNIQUE (description), 
	FOREIGN KEY(owner) REFERENCES "User" (id)
);

-- Table: Kraj
CREATE TABLE "Kraj" (
	id INTEGER NOT NULL, 
	ime VARCHAR NOT NULL, 
	postna INTEGER NOT NULL, 
	PRIMARY KEY (id)
);
INSERT INTO Kraj (id, ime, postna) VALUES (1, 'Ljubljana', 1000);
INSERT INTO Kraj (id, ime, postna) VALUES (2, 'Maribor', 2000);
INSERT INTO Kraj (id, ime, postna) VALUES (3, 'Kranj', 4000);
INSERT INTO Kraj (id, ime, postna) VALUES (4, 'Celje', 3000);
INSERT INTO Kraj (id, ime, postna) VALUES (5, 'Koper', 6000);
INSERT INTO Kraj (id, ime, postna) VALUES (6, 'Novo mesto', 8000);
INSERT INTO Kraj (id, ime, postna) VALUES (7, 'Velenje', 3320);
INSERT INTO Kraj (id, ime, postna) VALUES (8, 'Ptuj', 2250);
INSERT INTO Kraj (id, ime, postna) VALUES (9, 'Trbovlje', 1420);
INSERT INTO Kraj (id, ime, postna) VALUES (10, 'Murska Sobota', 9000);
INSERT INTO Kraj (id, ime, postna) VALUES (11, 'Nova Gorica', 5000);
INSERT INTO Kraj (id, ime, postna) VALUES (12, 'Krško', 8270);
INSERT INTO Kraj (id, ime, postna) VALUES (13, 'Škofja Loka', 4220);
INSERT INTO Kraj (id, ime, postna) VALUES (14, 'Kamnik', 1240);
INSERT INTO Kraj (id, ime, postna) VALUES (15, 'Jesenice', 4270);
INSERT INTO Kraj (id, ime, postna) VALUES (16, 'Postojna', 6230);
INSERT INTO Kraj (id, ime, postna) VALUES (17, 'Domžale', 1230);
INSERT INTO Kraj (id, ime, postna) VALUES (18, 'Izola', 6310);
INSERT INTO Kraj (id, ime, postna) VALUES (19, 'Trebnje', 8210);
INSERT INTO Kraj (id, ime, postna) VALUES (20, 'Litija', 1270);

-- Table: Naslov
CREATE TABLE "Naslov" (
	"id"	INTEGER NOT NULL,
	"ulica"	VARCHAR NOT NULL,
	"naslov"	INTEGER NOT NULL,
	"kraj"	INTEGER,
	PRIMARY KEY("id"),
	FOREIGN KEY("kraj") REFERENCES "Kraj"("id")
);
INSERT INTO Naslov (id, ulica, naslov, kraj) VALUES (1, 'Gregorciceva', 12, 1);
INSERT INTO Naslov (id, ulica, naslov, kraj) VALUES (2, 'Zaloška cesta', 2, 1);
INSERT INTO Naslov (id, ulica, naslov, kraj) VALUES (3, 'Engelsova ulica', 3, 2);
INSERT INTO Naslov (id, ulica, naslov, kraj) VALUES (4, 'Ipavceva ulica', 12, 4);

-- Table: Ordinacija
CREATE TABLE "Ordinacija" (
	"id"	INTEGER NOT NULL,
	"ime"	VARCHAR NOT NULL,
	"telefon"	VARCHAR NOT NULL,
	"email"	VARCHAR NOT NULL,
	"odpre"	TEXT NOT NULL,
	"zapre"	TEXT NOT NULL,
	"lastnik"	INTEGER,
	"lokacija"	INTEGER,
	"rating_sum"	INTEGER,
	"num_ratings"	INTEGER,
	"average_rating"	NUMERIC,
	"TipOrdinacije"	INTEGER,
	UNIQUE("email"),
	UNIQUE("ime"),
	UNIQUE("telefon"),
	PRIMARY KEY("id"),
	FOREIGN KEY("TipOrdinacije") REFERENCES "TipOrdinacije"("id"),
	FOREIGN KEY("lokacija") REFERENCES "Naslov"("id"),
	FOREIGN KEY("lastnik") REFERENCES "Zdravnik"("id")
);
INSERT INTO Ordinacija (id, ime, telefon, email, odpre, zapre, lastnik, lokacija, rating_sum, num_ratings, average_rating, TipOrdinacije) VALUES (1, 'Pediatricna klinika Ljubljana', '041999123', 'pediatricnaklinika@gmail.com', '08:00:00', '17:00:00', 1, 1, 29, 10, 2.9, 1);
INSERT INTO Ordinacija (id, ime, telefon, email, odpre, zapre, lastnik, lokacija, rating_sum, num_ratings, average_rating, TipOrdinacije) VALUES (2, 'Neka klinika ljubljana', '041111111', 'neke@neke.neke.com', '08:00:00', '19:00:00', 1, 1, 0, 0, 0, 6);
INSERT INTO Ordinacija (id, ime, telefon, email, odpre, zapre, lastnik, lokacija, rating_sum, num_ratings, average_rating, TipOrdinacije) VALUES (3, 'Nevrološka klinika Ljubljana', '031999123', 'nevroloska.ljubljana@hotmail.com', '09:00:00', '18:00:00', 2, 2, 0, 0, 0, 6);
INSERT INTO Ordinacija (id, ime, telefon, email, odpre, zapre, lastnik, lokacija, rating_sum, num_ratings, average_rating, TipOrdinacije) VALUES (4, 'Pediatricna ordinacija Bežigrad', '041931999', 'pediatricna.bezigrad@gmail.com', '08:00:00', '16:00:00', 3, 1, 0, 0, 0, 1);
INSERT INTO Ordinacija (id, ime, telefon, email, odpre, zapre, lastnik, lokacija, rating_sum, num_ratings, average_rating, TipOrdinacije) VALUES (5, 'Splošna ambulanta Maribor', '030129420', 'splosna@gmail.com', '7:00:00', '18:00:00', 4, 3, 0, 0, 0, 4);
INSERT INTO Ordinacija (id, ime, telefon, email, odpre, zapre, lastnik, lokacija, rating_sum, num_ratings, average_rating, TipOrdinacije) VALUES (6, 'Ginekološki center - Dobro zdravje', '01973235', 'dobro.zdravje@amis.net', '10:00:00', '16:00:00', 5, 4, 0, 0, 0, 5);

-- Table: Ponudba
CREATE TABLE "Ponudba" (
	"id"	INTEGER NOT NULL,
	"naziv"	VARCHAR NOT NULL,
	"dolzina"	INTEGER,
	"ordinacija"	INTEGER,
	"opis"	TEXT,
	FOREIGN KEY("ordinacija") REFERENCES "Ordinacija"("id"),
	PRIMARY KEY("id"),
	UNIQUE("naziv")
);
INSERT INTO Ponudba (id, naziv, dolzina, ordinacija, opis) VALUES (1, 'Pregled astmatika', 1, 1, 'Pregled astmatika je diagnosticni postopek, ki vkljucuje oceno dihalnih poti in pljucne funkcije ter zdravstvenega stanja bolnika na splošno. Med pregledom zdravnik zbere podatke o simptomih, zdravstveni anamnezi, alergijskih reakcijah in obstojecih zdravilih bolnika. Pregled lahko vkljucuje tudi merjenje kisika v krvi, testiranje pljucne funkcije s spirometrijo in poslušanje dihal s stetoskopom. Na podlagi rezultatov pregleda zdravnik lahko postavi diagnozo astme, predpiše zdravljenje in spremlja bolnikov napredek na dolgi rok.



');
INSERT INTO Ponudba (id, naziv, dolzina, ordinacija, opis) VALUES (2, 'Navadni pregled', 1, 1, NULL);
INSERT INTO Ponudba (id, naziv, dolzina, ordinacija, opis) VALUES (3, 'Pregled ušesa', 2, 2, NULL);
INSERT INTO Ponudba (id, naziv, dolzina, ordinacija, opis) VALUES (4, 'Pregled glave', 30, 1, NULL);
INSERT INTO Ponudba (id, naziv, dolzina, ordinacija, opis) VALUES (5, 'Pregled oci', 1, 1, NULL);
INSERT INTO Ponudba (id, naziv, dolzina, ordinacija, opis) VALUES (6, 'Posvetovanje za dojencke', 1, 4, NULL);
INSERT INTO Ponudba (id, naziv, dolzina, ordinacija, opis) VALUES (7, 'test', 30, 4, NULL);
INSERT INTO Ponudba (id, naziv, dolzina, ordinacija, opis) VALUES (8, 'Pregled pred kirurgijo', 1, 5, NULL);
INSERT INTO Ponudba (id, naziv, dolzina, ordinacija, opis) VALUES (9, 'Pregled novorojencka', 1, 1, 'Pregled novorojencka obicajno vkljucuje temeljit pregled telesa, preverjanje vitalnih znakov, kot so srcni utrip in dihanje, pregled kože, oci, ušes, nosu, ustne votline, ter merjenje telesne mase, dolžine in obsega glave. Pregled se izvaja z namenom prepoznavanja morebitnih težav v razvoju in zdravstvenih težav novorojencka.');

-- Table: Termin
CREATE TABLE "Termin" (
	"id"	INTEGER NOT NULL,
	"datum"	DATE,
	"cas"	TIME,
	"punudba"	INTEGER,
	"uporabnik"	INTEGER,
	"koncni_cas"	TEXT,
	"status"	TEXT DEFAULT 'Nepotrjeno',
	"timestamp"	Date,
	PRIMARY KEY("id"),
	FOREIGN KEY("uporabnik") REFERENCES "User"("id"),
	FOREIGN KEY("punudba") REFERENCES "Ponudba"("id")
);
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (11, '2023-02-03', '11:00:00', 3, 1, '12:00:00', 'Koncano', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (12, '2023-01-31', '08:00:00', 1, 1, '08:30:00', 'Ocenjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (13, '2023-02-06', '08:30:00', 1, 1, '09:00:00', 'Koncano', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (14, '2023-02-03', '11:30:00', 1, 1, '12:00:00', 'Koncano', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (15, '2023-02-02', '10:30:00', 1, 1, '11:00:00', 'Ocenjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (18, '2023-02-03', '13:30:00', 1, 1, '14:00:00', 'Koncano', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (22, '2023-02-03', '15:00:00', 1, 1, '15:30:00', 'Ocenjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (23, '2023-01-27', '08:00:00', 1, 1, '08:30:00', 'Ocenjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (25, '2023-02-24', '09:00:00', 1, 1, '09:30:00', 'Zavrnjen', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (27, '2023-02-21', '08:30:00', 1, 1, '09:00:00', 'Sprejet', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (28, '2023-02-28', '09:00:00', 2, 1, '09:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (29, '2023-02-21', '10:00:00', 1, 1, '10:30:00', 'Zavrnjen', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (30, '2023-02-21', '10:00:00', 1, 1, '10:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (32, '2023-02-02', '10:00:00', 2, 1, '10:30:00', 'Ocenjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (33, '2023-02-02', '09:30:00', 4, 1, '10:30:00', 'Ocenjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (34, '2023-02-02', '09:00:00', 2, 1, '09:30:00', 'Ocenjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (35, '2023-02-21', '09:30:00', 2, 1, '10:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (37, '2023-02-23', '09:00:00', 2, 1, '09:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (38, '2023-02-22', '09:00:00', 1, 1, '09:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (39, '2023-02-24', '11:30:00', 4, 1, '12:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (40, '2023-02-23', '08:30:00', 2, 1, '09:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (41, '2023-02-24', '11:00:00', 2, 1, '11:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (42, '2023-02-24', '10:30:00', 2, 1, '11:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (43, '2023-02-23', '08:00:00', 4, 1, '09:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (44, '2023-03-01', '17:30:00', 2, 1, '18:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (45, '2023-02-24', '10:00:00', 2, 1, '10:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (46, '2023-02-21', '09:00:00', 2, 1, '09:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (47, '2023-02-24', '12:30:00', 1, 1, '13:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (48, '2023-02-22', '08:30:00', 1, 1, '09:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (49, '2023-02-24', '09:30:00', 4, 1, '10:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (50, '2023-02-24', '09:00:00', 4, 1, '10:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (51, '2023-03-01', '11:00:00', 4, 1, '12:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (52, '2023-02-24', '08:30:00', 4, 1, '09:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (53, '2023-02-24', '08:00:00', 4, 1, '09:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (54, '2023-02-22', '05:30:00', 2, 1, '06:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (55, '2023-02-24', '07:30:00', 4, 1, '08:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (56, '2023-02-23', '07:30:00', 2, 1, '08:00:00', 'Koncano', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (57, '2023-02-24', '07:00:00', 4, 1, '08:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (58, '2023-02-14', '19:00:00', 2, 1, '19:30:00', 'Koncano', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (59, '2023-02-24', '05:30:00', 4, 1, '06:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (60, '2023-02-27', '19:00:00', 4, 1, '20:00:00', 'Sprejet', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (61, '2023-02-17', '05:30:00', 2, 1, '06:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (62, '2023-02-23', '04:30:00', 2, 1, '05:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (63, '2023-02-21', '11:00:00', 2, 1, '11:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (64, '2023-02-23', '21:00:00', 2, 1, '21:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (65, '2023-02-24', '06:30:00', 2, 1, '07:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (66, '2023-02-17', '05:00:00', 4, 1, '06:00:00', 'Koncano', '2023-02-28');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (67, '2023-02-23', '05:00:00', 2, 1, '05:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (68, '2023-02-17', '04:30:00', 2, 1, '05:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (69, '2023-02-17', '04:00:00', 4, 1, '05:00:00', 'Koncano', '2023-02-28');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (70, '2023-02-23', '07:00:00', 2, 1, '07:30:00', 'Koncano', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (71, '2023-02-23', '06:30:00', 4, 1, '07:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (72, '2023-02-23', '06:00:00', 2, 1, '06:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (73, '2023-02-23', '05:30:00', 4, 1, '06:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (74, '2023-02-18', '05:30:00', 4, 1, '06:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (75, '2023-02-21', '05:30:00', 4, 1, '06:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (76, '2023-02-23', '02:30:00', 2, 1, '03:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (77, '2023-02-24', '17:30:00', 2, 1, '18:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (78, '2023-02-18', '04:00:00', 4, 1, '05:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (79, '2023-02-23', '03:30:00', 2, 1, '04:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (80, '2023-02-23', '04:00:00', 2, 1, '04:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (81, '2023-02-18', '03:00:00', 4, 1, '04:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (82, '2023-02-23', '01:30:00', 2, 1, '02:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (84, '2023-02-28', '10:00:00', 2, 4, '10:30:00', 'Sprejet', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (85, '2023-02-08', '05:30:00', 2, 2, '06:00:00', 'Ocenjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (86, '2023-02-09', '06:00:00', 2, 2, '06:30:00', 'Koncano', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (87, '2023-02-15', '09:00:00', 1, 2, '09:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (88, '2023-02-24', '21:00:00', 2, 2, '21:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (89, '2023-03-03', '08:30:00', 4, 2, '09:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (90, '2023-03-01', '15:00:00', 2, 2, '15:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (91, '2023-03-01', '12:30:00', 2, 1, '13:00:00', 'Zavrnjen', '2023-02-28');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (92, '2023-03-03', '16:30:00', 1, 1, '17:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (93, '2023-02-27', '18:30:00', 3, 1, '19:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (94, '2023-03-02', '13:00:00', 1, 1, '13:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (95, '2023-02-21', '10:30:00', 2, 6, '11:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (96, '2023-03-24', '16:00:00', 3, 6, '17:00:00', 'Sprejet', '2023-03-11');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (97, '2023-02-22', '14:30:00', 2, 6, '15:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (98, '2023-02-20', '12:30:00', 2, 6, '13:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (99, '2023-02-21', '08:00:00', 1, 6, '08:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (100, '2023-02-21', '11:30:00', 1, 6, '12:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (101, '2023-02-21', '12:00:00', 1, 6, '12:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (102, '2023-02-21', '12:30:00', 1, 6, '13:00:00', 'Koncano', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (103, '2023-02-21', '13:00:00', 4, 6, '14:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (104, '2023-02-21', '14:00:00', 4, 6, '15:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (105, '2023-02-21', '15:00:00', 4, 6, '16:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (106, '2023-02-21', '16:00:00', 4, 6, '17:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (107, '2023-02-20', '08:00:00', 1, 1, '08:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (109, '2023-02-20', '08:30:00', 1, 1, '09:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (110, '2023-02-20', '09:00:00', 4, 1, '10:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (111, '2023-02-20', '10:00:00', 4, 1, '11:00:00', 'Koncano', '2023-02-28');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (112, '2023-02-20', '11:00:00', 4, 1, '12:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (113, '2023-02-20', '12:00:00', 1, 1, '12:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (114, '2023-02-20', '15:00:00', 4, 1, '16:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (115, '2023-02-20', '13:00:00', 4, 1, '14:00:00', 'Koncano', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (116, '2023-02-20', '14:00:00', 4, 1, '15:00:00', 'Koncano', '2023-02-28');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (117, '2023-02-20', '16:00:00', 2, 1, '16:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (118, '2023-02-22', '08:00:00', 1, 1, '08:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (119, '2023-02-23', '09:30:00', 4, 1, '10:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (120, '2023-02-23', '10:30:00', 4, 1, '11:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (121, '2023-02-23', '11:30:00', 4, 1, '12:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (122, '2023-02-23', '12:30:00', 4, 1, '13:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (123, '2023-02-23', '13:30:00', 4, 1, '14:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (124, '2023-02-23', '14:30:00', 4, 1, '15:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (125, '2023-02-23', '15:30:00', 4, 1, '16:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (126, '2023-02-23', '16:30:00', 1, 1, '17:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (127, '2023-02-24', '13:30:00', 1, 1, '14:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (128, '2023-03-02', '15:30:00', 1, 1, '16:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (129, '2023-02-28', '08:00:00', 1, 1, '08:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (131, '2023-02-28', '09:30:00', 1, 1, '10:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (132, '2023-02-28', '10:30:00', 4, 1, '11:30:00', 'Koncano', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (133, '2023-02-28', '11:30:00', 4, 1, '12:30:00', 'Zavrnjen', '2023-02-28');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (134, '2023-02-28', '12:30:00', 4, 1, '13:30:00', 'Sprejet', '2023-02-28');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (135, '2023-02-28', '13:30:00', 4, 1, '14:30:00', 'Sprejet', '2023-02-28');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (136, '2023-02-28', '14:30:00', 4, 1, '15:30:00', 'Sprejet', '2023-02-28');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (137, '2023-02-28', '15:30:00', 4, 1, '16:30:00', 'Sprejet', '2023-02-28');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (138, '2023-02-28', '16:30:00', 4, 1, '17:30:00', 'Sprejet', '2023-02-28');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (139, '2023-02-28', '08:00:00', 3, 1, '09:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (140, '2023-02-28', '09:00:00', 3, 1, '10:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (141, '2023-02-28', '10:00:00', 3, 1, '11:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (142, '2023-02-28', '11:00:00', 3, 1, '12:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (143, '2023-02-28', '12:00:00', 3, 1, '13:00:00', 'Sprejet', '2023-02-28');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (144, '2023-02-28', '13:00:00', 3, 1, '14:00:00', 'Sprejet', '2023-02-28');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (145, '2023-02-28', '14:00:00', 3, 1, '15:00:00', 'Sprejet', '2023-02-28');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (146, '2023-02-28', '15:00:00', 3, 1, '16:00:00', 'Sprejet', '2023-02-28');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (147, '2023-02-28', '16:00:00', 3, 1, '17:00:00', 'Sprejet', '2023-02-28');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (148, '2023-02-28', '17:00:00', 3, 1, '18:00:00', 'Sprejet', '2023-02-28');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (149, '2023-02-28', '18:00:00', 3, 1, '19:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (150, '2023-03-01', '08:00:00', 1, 1, '08:30:00', 'Sprejet', '2023-02-28');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (151, '2023-02-24', '14:00:00', 4, 1, '15:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (152, '2023-02-24', '15:00:00', 4, 1, '16:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (153, '2023-02-24', '16:00:00', 4, 1, '17:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (154, '2023-02-28', '08:30:00', 1, 1, '09:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (155, '2023-03-03', '15:00:00', NULL, 2, '15:21:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (156, '2023-03-09', '08:00:00', NULL, 2, '23:00:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (157, '2023-03-03', '15:00:00', 1, 2, '15:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (158, '2023-03-03', '12:30:00', 1, 1, '13:00:00', 'Nepotrjeno', '2023-02-28');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (159, '2023-03-01', '16:00:00', 1, 1, '16:30:00', 'Nepotrjeno', '2023-02-27');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (160, '2023-03-08', '15:30:00', 1, 1, '16:00:00', 'Nepotrjeno', '2023-03-02');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (161, '2023-03-29', '14:00:00', 2, 1, '14:30:00', 'Sprejet', '2023-03-08');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (162, '2023-04-05', '14:00:00', 5, 1, '14:30:00', 'Nepotrjeno', '2023-03-02');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (163, '2023-03-22', '10:00:00', 3, 1, '11:00:00', 'Sprejet', '2023-03-11');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (164, '2023-03-28', '08:00:00', 5, 1, '08:30:00', 'Sprejet', '2023-03-11');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (166, '2023-03-29', '08:00:00', 4, 1, '09:00:00', 'Sprejet', '2023-03-11');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (167, '2023-03-30', '08:00:00', 4, 1, '23:00:00', 'Nepotrjeno', '2023-03-02');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (170, '2023-03-29', '12:00:00', 1, 1, '12:30:00', 'Sprejet', '2023-03-08');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (171, '2023-03-29', '15:30:00', 1, 1, '16:00:00', 'Sprejet', '2023-03-11');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (172, '2023-03-22', '14:30:00', 1, 1, '15:00:00', 'Sprejet', '2023-03-08');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (173, '2023-03-29', '16:30:00', 2, 7, '17:00:00', 'Sprejet', '2023-03-11');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (174, '2023-03-28', '14:00:00', 6, 7, '14:01:00', 'Sprejet', '2023-03-06');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (175, '2023-03-28', '14:30:00', 6, 7, '15:00:00', 'Sprejet', '2023-03-06');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (176, '2023-03-29', '09:00:00', 1, 7, '09:30:00', 'Sprejet', '2023-03-11');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (177, '2023-03-29', '10:00:00', 2, 7, '10:30:00', 'Sprejet', '2023-03-11');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (178, '2023-03-29', '09:30:00', 1, 7, '10:00:00', 'Sprejet', '2023-03-11');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (179, '2023-03-29', '10:30:00', 2, 7, '11:00:00', 'Zavrnjen', '2023-03-11');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (180, '2023-03-29', '11:00:00', 1, 7, '11:30:00', 'Zavrnjen', '2023-03-11');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (181, '2023-03-29', '11:30:00', 1, 7, '12:00:00', 'Zavrnjen', '2023-03-11');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (182, '2023-03-29', '16:00:00', 1, 7, '16:30:00', 'Nepotrjeno', '2023-03-06');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (183, '2023-03-29', '14:30:00', 2, 7, '15:00:00', 'Nepotrjeno', '2023-03-06');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (184, '2023-03-29', '12:30:00', 2, 7, '13:00:00', 'Nepotrjeno', '2023-03-06');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (185, '2023-03-29', '15:00:00', 1, 7, '15:30:00', 'Nepotrjeno', '2023-03-06');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (186, '2023-03-29', '13:30:00', 2, 7, '14:00:00', 'Nepotrjeno', '2023-03-06');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (187, '2023-03-29', '13:00:00', 1, 7, '13:30:00', 'Nepotrjeno', '2023-03-06');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (188, '2023-04-03', '08:00:00', 7, 7, '23:00:00', 'Nepotrjeno', '2023-03-06');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (189, '2023-03-24', '10:30:00', 1, 2, '11:00:00', 'Sprejet', '2023-03-08');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (190, '2023-04-05', '14:30:00', 1, 2, '15:00:00', 'Nepotrjeno', '2023-03-08');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (191, '2023-03-31', '10:00:00', 1, 1, '10:30:00', 'Nepotrjeno', '2023-03-08');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (192, '2023-03-31', '12:00:00', 6, 1, '12:30:00', 'Nepotrjeno', '2023-03-11');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (193, '2023-03-24', '13:30:00', 3, 1, '14:30:00', 'Nepotrjeno', '2023-03-11');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (194, '2023-03-23', '13:30:00', 3, 1, '14:30:00', 'Nepotrjeno', '2023-03-11');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (195, '2023-03-29', '14:30:00', 3, 1, '15:30:00', 'Nepotrjeno', '2023-03-11');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (196, '2023-03-24', '11:00:00', 3, 1, '12:00:00', 'Nepotrjeno', '2023-03-11');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (197, '2023-03-24', '09:30:00', 3, 1, '10:30:00', 'Nepotrjeno', '2023-03-11');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (198, '2023-03-24', '14:30:00', 8, 1, '15:00:00', 'Nepotrjeno', '2023-03-11');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (199, '2023-03-29', '12:00:00', 8, 1, '12:30:00', 'Nepotrjeno', '2023-03-11');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (200, '2023-04-06', '13:30:00', 9, 1, '14:00:00', 'Nepotrjeno', '2023-03-12');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (201, '2023-03-31', '13:00:00', 1, 1, '13:30:00', 'Nepotrjeno', '2023-03-12');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (202, '2023-03-24', '10:00:00', 1, 1, '10:30:00', 'Nepotrjeno', '2023-03-12');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (203, '2023-03-31', '14:00:00', 1, 1, '14:30:00', 'Nepotrjeno', '2023-03-12');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (204, '2023-03-14', '10:30:00', 2, 1, '11:00:00', 'Nepotrjeno', '2023-03-12');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (205, '2023-03-23', '08:30:00', 5, 1, '09:00:00', 'Nepotrjeno', '2023-03-12');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (206, '2023-03-31', '12:30:00', 1, 1, '13:00:00', 'Nepotrjeno', '2023-03-12');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (207, '2023-03-24', '13:30:00', 4, 1, '04:30:00', 'Nepotrjeno', '2023-03-12');
INSERT INTO Termin (id, datum, cas, punudba, uporabnik, koncni_cas, status, timestamp) VALUES (208, '2023-03-24', '12:30:00', 1, 2, '13:00:00', 'Nepotrjeno', '2023-03-12');

-- Table: TipOrdinacije
CREATE TABLE "TipOrdinacije" (
	id INTEGER NOT NULL, 
	picture_link VARCHAR(200) NOT NULL, 
	type_name VARCHAR(30) NOT NULL, 
	PRIMARY KEY (id)
);
INSERT INTO TipOrdinacije (id, picture_link, type_name) VALUES (1, 'https://i.ibb.co/NFrMsy5/pediatrics-100.png', 'Pediatrija');
INSERT INTO TipOrdinacije (id, picture_link, type_name) VALUES (2, 'https://i.ibb.co/j5rcT7Z/orthopedic-surgery-100.png', 'Ortopedija');
INSERT INTO TipOrdinacije (id, picture_link, type_name) VALUES (3, 'https://i.ibb.co/LzS545K/internal-medicine-100.png', 'Notranje bolezni');
INSERT INTO TipOrdinacije (id, picture_link, type_name) VALUES (4, 'https://i.ibb.co/NNWPyrH/general-surgery-100.png', 'Splošna kirurgija');
INSERT INTO TipOrdinacije (id, picture_link, type_name) VALUES (5, 'https://i.ibb.co/WFHCpnm/obgyn-obstetrics-gynecology-100.png', 'Ginekologija');
INSERT INTO TipOrdinacije (id, picture_link, type_name) VALUES (6, 'https://i.ibb.co/rv1WgKm/neurology-100.png', 'Nevrologija');
INSERT INTO TipOrdinacije (id, picture_link, type_name) VALUES (7, 'https://i.ibb.co/3sPXHvt/dermatology-100.png', 'Dermatologija');
INSERT INTO TipOrdinacije (id, picture_link, type_name) VALUES (8, 'https://i.ibb.co/fHzJzFz/allergy-immunology-100.png', 'Alergologija');
INSERT INTO TipOrdinacije (id, picture_link, type_name) VALUES (9, 'https://i.ibb.co/64YZcrp/cardiology-100.png', 'Kardiologija');
INSERT INTO TipOrdinacije (id, picture_link, type_name) VALUES (10, 'https://i.ibb.co/ctKMsKW/ent-otolaryngology-100.png', 'Otorinolaringologija');
INSERT INTO TipOrdinacije (id, picture_link, type_name) VALUES (11, 'https://i.ibb.co/3rN0T7j/hematology-oncology-100.png', 'Hematologija');
INSERT INTO TipOrdinacije (id, picture_link, type_name) VALUES (12, 'https://i.ibb.co/DfzTz79/gastroenterology-100.png', 'Gastroenterologija');

-- Table: User
CREATE TABLE "User" (
	"id"	INTEGER NOT NULL,
	"username"	VARCHAR(30) NOT NULL,
	"email_address"	VARCHAR(60) NOT NULL,
	"password_hash"	VARCHAR(60) NOT NULL,
	"role"	TEXT,
	"kzzs"	INTEGER,
	"last_login"	Date,
	PRIMARY KEY("id"),
	UNIQUE("username"),
	UNIQUE("email_address")
);
INSERT INTO User (id, username, email_address, password_hash, role, kzzs, last_login) VALUES (1, 'gost', 'gos1t@gmail.com', '$2b$12$LyMNyC.hrCEPVVo75GvBYu1YobpKlVdXHz1bl40zeuoFGMQTPrYFC', 'pacient', 55111222, '2023-03-13');
INSERT INTO User (id, username, email_address, password_hash, role, kzzs, last_login) VALUES (2, 'zdravnik', 'janko.novic@gmail.com', '$2b$12$vTDgLDDwJDDnVdRyp6ekvuyB9zoWbpuG2I/GhfHxK6tIfm4bnE2x.', 'zdravnik', 31999333, '2023-02-03');
INSERT INTO User (id, username, email_address, password_hash, role, kzzs, last_login) VALUES (3, 'majda', 'majda.sepa@gmail.com', '$2b$12$ekZlZcVWzYtHbuxukjv10uMw1IQkkmGkm6kHroj3ZxxxS.2pP0Sru', 'zdravnik', 123974123, '2023-02-03');
INSERT INTO User (id, username, email_address, password_hash, role, kzzs, last_login) VALUES (4, 'bibi', 'lalalove.unicorns@gmail.com', '$2b$12$fAE5oabYdRxEoq3PhQ8BwezZ7x/erqHxWtxArqMbZ1QVPUt66tB7q', 'pacient', 123321123, '2023-02-03');
INSERT INTO User (id, username, email_address, password_hash, role, kzzs, last_login) VALUES (5, 'Gostisok', 'gosti.sok@gmail.com', '$2b$12$l75rIQ7HGfDXk/koQL/mcuhDL12ckpZPDn4POGXQybEE3VNyzEiMK', 'pacient', 912332213, '2023-02-03');
INSERT INTO User (id, username, email_address, password_hash, role, kzzs, last_login) VALUES (6, 'drugi', 'jernej.ozebek@gmail.com', '$2b$12$pZmNwgnpeljyW/ggEi6qsOfN1CtDsQ2EHwtdRo.xm7PmoAKiTdidC', 'pacient', 123123123, '2023-02-03');
INSERT INTO User (id, username, email_address, password_hash, role, kzzs, last_login) VALUES (7, 'markostanic', 'marko.stanic@gmail.com', '$2b$12$z77IQaKOcRJW.qXCtiVTUOV8UZXnGKvx7qjCew69N9y3ku0NVsIWO', 'zdravnik', 551112222, '2023-03-06');
INSERT INTO User (id, username, email_address, password_hash, role, kzzs, last_login) VALUES (8, 'admin', 'admin@gmail.com', '$2b$12$Nkn.QAxEULKprB0v4od3i.qpN31uHUdIvvC/kYc8B8dGAfGgD/Ugu', 'admin', 213331233, '2023-03-09');
INSERT INTO User (id, username, email_address, password_hash, role, kzzs, last_login) VALUES (9, 'jankon', 'novak.janko@gmail.com', '$2b$12$BA7YW2tEci.vEunvQugWeuxjT3XtS7f/3WjcReaJFS.qxmOFCke0m', 'pacient', 123123124, '2023-03-09');
INSERT INTO User (id, username, email_address, password_hash, role, kzzs, last_login) VALUES (10, 'romanstr', 'roman@gmail.com', '$2b$12$m5gry.kOsrefKNfl8DzKau0ipg5ptLiKFMzlnMmoOXQNrTjisnhfS', 'zdravnik', 912332212, '2023-03-09');

-- Table: Zdravnik
CREATE TABLE "Zdravnik" (
	id INTEGER NOT NULL, 
	ime VARCHAR NOT NULL, 
	priimek VARCHAR NOT NULL, 
	email VARCHAR(60) NOT NULL, 
	password_hash VARCHAR(60) NOT NULL, 
	naziv VARCHAR NOT NULL, 
	PRIMARY KEY (id), 
	UNIQUE (ime), 
	UNIQUE (priimek), 
	UNIQUE (email)
);
INSERT INTO Zdravnik (id, ime, priimek, email, password_hash, naziv) VALUES (1, 'Dr. Janko', 'Novic', 'janko.novic@gmail.com', 'jako123', 'Glavni pediater');
INSERT INTO Zdravnik (id, ime, priimek, email, password_hash, naziv) VALUES (2, 'Dr. Majda', 'Šepa', 'majda.sepa@gmail.com', 'majda123', 'Glavna Zdravnica');
INSERT INTO Zdravnik (id, ime, priimek, email, password_hash, naziv) VALUES (3, 'Dr. Marko', 'Stanic', 'marko.stanic@gmail.com', 'marko123', 'Glavni pediater');
INSERT INTO Zdravnik (id, ime, priimek, email, password_hash, naziv) VALUES (4, 'Roman', 'Štranberger', 'roman@gmail.com', 'roman123', 'Glavni Splošni zdravnik');
INSERT INTO Zdravnik (id, ime, priimek, email, password_hash, naziv) VALUES (5, 'Jožica', 'Šmorn', 'jozica@gmail.com', 'jožica12', 'Glavna Ginekologinja');

COMMIT TRANSACTION;
PRAGMA foreign_keys = on;
