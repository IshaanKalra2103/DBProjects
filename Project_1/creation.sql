CREATE SCHEMA IF NOT EXISTS `schema_databases` DEFAULT CHARACTER SET u8mb4;
USE `schema_databases`;
-- Authors table (extracted from Books)
CREATE TABLE Authors (
    main_author CHAR(100),
    other_authors CHAR(200),
    menon_authors CHAR(200),
    CONSTRAINT authors_pk PRIMARY KEY (main_author, OTHER_AUTHORS, MENTION_AUTHORS)
);
-- Books table
CREATE TABLE Books (
    tle CHAR(200),
    main_author CHAR(100),
    other_authors CHAR(200),
    menon_authors CHAR(200),
    pub_date CHAR(12),
    pub_country CHAR(50),
    original_language CHAR(50),
    alt_tle CHAR(200),
    topic CHAR(200),
    content_notes VARCHAR(2500),
    -- VARCHAR2(2500)
    awards CHAR(200),
    CONSTRAINT books_pk PRIMARY KEY (tle, pub_date)
);
-- Publicaons table (publishing details)
CREATE TABLE Publicaons (
    isbn CHAR(20),
    publisher CHAR(100),
    pub_place CHAR(50),
    copyright CHAR(20),
    CONSTRAINT publicaons_pk PRIMARY KEY (isbn)
);
-- Edions table (physical characteriscs)
CREATE TABLE Edions (
    isbn CHAR(20),
    tle CHAR(200),
    pub_date CHAR(12),
    edion CHAR(50),
    main_language CHAR(50),
    other_languages CHAR(50),
    extension CHAR(50),
    series CHAR(50),
    dimensions CHAR(50),
    physical_features CHAR(200),
    aached_materials CHAR(200),
    notes VARCHAR(500),
    -- CHAR(500)
    naonal_lib_id CHAR(20),
    url CHAR(200),
    CONSTRAINT edions_pk PRIMARY KEY (isbn),
    CONSTRAINT edions_pub_ FOREIGN KEY (isbn) REFERENCES Publicaons (isbn),
    CONSTRAINT edions_book_ FOREIGN KEY (tle, pub_date) REFERENCES Books (tle, pub_date)
);
-- Library Staﬀ table
CREATE TABLE Library_Staﬀ (
    lib_passport CHAR(20),
    lib_email CHAR(100),
    lib_fullname CHAR(80),
    lib_birthdate CHAR(10),
    lib_phone CHAR(9),
    lib_address CHAR(100),
    cont_start CHAR(10),
    cont_end CHAR(10),
    CONSTRAINT library_staﬀ_pk PRIMARY KEY (lib_passport)
);
-- Towns table
CREATE TABLE Towns (
    town CHAR(50),
    province CHAR(22),
    populaon CHAR(8),
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
    CONSTRAINT users_town_ FOREIGN KEY (town, PROVINCE) REFERENCES Towns (town, PROVINCE)
);
-- Posts table
CREATE TABLE Posts (
    user_id CHAR(10),
    post_date CHAR(22),
    post VARCHAR(2000),
    -- CHAR(2000)
    likes CHAR(7),
    dislikes CHAR(7),
    isbn CHAR(20),
    CONSTRAINT posts_pk PRIMARY KEY (user_id, post_date),
    CONSTRAINT posts_user_ FOREIGN KEY (user_id) REFERENCES Users (user_id),
    CONSTRAINT posts_edion_ FOREIGN KEY (isbn) REFERENCES Edions (isbn)
);
-- Copies table
CREATE TABLE Copies (
    signature CHAR(20),
    isbn CHAR(20),
    CONSTRAINT copies_pk PRIMARY KEY (signature),
    CONSTRAINT copies_edion_ FOREIGN KEY (isbn) REFERENCES Edions (isbn)
);
-- Loans table
CREATE TABLE Loans (
    signature CHAR(20),
    user_id CHAR(10),
    date_me CHAR(22),
    return_ CHAR(22),
    -- Formerly return
    lib_passport CHAR(20),
    CONSTRAINT loans_pk PRIMARY KEY (signature, date_me),
    CONSTRAINT loans_copy_ FOREIGN KEY (signature) REFERENCES Copies (signature),
    CONSTRAINT loans_user_ FOREIGN KEY (user_id) REFERENCES Users (user_id),
    CONSTRAINT loans_staﬀ_ FOREIGN KEY (lib_passport) REFERENCES Library_Staﬀ (lib_passport)
);
-- Bibuses table
CREATE TABLE Bibuses (
    plate CHAR(8),
    last_itv CHAR(22),
    next_itv CHAR(22),
    lib_passport CHAR(20),
    CONSTRAINT bibuses_pk PRIMARY KEY (plate),
    CONSTRAINT bibuses_staﬀ_ FOREIGN KEY (lib_passport) REFERENCES Library_Staﬀ (lib_passport)
);
-- Routes table
CREATE TABLE Routes (
    route_id CHAR(5),
    plate CHAR(8),
    stopdate CHAR(10),
    stopme CHAR(8),
    town CHAR(50),
    PROVINCE CHAR(22),
    CONSTRAINT routes_pk PRIMARY KEY (route_id),
    CONSTRAINT routes_bibus_ FOREIGN KEY (plate) REFERENCES Bibuses (plate),