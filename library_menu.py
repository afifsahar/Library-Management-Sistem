from pickle import TRUE
from turtle import pd
from mysql.connector import Error
from ast import Break
import pandas as pd
from tabulate import tabulate

def register_user(connection):
    try:
        cursor = connection.cursor()
        user_name = input('Masukkan Nama User: ')
        tanggal_lahir = input('Masukkan Tanggal Lahir (YYYY-MM-DD): ')
        user_profession = input('Masukkan Pekerjaan: ')
        user_address = input('Masukkan Alamat: ')
        query = (f"""INSERT INTO user (user_name, tanggal_lahir, user_profession, user_address)
                    VALUES ('{user_name}','{tanggal_lahir}','{user_profession}', '{user_address}')""")
        cursor.execute(query)
        connection.commit()
        print("Permintaan BERHASIL dieksekusi")
    except Error as err:
        print("Permintaan GAGAL dieksekusi")
        print(f"Error: {err}")

def register_book(connection):
    try:
        cursor = connection.cursor()
        book_code = int(input('Masukkan Kode Buku (4 Digit Angka): '))
        book_name = input('Masukkan Nama Buku: ')
        book_stock = int(input('Masukkan Stok Buku: '))
        query = (f"""INSERT INTO book (book_code, book_name, book_stock) 
                    VALUES ({book_code}, '{book_name}', {book_stock})""")
        cursor.execute(query)
        connection.commit()
        print("Permintaan BERHASIL dieksekusi")
    except Error as err:
        print("Permintaan GAGAL dieksekusi")
        print(f"Error: {err}")

def borrow_book(connection):
    try:
        cursor = connection.cursor()
        book_code = int(input('Masukkan Kode Buku (4 Digit Angka): '))
        query1 = (f"""SELECT book_id FROM book WHERE book_code = {book_code}""")
        cursor.execute(query1)
        result = cursor.fetchall()
        user_id = int(input('Masukkan ID User: '))
        query2 = (f"""INSERT INTO borrowBook(bookId_fk, userId_fk)
                    VALUES ({result[0][0]},{user_id});""")
        cursor.execute(query2)
        connection.commit()
        print("Permintaan BERHASIL dieksekusi")
    except Error as err:
        print("Permintaan GAGAL dieksekusi")
        print(f"Error: {err}")

def show_user_list(connection):
    try:
        cursor = connection.cursor()
        result = None
        query = (f"""SELECT user_id, user_name, user_profession, user_address FROM user""")
        cursor.execute(query)
        result = cursor.fetchall()
        pd_result = pd.DataFrame(result)
        pd_result.columns = ['ID','Nama User','Pekerjaan','Alamat']
        return print(pd.DataFrame(pd_result))
    except Error as err:
        print("Permintaan GAGAL dieksekusi")
        print(f"Error: {err}")

def show_book_list(connection):
    try:
        cursor = connection.cursor()
        result = None
        query = (f"""SELECT book_id, book_code, book_name, book_stock FROM book""")
        cursor.execute(query)
        result = cursor.fetchall()
        pd_result = pd.DataFrame(result)
        pd_result.columns = ['ID','Code Buku','Nama Buku','Stok Buku']
        return print(pd.DataFrame(pd_result))
    except Error as err:
        print("Permintaan GAGAL dieksekusi")
        print(f"Error: {err}")

def show_borrowing(connection):
    try:
        cursor = connection.cursor()
        result = None
        query = (f"""select bb.borrowBook_id, b.book_code, b.book_name, u.user_name, 
                        bb.borrow_date, bb.returned_on, bb.lateness
                    from borrowbook bb
                        join book b
                            on bb.bookId_fk = b.book_id
                        join user u
                            on bb.userId_fk = u.user_id;""")
        cursor.execute(query)
        result = cursor.fetchall()
        pd_result = pd.DataFrame(result)
        pd_result.columns = ['ID Peminjaman','Code Buku','Nama Buku','Nama Peminjam','Tanggal Pinjaman', 'Tanggal Pengembalian','Keterlambatan']
        return print(pd.DataFrame(pd_result))
    except Error as err:
        print("Permintaan GAGAL dieksekusi")
        print(f"Error: {err}")
    pass

def search_book(connection):
    try:
        cursor = connection.cursor()
        result = None
        kiwod = input("Masukkan kata kunci: ")
        query = (f"""SELECT book_id, book_code, book_name, book_stock FROM book WHERE book_name REGEXP '{kiwod}' or book_code REGEXP '{kiwod}';""")
        cursor.execute(query)
        result = cursor.fetchall()
        pd_result = pd.DataFrame(result)
        pd_result.columns = ['ID','Code Buku','Nama Buku','Stok Buku']
        return print(pd.DataFrame(pd_result))
    except Error as err:
        print("Permintaan GAGAL dieksekusi")
        print(f"Error: {err}")
    pass

def return_book(connection):
    try:
        cursor = connection.cursor()
        book_code = int(input('Masukkan Kode Buku (4 Digit Angka): '))
        query1 = (f"""SELECT book_id FROM book WHERE book_code = {book_code}""")
        cursor.execute(query1)
        result = cursor.fetchall()
        user_id = int(input('Masukkan ID User: '))
        query2 = (f"""UPDATE borrowBook SET is_return = TRUE 
                WHERE bookId_fk = {result[0][0]} AND userId_fk = {user_id}""")
        cursor.execute(query2)
        connection.commit()
        print("Permintaan BERHASIL dieksekusi")
    except Error as err:
        print("Permintaan GAGAL dieksekusi")
        print(f"Error: {err}")