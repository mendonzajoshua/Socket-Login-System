import socket

HOST = '127.0.0.1'
PORT = 5001

client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client_socket.connect((HOST, PORT))

client_socket.send("Test message from client".encode())

response = client_socket.recv(1024).decode()
print("Server replied:", response)

client_socket.close()