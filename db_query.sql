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
	tanggal_lahir DATE,
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
('Afif','1994-01-01','Direktur','Ragunan'),
('Edwin','1995-01-01','Presiden','Pasar Minggu'),
('Ricky','1996-01-01','Kadiv','Jagakarsa'),
('Fadil','1997-01-01','Komisaris','Pasar Rebo'),
('Satria','1998-01-01','Mahasiswa','Tangsel');

INSERT INTO book(book_code, book_name, book_stock)
VALUES
(1347,'5 Second Rules',40),
(2431,'Finite Infinite Game',80),
(7586,'Atomic Habit',30),
(8260,'The Psychology of Money',70),
(4577,'Advanced Data Science',50);

