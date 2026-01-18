import socket
import sqlite3
import json
import bcrypt

HOST = "192.168.29.209"
PORT = 5001

# Connect to SQLite DB
conn = sqlite3.connect("users.db", check_same_thread=False)
cursor = conn.cursor()

# Create table if not exists
cursor.execute("""
CREATE TABLE IF NOT EXISTS users (
    username TEXT PRIMARY KEY,
    password BLOB
)
""")
conn.commit()

# Socket server
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_socket.bind((HOST, PORT))
server_socket.listen(5)
print(f"[SERVER] Running on port {PORT}")

def handle_client(client_socket):
    try:
        data = client_socket.recv(1024).decode()
        request = json.loads(data)
        action = request.get("action")
        username = request.get("username")
        password = request.get("password")
        old_password = request.get("old_password")
        new_password = request.get("new_password")

        if action == "register":
            cursor.execute("SELECT * FROM users WHERE username=?", (username,))
            if cursor.fetchone():
                client_socket.send("User already exists".encode())
            else:
                hashed_pw = bcrypt.hashpw(password.encode(), bcrypt.gensalt())
                cursor.execute("INSERT INTO users (username, password) VALUES (?, ?)", (username, hashed_pw))
                conn.commit()
                client_socket.send("Registered successfully".encode())

        elif action == "login":
            cursor.execute("SELECT password FROM users WHERE username=?", (username,))
            row = cursor.fetchone()
            if row and bcrypt.checkpw(password.encode(), row[0]):
                client_socket.send("Login successful".encode())
            else:
                client_socket.send("Invalid username or password".encode())

        elif action == "update":
            # Requires old_password + new_password
            cursor.execute("SELECT password FROM users WHERE username=?", (username,))
            row = cursor.fetchone()
            if row and bcrypt.checkpw(old_password.encode(), row[0]):
                new_hashed = bcrypt.hashpw(new_password.encode(), bcrypt.gensalt())
                cursor.execute("UPDATE users SET password=? WHERE username=?", (new_hashed, username))
                conn.commit()
                client_socket.send("Password updated successfully".encode())
            else:
                client_socket.send("Old password is incorrect".encode())

        else:
            client_socket.send("Invalid action".encode())
    except Exception as e:
        client_socket.send(f"Error: {e}".encode())
    finally:
        client_socket.close()

while True:
    client, addr = server_socket.accept()
    print(f"[CONNECTION] {addr} connected")
    handle_client(client)
