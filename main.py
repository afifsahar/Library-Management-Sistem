from ast import Break
from pickle import TRUE
import sys
import mysql.connector
from mysql.connector import Error
from db_query import *
import pandas as pd
from library_menu import *

host_name = "localhost"
user_name = 'root'
user_password = "root"
db = 'library1'

connection = None
try:
    connection = mysql.connector.connect(
        host=host_name,
        user=user_name,
        password=user_password,
        database=db
    )
    flag = TRUE
    menu = {
            1: register_user,
            2: register_book,
            3: borrow_book,
            4: show_user_list,
            5: show_book_list,
            6: show_borrowing,
            7: search_book,
            8: return_book,
        }
    print(".............Berhasil Terbuhung dengan Database.............")
    while flag==TRUE:
        print("........................................................")
        print(".............Selamat Datang di Library 1.............")
        print("\t 1. Pendaftaran User Baru")
        print("\t 2. Pendaftaran Buku Baru")
        print("\t 3. Peminjaman")
        print("\t 4. Tampilkan Daftar User")
        print("\t 5. Tampilkan Daftar Buku")
        print("\t 6. Tampilkan Daftar Peminjaman")
        print("\t 7. Cari Buku")
        print("\t 8. Pengembalian")
        print("\t 9. Keluar Menu")
        print("\n")
        try:
            print("........................................................")
            menu_pointer = int(input("Masukkan Nomor Tugas (1-9): "))
            if menu_pointer>=1 and menu_pointer<=9:
                if menu_pointer == 9:
                    flag = False
                    sys.exit()
                else:
                    print("........................................................")
                    menu[menu_pointer](connection)
            else:
                continue
        except:
            print("Permintaan GAGAL dieksekusi")
            continue
        if flag == False:
            print("........................................................")
            print("........Anda Keluar Dari Menu !!..........")
            print("Tekan 8 untuk  Kembali ke Menu")
            print("Tekan Tombol Apapun untuk Keluar Sistem")
            print("\n")
            pilihan = (input("Masukkan Pilihan Anda: "))
            if pilihan == '8':
                flag = TRUE
            else:
                print("........................................................")
                print(".............Sampai Jumpa Kembali.............")
                sys.exit()
except Error as err:
    print("Error: Gagal Terbuhung dengan Database")
    print(f"Error: {err}")
    print("Info: Hubungi Petugas Berwenang")
