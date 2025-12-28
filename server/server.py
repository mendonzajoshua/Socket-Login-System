import socket

HOST = '0.0.0.0'
PORT = 5001

server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_socket.bind((HOST, PORT))
server_socket.listen(5)

print(f"Server started on {HOST}:{PORT}")
print("Waiting for client connection...")

while True:
    client_socket, client_address = server_socket.accept()
    print(f"Connected by {client_address}")

    data = client_socket.recv(1024).decode()
    print("Received:", data)

    response = "Hello from Python Server 😎. Hi!"
    client_socket.send(response.encode())

    client_socket.close()