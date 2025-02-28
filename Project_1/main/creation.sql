
-- Books table
CREATE TABLE Books (
    title CHAR(200),
    main_author CHAR(100),
    other_authors CHAR(200),
    mention_authors CHAR(200),
    pub_date CHAR(12),
    pub_country CHAR(50),
    original_language CHAR(50),
    alt_title CHAR(200),
    topic CHAR(200),
    content_notes VARCHAR2(2500),
    awards CHAR(200),
    CONSTRAINT books_pk PRIMARY KEY (title, pub_date)
);

-- Publications table (publishing details)
CREATE TABLE Publications (
    isbn CHAR(20),
    publisher CHAR(100),
    pub_place CHAR(50),
    copyright CHAR(20),
    CONSTRAINT publications_pk PRIMARY KEY (isbn)
);

-- Editions table (physical characteristics)
CREATE TABLE Editions (
    isbn CHAR(20),
    title CHAR(200),
    pub_date CHAR(12),
    edition CHAR(50),
    main_language CHAR(50),
    other_languages CHAR(50),
    extension CHAR(50),
    series CHAR(50),
    dimensions CHAR(50),
    physical_features CHAR(200),
    attached_materials CHAR(200),
    notes VARCHAR2(500),
    national_lib_id CHAR(20),
    url CHAR(200),
    CONSTRAINT editions_pk PRIMARY KEY (isbn),
    CONSTRAINT editions_pub_fk FOREIGN KEY (isbn) REFERENCES Publications (isbn),
    CONSTRAINT editions_book_fk FOREIGN KEY (title, pub_date) REFERENCES Books (title, pub_date)
);

-- Library Staff table
CREATE TABLE Library_Staff (
    lib_passport CHAR(20),
    lib_email CHAR(100),
    lib_fullname CHAR(80),
    lib_birthdate CHAR(10),
    lib_phone CHAR(9),
    lib_address CHAR(100),
    cont_start CHAR(10),
    cont_end CHAR(10),
    CONSTRAINT library_staff_pk PRIMARY KEY (lib_passport)
);

-- Towns table
CREATE TABLE Towns (
    town CHAR(50),
    province CHAR(22),
    population CHAR(8),
    has_library CHAR(1),
    address CHAR(100),
    CONSTRAINT towns_pk PRIMARY KEY (town, province)
);

-- Users table
CREATE TABLE Users (
    user_id CHAR(10),
    passport CHAR(20),
    email CHAR(100),
    name CHAR(80),
    surname1 CHAR(80),
    surname2 CHAR(80),
    birthdate CHAR(10),
    phone CHAR(9),
    address CHAR(150),
    town CHAR(50),
    PROVINCE CHAR(22),
    CONSTRAINT users_pk PRIMARY KEY (user_id),
    CONSTRAINT users_town_fk FOREIGN KEY (town, PROVINCE) REFERENCES Towns (town, PROVINCE)
);

-- Posts table
CREATE TABLE Posts (
    user_id CHAR(10),
    post_date CHAR(22),
    post VARCHAR2(2000), 
    likes CHAR(7),
    dislikes CHAR(7),
    isbn CHAR(20),
    CONSTRAINT posts_pk PRIMARY KEY (user_id, post_date),
    CONSTRAINT posts_user_fk FOREIGN KEY (user_id) REFERENCES Users (user_id),
    CONSTRAINT posts_edition_fk FOREIGN KEY (isbn) REFERENCES Editions (isbn)
);

-- Copies table
CREATE TABLE Copies (
    signature CHAR(20),
    isbn CHAR(20),
    CONSTRAINT copies_pk PRIMARY KEY (signature),
    CONSTRAINT copies_edition_fk FOREIGN KEY (isbn) REFERENCES Editions (isbn)
);

-- Loans table
CREATE TABLE Loans (
    signature CHAR(20),
    user_id CHAR(10),
    date_time CHAR(22),
    return_ CHAR(22),
    CONSTRAINT loans_pk PRIMARY KEY (signature),
    CONSTRAINT loans_copy_fk FOREIGN KEY (signature) REFERENCES Copies (signature),
    CONSTRAINT loans_user_fk FOREIGN KEY (user_id) REFERENCES Users (user_id)
);

-- Bibuses table
CREATE TABLE Bibuses (
    plate CHAR(8),
    last_itv CHAR(22),
    next_itv CHAR(22),
    lib_passport CHAR(20),
    CONSTRAINT bibuses_pk PRIMARY KEY (plate),
    CONSTRAINT bibuses_staff_fk FOREIGN KEY (lib_passport) REFERENCES Library_Staff (lib_passport)
);

-- Routes table
CREATE TABLE Routes (
    route_id CHAR(5),
    plate CHAR(8),
    stopdate CHAR(10),
    stoptime CHAR(8),
    town CHAR(50),
    PROVINCE CHAR(22),
    CONSTRAINT routes_pk PRIMARY KEY (route_id),
    CONSTRAINT routes_bibus_fk FOREIGN KEY (plate) REFERENCES Bibuses (plate),
    CONSTRAINT routes_town_fk FOREIGN KEY (town, PROVINCE) REFERENCES Towns (town, PROVINCE)
);
