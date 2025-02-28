-- Books table
MERGE INTO Books dest
USING (
    SELECT Title, Main_Author, Other_Authors, Mention_Authors, NVL(PUB_DATE, 'N/A') AS PUB_DATE, Pub_Country, Original_Language, Alt_Title, Topic, Content_Notes, Awards
    FROM (
        SELECT Title, Main_Author, Other_Authors, Mention_Authors, PUB_DATE, Pub_Country, Original_Language, Alt_Title, Topic, Content_Notes, Awards,
               ROW_NUMBER() OVER (PARTITION BY Title, PUB_DATE ORDER BY Title) AS rn
        FROM fsdb.acervus
    )
    WHERE rn = 1
) src
ON (dest.title = src.Title AND dest.pub_date = src.PUB_DATE)
WHEN NOT MATCHED THEN
    INSERT (title, main_author, other_authors, mention_authors, pub_date, pub_country, original_language, alt_title, topic, content_notes, awards)
    VALUES (src.Title, src.Main_Author, src.Other_Authors, src.Mention_Authors, src.PUB_DATE, src.Pub_Country, src.Original_Language, src.Alt_Title, src.Topic, src.Content_Notes, src.Awards);


-- Publications table
MERGE INTO Publications dest
USING (
    SELECT ISBN, Publisher, Pub_Place, Copyright
    FROM (
        SELECT ISBN, Publisher, Pub_Place, Copyright,
               ROW_NUMBER() OVER (PARTITION BY ISBN ORDER BY ISBN) AS rn
        FROM fsdb.acervus
    )
    WHERE rn = 1
) src
ON (dest.isbn = src.ISBN)
WHEN NOT MATCHED THEN
    INSERT (isbn, publisher, pub_place, copyright)
    VALUES (src.ISBN, src.Publisher, src.Pub_Place, src.Copyright);


-- Editions table
MERGE INTO Editions dest
USING (
    SELECT ISBN, Title, Pub_Date, Edition, Main_Language, Other_Languages, Extension, Series, Dimensions, Physical_Features, Notes, National_Lib_Id, URL
    FROM (
        SELECT ISBN, Title, Pub_Date, Edition, Main_Language, Other_Languages, Extension, Series, Dimensions, Physical_Features, Notes, National_Lib_Id, URL,
               ROW_NUMBER() OVER (PARTITION BY ISBN, Edition ORDER BY ISBN) AS rn
        FROM fsdb.acervus
    )
    WHERE rn = 1
) src
ON (dest.isbn = src.ISBN AND dest.edition = src.Edition)
WHEN NOT MATCHED THEN
    INSERT (isbn, title, pub_date, edition, main_language, other_languages, extension, series, dimensions, physical_features, notes, national_lib_id, url)
    VALUES (src.ISBN, src.Title, src.Pub_Date, src.Edition, src.Main_Language, src.Other_Languages, src.Extension, src.Series, src.Dimensions, src.Physical_Features, src.Notes, src.National_Lib_Id, src.URL);


-- Library Staff table
MERGE INTO Library_Staff dest
USING (
    SELECT LIB_PASSPORT, LIB_EMAIL, LIB_FULLNAME, LIB_BIRTHDATE, LIB_PHONE, LIB_ADDRESS, CONT_START, CONT_END
    FROM (
        SELECT LIB_PASSPORT, LIB_EMAIL, LIB_FULLNAME, LIB_BIRTHDATE, LIB_PHONE, LIB_ADDRESS, CONT_START, CONT_END,
               ROW_NUMBER() OVER (PARTITION BY LIB_PASSPORT ORDER BY LIB_PASSPORT) AS rn
        FROM fsdb.busstops
    )
    WHERE rn = 1
) src
ON (dest.lib_passport = src.LIB_PASSPORT)
WHEN NOT MATCHED THEN
    INSERT (lib_passport, lib_email, lib_fullname, lib_birthdate, lib_phone, lib_address, cont_start, cont_end)
    VALUES (src.LIB_PASSPORT, src.LIB_EMAIL, src.LIB_FULLNAME, src.LIB_BIRTHDATE, src.LIB_PHONE, src.LIB_ADDRESS, src.CONT_START, src.CONT_END);


-- Towns table
MERGE INTO Towns dest
USING (
    SELECT TOWN, PROVINCE, POPULATION, HAS_LIBRARY, ADDRESS
    FROM (
        SELECT TOWN, PROVINCE, POPULATION, HAS_LIBRARY, ADDRESS,
               ROW_NUMBER() OVER (PARTITION BY TOWN, PROVINCE ORDER BY TOWN) AS rn
        FROM fsdb.busstops
    )
    WHERE rn = 1
) src
ON (dest.town = src.TOWN AND dest.province = src.PROVINCE)
WHEN NOT MATCHED THEN
    INSERT (town, province, population, has_library, address)
    VALUES (src.TOWN, src.PROVINCE, src.POPULATION, src.HAS_LIBRARY, src.ADDRESS);


-- Users table
MERGE INTO Users dest
USING (
    SELECT USER_ID, PASSPORT, EMAIL, NAME, SURNAME1, SURNAME2, BIRTHDATE, PHONE, ADDRESS, TOWN, PROVINCE
    FROM (
        SELECT USER_ID, PASSPORT, EMAIL, NAME, SURNAME1, SURNAME2, BIRTHDATE, PHONE, ADDRESS, TOWN, PROVINCE,
               ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY USER_ID) AS rn
        FROM fsdb.loans
    )
    WHERE rn = 1
) src
ON (dest.user_id = src.USER_ID)
WHEN NOT MATCHED THEN
    INSERT (user_id, passport, email, name, surname1, surname2, birthdate, phone, address, town, province)
    VALUES (src.USER_ID, src.PASSPORT, src.EMAIL, src.NAME, src.SURNAME1, src.SURNAME2, src.BIRTHDATE, src.PHONE, src.ADDRESS, src.TOWN, src.PROVINCE);


-- Posts table
MERGE INTO Posts dest
USING (
    SELECT USER_ID, POST_DATE, POST, LIKES, DISLIKES, ISBN
    FROM (
        SELECT l.USER_ID, l.POST_DATE, NVL(l.Post, 'N/A') AS Post, l.LIKES, l.DISLIKES, e.ISBN,
               ROW_NUMBER() OVER (PARTITION BY l.USER_ID, l.POST_DATE, NVL(l.Post, 'N/A') ORDER BY l.USER_ID) AS rn
        FROM fsdb.loans l
        JOIN fsdb.acervus a ON l.SIGNATURE = a.SIGNATURE
        JOIN Editions e ON a.ISBN = e.ISBN
        JOIN Users u ON l.USER_ID = u.user_id  
    )
    WHERE rn = 1  
) src
ON (dest.user_id = src.USER_ID AND dest.post_date = src.POST_DATE AND dest.post = src.POST)
WHEN NOT MATCHED THEN
    INSERT (user_id, post_date, post, likes, dislikes, isbn)
    VALUES (src.USER_ID, src.POST_DATE, src.POST, src.LIKES, src.DISLIKES, src.ISBN);


-- Copies table
MERGE INTO Copies dest
USING (
    SELECT l.SIGNATURE, e.ISBN
    FROM fsdb.loans l
    JOIN fsdb.acervus a ON l.SIGNATURE = a.SIGNATURE
    JOIN Editions e ON a.ISBN = e.ISBN
    WHERE l.SIGNATURE IS NOT NULL AND e.ISBN IS NOT NULL  
) src
ON (dest.signature = src.SIGNATURE)
WHEN NOT MATCHED THEN
    INSERT (signature, isbn)
    VALUES (src.SIGNATURE, src.ISBN);


-- Loans table
MERGE INTO Loans dest
USING (
    SELECT 
        l.SIGNATURE, 
        u.USER_ID, 
        l.DATE_TIME, 
        l.RETURN
    FROM (
        SELECT 
            SIGNATURE, 
            USER_ID, 
            DATE_TIME, 
            RETURN,
            ROW_NUMBER() OVER (PARTITION BY SIGNATURE ORDER BY SIGNATURE) AS rn
        FROM fsdb.loans
        WHERE SIGNATURE IS NOT NULL
    ) l
    JOIN Users u ON l.USER_ID = u.USER_ID
    WHERE l.rn = 1  -- Keep only one row per unique SIGNATURE
    AND NOT EXISTS (
        SELECT 1
        FROM Loans dest
        WHERE dest.SIGNATURE = l.SIGNATURE
    )
) src
ON (dest.SIGNATURE = src.SIGNATURE)
WHEN NOT MATCHED THEN
    INSERT (SIGNATURE, USER_ID, DATE_TIME, RETURN)
    VALUES (src.SIGNATURE, src.USER_ID, src.DATE_TIME, src.RETURN);


-- Bibuses table
MERGE INTO Bibuses dest
USING (
    SELECT PLATE, LAST_ITV, NEXT_ITV, LIB_PASSPORT
    FROM (
        SELECT PLATE, LAST_ITV, NEXT_ITV, LIB_PASSPORT,
               ROW_NUMBER() OVER (PARTITION BY PLATE ORDER BY PLATE) AS rn
        FROM fsdb.busstops
    )
    WHERE rn = 1
) src
ON (dest.plate = src.PLATE)
WHEN NOT MATCHED THEN
    INSERT (plate, last_itv, next_itv, lib_passport)
    VALUES (src.PLATE, src.LAST_ITV, src.NEXT_ITV, src.LIB_PASSPORT);


-- Routes table 
MERGE INTO Routes dest
USING (
    SELECT ROUTE_ID, PLATE, STOPDATE, STOPTIME, TOWN, PROVINCE
    FROM (
        SELECT ROUTE_ID, PLATE, STOPDATE, STOPTIME, TOWN, PROVINCE,
               ROW_NUMBER() OVER (PARTITION BY ROUTE_ID, PLATE ORDER BY ROUTE_ID) AS rn
        FROM fsdb.busstops
    )
    WHERE rn = 1
) src
ON (dest.route_id = src.ROUTE_ID AND dest.plate = src.PLATE)
WHEN NOT MATCHED THEN
    INSERT (route_id, plate, stopdate, stoptime, town, province)
    VALUES (src.ROUTE_ID, src.PLATE, src.STOPDATE, src.STOPTIME, src.TOWN, src.PROVINCE);