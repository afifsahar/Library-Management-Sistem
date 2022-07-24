use `library1`;

DROP TABLE user;
DROP TABLE book;
DROP TABLE borrowBook;

DROP TRIGGER borrow_book;
DROP TRIGGER return_book; 
SHOW TRIGGERS;

TRUNCATE user;
TRUNCATE book;
TRUNCATE borrowBook;

-- Tabel Pengguna
CREATE TABLE IF NOT EXISTS user(
    user_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_name VARCHAR(255) NOT NULL,
    user_profession VARCHAR(255),
    user_address VARCHAR(255) NOT NULL,
    create_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modify_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabel Buku
CREATE TABLE IF NOT EXISTS book(
    book_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    book_code INT UNSIGNED NOT NULL UNIQUE,
    book_name VARCHAR(255) NOT NULL,
    book_stock INT UNSIGNED NOT NULL,
    create_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modify_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabel Pinjam Buku
CREATE TABLE IF NOT EXISTS borrowBook(
    borrowBook_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    bookId_fk INT UNSIGNED,
    userId_fk INT UNSIGNED NOT NULL,
    borrow_date DATE DEFAULT (CURRENT_DATE) NOT NULL,
    return_date DATE,
    is_return BOOLEAN DEFAULT FALSE,
    returned_on DATE,
    lateness INT UNSIGNED,
    FOREIGN KEY (bookId_fk) REFERENCES book(book_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (userId_fk) REFERENCES user(user_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Trigger Aksi Ketika Buku Dipinjamkan
DELIMITER $$
CREATE TRIGGER borrow_book
    BEFORE INSERT
    ON borrowBook FOR EACH ROW
BEGIN
    IF NEW.borrow_date IS NOT NULL THEN
		SET NEW.return_date = DATE_ADD(NEW.borrow_date,interval 3 day);
        UPDATE book SET book_stock = book_stock-1 WHERE book_id = NEW.bookId_fk;
	END IF;
END$$    
DELIMITER ;

-- Trigger Aksi Ketika Buku Dikembalikan
DELIMITER $$
CREATE TRIGGER return_book
    BEFORE UPDATE
    ON borrowBook FOR EACH ROW
BEGIN
	IF NEW.is_return = 1 AND NEW.returned_on IS NULL THEN
        SET NEW.returned_on = CURRENT_DATE();
        UPDATE book SET book_stock = book_stock+1 WHERE book_id = OLD.bookId_fk;
        IF NEW.returned_on > OLD.return_date THEN
			SET NEW.lateness = datediff(NEW.returned_on, OLD.return_date);
		ELSE
			SET NEW.lateness = 0;
		END IF;
	ELSEIF OLD.is_return = 0 AND NEW.returned_on IS NOT NULL THEN
		SET NEW.is_return = 1;
        UPDATE book SET book_stock = book_stock+1 WHERE book_id = OLD.bookId_fk;
        IF NEW.returned_on > OLD.return_date THEN
			SET NEW.lateness = datediff(NEW.returned_on, OLD.return_date);
		ELSE
			SET NEW.lateness = 0;
		END IF;
    END IF;
END$$    
DELIMITER ;

INSERT INTO user(user_name, user_profession, user_address)
VALUES
('Afif','Direktur','Ragunan'),
('Edwin','Presiden','Pasar Minggu'),
('Ricky','Kadiv','Jagakarsa'),
('Fadil','Komisaris','Pasar Rebo'),
('Satria','Mahasiswa','Tangsel');

INSERT INTO book(book_code, book_name, book_stock)
VALUES
(1347,'5 Second Rules',40),
(2431,'Finite Infinite Game',80),
(7586,'Atomic Habit',30),
(8260,'The Psychology of Money',70),
(4577,'Advanced Data Science',50);

INSERT INTO borrowBook(bookId_fk, userId_fk)
VALUES (1,1),(1,2),(1,3);


UPDATE borrowBook SET is_return = TRUE WHERE borrowBook_id = 1;
UPDATE borrowBook SET returned_on = '2022-07-22' WHERE borrowBook_id = 2;
UPDATE borrowBook 
SET
is_return = True,
returned_on = '2022-07-26'
WHERE borrowBook_id = 3;

ALTER TABLE user ADD tanggal_lahir DATE;


select bb.borrowBook_id, b.book_code, b.book_name, u.user_name, 
	bb.borrow_date, bb.returned_on, bb.lateness
from borrowbook bb
	join book b
		on bb.bookId_fk = b.book_id
	join user u
		on bb.userId_fk = u.user_id;

SELECT * FROM book WHERE book_name REGEXP 's' or book_code REGEXP 's';

-- SELECT @bookId := 1;
SELECT @bookId := book_id FROM book WHERE book_code=1347;
INSERT INTO borrowBook(bookId_fk, userId_fk)
VALUES (@bookId,1);
UPDATE borrowBook SET is_return = TRUE WHERE borrowBook_id = @bookId AND userId = 1;

