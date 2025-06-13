-- Create AUTHOR table
CREATE TABLE Author (
    Author_ID INT PRIMARY KEY,
    Author_Name VARCHAR(100) NOT NULL,
    Nationality VARCHAR(50)
);

-- Create BOOK table
CREATE TABLE Book (
    Book_ID INT PRIMARY KEY,
    Title VARCHAR(70) NOT NULL,
    Publish_Date DATE,
    Copies_Available INT,
    Publisher VARCHAR (50)
);

-- Create GENRE table
CREATE TABLE Genre (
    Genre_ID INT PRIMARY KEY,
    Name varchar(50)
);

-- Create HAS_GENRE table   (Junction table)
CREATE TABLE Has_Genre (
    genre_id INT NOT NULL,
    book_id INT NOT NULL,
    PRIMARY KEY (genre_id, book_id),
    FOREIGN KEY (genre_id) REFERENCES Genre(genre_id),
);
--Adding the constraint on HAS_GENRE
ALTER TABLE HAS_GENRE
ADD CONSTRAINT FK_GENRE FOREIGN KEY (Book_ID) REFERENCES Book (Book_ID) 
ON DELETE CASCADE; -- if a book_id is deleted from the book table,
--then the corresponding book_id in the HAS_GENRE table is also deleted


-- Create AUTHOR_BOOK table  (Junction table)
CREATE TABLE Author_Book (
    Author_ID INT,
    Book_ID INT,
    PRIMARY KEY (Author_ID, Book_ID)
);
-- Add the foreign key constraints for the Author_Book table
ALTER TABLE Author_Book
ADD CONSTRAINT WRITES FOREIGN KEY (Author_ID) REFERENCES Author (Author_ID);
ALTER TABLE Author_Book
ADD CONSTRAINT WRITES_BOOK FOREIGN KEY (Book_ID) REFERENCES Book (Book_ID)
ON DELETE CASCADE; -- if a book_id is deleted from the book table,
--then the corresponding book_id in the Author_Book table is also deleted


-- Create MEMBER table
CREATE TABLE Member (
    Member_ID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Registration_Date DATE,
    Email_Address VARCHAR(100)
);

-- Create MEMBER_PHONE table   (table for multi-valued attribute)
CREATE TABLE Member_Phone ( 
    Member_ID INT,             
    Phone_Number VARCHAR(20), 
    primary key(Member_ID,Phone_Number), 
    CONSTRAINT FK_Member_Phone FOREIGN KEY (Member_ID) REFERENCES Member (Member_ID)
);

-- Create STAFF table
CREATE TABLE Staff (
    Staff_ID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Hire_Date DATE,
    Salary DECIMAL(10, 2),
    Phone_Number VARCHAR(20)
);

-- Create LOAN table
CREATE TABLE Loan (
    Loan_ID INT PRIMARY KEY,
    Member_ID INT,
    Loan_Date DATE, --The date the member borrowed the book
    Return_Date DATE, --The date the book is supposed to be returned (after 14 days)
    Staff_ID INT
);
-- Add the foreign key constraints for the Loan table
ALTER TABLE Loan
ADD CONSTRAINT MANAGED_BY FOREIGN KEY (Staff_ID) REFERENCES Staff (Staff_ID);
ALTER TABLE Loan
ADD CONSTRAINT BORROWS FOREIGN KEY (Member_ID) REFERENCES Member (Member_ID);

-- Create Loan_includes table  (Junction table)
CREATE TABLE Loan_Includes(
    Book_ID int,
    Loan_ID int,
    primary key(book_id, loan_id),
    Foreign key(Book_ID) references Book(Book_ID),
    Foreign key(Loan_ID) references Loan(loan_id)
);  


-- Create FINE table
CREATE TABLE Fine (
    Fine_ID INT,
    Loan_ID INT,
    PRIMARY KEY(Fine_ID, Loan_ID),
    Fine_Per_Day DECIMAL(10, 2),
    Amount_To_Pay DECIMAL(10, 2),
    Overdue_Days INT,
    Due_Date DATE, --The day the book was actually returned
    Previous_Due_Date DATE, --The day the book was supposed to be returned
    Payment_Status VARCHAR(20)
);
-- Add the foreign key constraint for the Fine table
ALTER TABLE Fine
ADD CONSTRAINT GENERATES FOREIGN KEY (Loan_ID) REFERENCES Loan (Loan_ID);


-- Select query for overdue days and fine amount calculation
SELECT Loan.Loan_ID, Loan.Member_ID, Fine.Due_Date, Fine.Previous_Due_Date, Fine.Payment_Status,
    CASE 
        WHEN Fine.Due_Date > Fine.Previous_Due_Date THEN DATEDIFF(DAY, Fine.Previous_Due_Date, Fine.Due_Date)
        ELSE 0
    END AS Overdue_Days,
    CASE 
        WHEN Fine.Due_Date > Fine.Previous_Due_Date THEN DATEDIFF(DAY, Fine.Previous_Due_Date, Fine.Due_Date) * Fine.Fine_Per_Day
        ELSE 0
    END AS Amount_To_Pay
FROM Fine
INNER JOIN Loan ON Fine.Loan_ID = Loan.Loan_ID
WHERE Fine.Due_Date IS NOT NULL;



--To delete the author if they have no books related to them
DELETE FROM Author 
WHERE Author_ID NOT IN (SELECT DISTINCT Author_ID FROM Author_Book);
--To delete the genre if they have no books related to them
DELETE FROM GENRE
WHERE Genre_ID NOT IN (
    SELECT DISTINCT Genre_ID
    FROM HAS_GENRE
    WHERE Book_ID IN (SELECT Book_ID FROM Book)
);



-- Book
insert into Book (Book_ID, title, Publish_Date, publisher, Copies_available)
VALUES
(1, 'The Great Gatsby', '1925-04-10', 'Charles Scribners Sons', 5),
(2, '1984', '1949-06-08', 'Secker & Warburg', 3),
(3, 'To Kill a Mockingbird', '1960-07-11', 'J.B. Lippincott & Co.', 4),
(4, 'Moby-Dick', '1851-10-18', 'Harper & Brothers', 2),
(5, 'Pride and Prejudice', '1813-01-28', 'T. Egerton, Whitehall', 6),
(6, 'The Catcher in the Rye', '1951-07-16', 'Little, Brown and Company', 4),
(7, 'The Hobbit', '1937-09-21', 'George Allen & Unwin', 7),
(8, 'War and Peace', '1869-01-01', 'The Russian Messenger', 3),
(9, 'The Odyssey', '1900-01-01', 'Ancient Texts', 8),
(10, 'Crime and Punishment', '1866-01-01', 'The Russian Messenger', 5),
(11, 'The Grapes of Wrath', '1939-04-14', 'The Viking Press', 4),
(12, 'Wuthering Heights', '1847-12-01', 'Thomas Cautley Newby', 3),
(13, 'Frankenstein', '1818-01-01', 'Lackington, Hughes, Harding, Mavor & Jones', 6),
(14, 'Dracula', '1897-05-26', 'Archibald Constable and Company', 2),
(15, 'Anna Karenina', '1878-04-01', 'The Russian Messenger', 5),
(16, 'Brave New World', '1932-08-01', 'Chatto & Windus', 3),
(17, 'The Picture of Dorian Gray', '1890-07-01', 'Lippincotts Monthly Magazine', 4),
(18, 'Heart of Darkness', '1899-02-01', 'Blackwoods Magazine', 3),
(19, 'Les Misérables', '1862-04-03', 'A. Lacroix, Verboeckhoven & Cie', 7),
(20, 'The Divine Comedy', '1900-01-01', 'Ancient Texts', 5),
(21, 'The Lord of the Rings', '1954-07-29', 'George Allen & Unwin', 9),
(22, 'Ulysses', '1922-02-02', 'Sylvia Beach', 4),
(23, 'The Catcher in the Rye', '1951-07-16', 'Little, Brown and Company', 3),
(24, 'Catcher in the Rye', '1951-07-16', 'Little, Brown and Company', 5),
(25, 'The Chronicles of Narnia', '1950-10-16', 'Geoffrey Bles', 8),
(26, 'Harry Potter and the Philosophers Stone', '1997-06-26','George Allen & Unwin', 5),
(27, 'The Old Man and the Sea', '1952-09-01', 'Charles Scribners Sons', 4),
(28, 'Jane Eyre', '1847-10-16', 'Smith, Elder & Co.', 6);

--Author 
insert into Author (Author_ID, Author_Name, Nationality)
values
(1, 'F. Scott Fitzgerald', 'American'),
(2, 'George Orwell', 'British'),
(3, 'Harper Lee', 'American'),
(4, 'Herman Melville', 'American'),
(5, 'Jane Austen', 'British'),
(6, 'J.D. Salinger', 'American'),
(7, 'J.R.R. Tolkien', 'British'),
(8, 'Leo Tolstoy', 'Russian'),
(9, 'Homer', 'Greek'),
(10, 'Fyodor Dostoevsky', 'Russian'),
(11, 'John Steinbeck', 'American'),
(12, 'Emily Brontë', 'British'),
(13, 'Mary Shelley', 'British'),
(14, 'Bram Stoker', 'Irish'),
(15, 'Charles Dickens', 'British'),
(16, 'Mark Twain', 'American'),
(17, 'J.K. Rowling', 'British'),
(18, 'Gabriel García Márquez', 'Colombian'),
(19, 'Virginia Woolf', 'British'),
(20, 'Agatha Christie', 'British'),
(21, 'Isaac Asimov', 'American'),
(22, 'Arthur C. Clarke', 'British'),
(23, 'Philip K. Dick', 'American'),
(24, 'Ray Bradbury', 'American'),
(25, 'Kurt Vonnegut', 'American'),
(26, 'J.K. Rowling', 'British'),
(27, 'C.S. Lewis', 'British'),
(28, 'George Eliot', 'British');

--Writes
insert into Author_Book(Author_ID, Book_ID)
values
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5), (6, 6), (7, 7), (8, 8), (9, 9), (10, 10),
(11, 11), (12, 12), (13, 13), (14, 14), (15, 15), (16, 16), (17, 17),(18, 18), (19, 19),
(21, 21), (22, 22), (23, 23), (24, 24), (25, 25), (26, 26), (27, 27), (28, 28);

--Genre
insert into Genre (Genre_ID, Name) values 
(1, 'Fiction'), (2, 'Fantasy'), (3, 'Science Fiction'), (4, 'Mystery'),
(5, 'Romance'), (6, 'Historical Fiction'), (7, 'Thriller'), (8, 'Horror'),
(9, 'Adventure'), (10, 'Young Adult'), (11, 'Childrens Literature'),
(12, 'Biography'), (13, 'Autobiography'), (14, 'Memoir'), (15, 'Self-Help'),
(16, 'Non-Fiction'), (17, 'Classics'), (18, 'Humor'), (19, 'Poetry'),
(20, 'Drama'), (21, 'Graphic Novel'), (22, 'Short Stories'), (23, 'Contemporary'),
(24, 'Literary Fiction'), (25, 'Crime');
--Has Genre
insert into Has_Genre (book_id, genre_id) values
(1, 21), 
(2, 1), (2, 24),
(3, 9), (3, 8),
(4, 8), (4, 5),
(5, 24), (5, 4),
(6, 14),
(7, 25), (7, 21),
(8, 9), (8, 24),
(9, 13), (9, 14),
(10, 19),
(11, 1),
(12, 4), 
(13, 8),
(14, 5), (14, 7),
(15, 14), (15, 18),
(16, 20), (16, 3),
(17, 10),
(18, 23),
(19, 2), (19, 11),
(20, 9), (20, 7),
(21, 1), (21, 4),
(22, 20),
(23, 6), (23, 19),
(24, 25), (24, 2),
(25, 18),
(26, 14), 
(27, 12), (27, 13),
(28, 23), (28, 6);


--Members
insert into Member (Member_ID, Name, Registration_Date, Email_Address)
values
(1, 'John Doe', '2024-01-01', 'johndoe@example.com'),
(2, 'Jane Smith', '2024-01-03', 'janesmith@example.com'),
(3, 'Michael Johnson', '2024-01-05', 'michaelj@example.com'),
(4, 'Emily Brown', '2024-01-07', 'emilyb@example.com'),
(5, 'David Wilson', '2024-01-09', 'davidw@example.com'),
(6, 'Sarah Lee', '2024-01-12', 'sarahlee@example.com'),
(7, 'James Taylor', '2024-01-15', 'jamestaylor@example.com'),
(8, 'Laura Martinez', '2024-01-18', 'lauram@example.com'),
(9, 'Paul Anderson', '2024-01-21', 'paulanderson@example.com'),
(10, 'Olivia Thomas', '2024-01-25', 'oliviat@example.com'),
(11, 'Daniel White', '2024-01-28', 'danielw@example.com'),
(12, 'Sophia Harris', '2024-02-01', 'sophiah@example.com'),
(13, 'Liam Clark', '2024-02-04', 'liamc@example.com'),
(14, 'Ethan Lewis', '2024-02-07', 'ethanl@example.com'),
(15, 'Ava Walker', '2024-02-10', 'avaw@example.com'),
(16, 'Mason Hall', '2024-02-13', 'masonh@example.com'),
(17, 'Isabella Allen', '2024-02-16', 'isabella@example.com'),
(18, 'Lucas Young', '2024-02-19', 'lucasy@example.com'),
(19, 'Charlotte King', '2024-02-22', 'charlottek@example.com'),
(20, 'Amelia Scott', '2024-02-25', 'amelias@example.com'),
(21, 'Benjamin Adams', '2024-02-28', 'benjamin@example.com'),
(22, 'Harper Baker', '2024-03-03', 'harperb@example.com'),
(23, 'William Gonzalez', '2024-03-06', 'williamg@example.com'),
(24, 'Ella Perez', '2024-03-09', 'ellap@example.com'),
(25, 'Jack Roberts', '2024-03-12', 'jackr@example.com'),
(26, 'Mia Martinez', '2024-03-15', 'miam@example.com'),
(27, 'Henry Thompson', '2024-03-18', 'henryt@example.com'),
(28, 'Zoe Lee', '2024-03-21', 'zoel@example.com'),
(29, 'Gabriel Moore', '2024-03-24', 'gabrielm@example.com'),
(30, 'Chloe Jackson', '2024-03-27', 'chloej@example.com');

--MemberPhone
insert into Member_Phone(Member_ID, Phone_Number)
values
(1, '11234567890'), (1, '15012345678'),
(2, '12345678901'),
(3, '11298765432'), (3, '15023456789'),
(4, '12123456789'),
(5, '11234567891'), (5, '15034567890'),
(6, '12345678902'),
(7, '11234567892'), (7, '15045678901'),
(8, '12134567890'),
(9, '11234567893'), (9, '15056789012'),
(10, '12345678903'),
(11, '11234567894'), (11, '15067890123'),
(12, '12145678901'),
(13, '11234567895'), (13, '15078901234'),
(14, '12345678904'),
(15, '11234567896'), (15, '15089012345'),
(16, '12156789012'),
(17, '11234567897'), (17, '15090123456'),
(18, '12345678905'),
(19, '11234567898'), (19, '15091234567'),
(20, '12167890123'),
(21, '11234567899'),
(22, '15092345678'), (22, '12345678906'),
(23, '11234567900'),
(24, '15093456789'), (24, '12178901234'),
(25, '11234567901'), (25, '15094567890'),
(26, '12345678907'),
(27, '11234567902'),
(28, '15095678901'), (28, '12189012345'),
(29, '11234567903'),
(30, '15096789012'), (30, '12345678908');

--Staff
insert into Staff (Staff_ID, Name, Phone_Number, Hire_Date, Salary)
values
(1, 'Alice Turner', 7001234561, '2022-01-15', 4000.00),
(2, 'Brad Cooper', 7001234562, '2021-05-20', 5500.00),
(3, 'Cathy Roberts', 7001234563, '2023-03-10', 4000.00),
(4, 'David Morgan', 7001234564, '2019-07-25', 4000.00),
(5, 'Emma Sanchez', 7001234565, '2020-10-05', 4000.00);

-- Loan
insert into Loan (Loan_ID, Loan_Date, Return_Date, Member_ID, Staff_ID)
values
(1, '2024-01-01', '2024-01-15', 1, 1),
(2, '2024-01-03', '2024-01-17', 2, 2), 
(3, '2024-01-05', '2024-01-19', 3, 3), 
(4, '2024-01-07', '2024-01-21', 4, 1),
(5, '2024-01-09', '2024-01-23', 5, 2),
(6, '2024-01-12', '2024-01-26', 1, 3),
(7, '2024-01-15', '2024-01-29', 4, 1),
(8, '2024-01-18', '2024-02-01', 8, 2), 
(9, '2024-01-21', '2024-02-04', 9, 3),
(10, '2024-01-25', '2024-02-08', 10, 1), 
(11, '2024-02-01', '2024-02-15', 11, 2), 
(12, '2024-02-07', '2024-02-21', 12, 3), 
(13, '2024-02-13', '2024-02-27', 13, 1),
(14, '2024-02-19', '2024-03-04', 4, 2),
(15, '2024-02-25', '2024-03-10', 15, 3), 
(16, '2024-03-03', '2024-03-17', 16, 1), 
(17, '2024-03-09', '2024-03-23', 17, 2), 
(18, '2024-03-15', '2024-03-29', 18, 3),
(19, '2024-03-21', '2024-04-04', 19, 1),
(20, '2024-03-27', '2024-04-10', 20, 2);


-- Fine
insert into Fine (Fine_ID, Fine_Per_Day, Previous_Due_Date, Payment_Status, Due_Date, Loan_ID)
values
(1, 12.00, '2024-01-15', 'Paid', '2024-01-21', 1), -- 20 days overdue (6 days fined)
(2, 12.00, '2024-01-17', 'Pending', '2024-01-18', 2), -- 15 days overdue (1 day fined)
(3, 12.00, '2024-01-19', 'Paid', '2024-01-22', 3), -- 17 days overdue (3 days fined)
(4, 12.00, '2024-02-01', 'Pending', '2024-02-05', 8), -- 18 days overdue (4 days fined)
(5, 12.00, '2024-01-23', 'Paid', '2024-01-25', 10), -- 16 days overdue (2 days fined)
(6, 12.00, '2024-01-26', 'Pending', '2024-01-27', 11), -- 15 days overdue (1 day fined)
(7, 12.00, '2024-01-29', 'Paid', '2024-01-31', 12), -- 16 days overdue (2 days fined)
(8, 12.00, '2024-02-04', 'Pending', '2024-02-6', 15), -- 16 days overdue (2 days fined)
(9, 12.00, '2024-02-08', 'Paid', '2024-02-11', 16), -- 17 days overdue (3 days fined)
(10, 12.00, '2024-02-10', 'Pending', '2024-02-13', 17); -- 17 days overdue (3 days fined)
