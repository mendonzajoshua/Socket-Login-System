# Secure Socket Login App

A simple client–server authentication app built using **Flutter**, **Python TCP sockets**, and **SQLite**.  
The app supports **user registration**, **login**, and **secure password update** using hashed passwords.

---

## Features

- User Registration
- User Login
- Update Password (old password required)
- Password hashing for security
- TCP socket communication (JSON-based)
- Clean Flutter UI

---

## Architecture

Flutter App -> Python Socket Server -> SQLite Database

- Flutter app acts as a TCP client
- Python server handles authentication logic
- SQLite stores hashed passwords

---

## Tech Stack

- Flutter (Dart)
- Python
- SQLite
- TCP Sockets
- JSON

---

## How to Run

1. Start the Python server

   ```bash
   python server.py

   ```

2. Update server IP in main.dart

3. Run the Flutter app on an Android device
   flutter run
