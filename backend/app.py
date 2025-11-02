from flask import Flask, jsonify, request
from flask_cors import CORS
import random
import time
from datetime import datetime
import os
import socket

app = Flask(__name__)
CORS(app)  # Enable CORS for frontend calls

# Sample data storage (in production, use a database)
users = [
    {"id": 1, "name": "Alice Johnson", "email": "alice@example.com", "role": "Developer"},
    {"id": 2, "name": "Bob Smith", "email": "bob@example.com", "role": "Designer"},
    {"id": 3, "name": "Carol Davis", "email": "carol@example.com", "role": "Manager"}
]

tasks = [
    {"id": 1, "title": "Implement user authentication", "status": "completed", "priority": "high"},
    {"id": 2, "title": "Design new dashboard", "status": "in-progress", "priority": "medium"},
    {"id": 3, "title": "Write API documentation", "status": "pending", "priority": "low"}
]

@app.route('/api/message')
def message():
    return jsonify({"message": "Hello from backend!"})

@app.route('/api/users')
def get_users():
    return jsonify({"users": users})

@app.route('/api/users', methods=['POST'])
def create_user():
    data = request.get_json()
    new_user = {
        "id": len(users) + 1,
        "name": data.get('name', ''),
        "email": data.get('email', ''),
        "role": data.get('role', 'User')
    }
    users.append(new_user)
    return jsonify({"user": new_user, "message": "User created successfully"})

@app.route('/api/tasks')
def get_tasks():
    return jsonify({"tasks": tasks})

@app.route('/api/tasks', methods=['POST'])
def create_task():
    data = request.get_json()
    new_task = {
        "id": len(tasks) + 1,
        "title": data.get('title', ''),
        "status": data.get('status', 'pending'),
        "priority": data.get('priority', 'medium')
    }
    tasks.append(new_task)
    return jsonify({"task": new_task, "message": "Task created successfully"})

@app.route('/api/stats')
def get_stats():
    return jsonify({
        "total_users": len(users),
        "total_tasks": len(tasks),
        "completed_tasks": len([t for t in tasks if t["status"] == "completed"]),
        "server_time": datetime.now().isoformat()
    })

@app.route('/api/random-quote')
def get_random_quote():
    quotes = [
        "The only way to do great work is to love what you do.",
        "Innovation distinguishes between a leader and a follower.",
        "Life is what happens to you while you're busy making other plans.",
        "The future belongs to those who believe in the beauty of their dreams."
    ]
    return jsonify({"quote": random.choice(quotes)})

def choose_host_and_port():
    desired_host = os.getenv('HOST', '0.0.0.0')
    desired_port_str = os.getenv('PORT', '5000')
    try:
        desired_port = int(desired_port_str)
    except ValueError:
        desired_port = 5000

 # Check if desired port is available, if yes, return it    
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        sock.settimeout(0.5)
        if sock.connect_ex((desired_host, desired_port)) != 0:
            return desired_host, desired_port

    # If desired port is in use, pick a free ephemeral port from OS
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        sock.bind((desired_host, 0))
        _, free_port = sock.getsockname()
        return desired_host, free_port

if __name__ == '__main__':
    # Determine host and port dynamically, allowing Kubernetes to control via env vars
    host, port = choose_host_and_port()
    print(f"Starting server on {host}:{port}") # Logs the chosen host and port
    app.run(host=host, port=port, debug=True) # Starts the flask app on chosen host and port with debug enabled