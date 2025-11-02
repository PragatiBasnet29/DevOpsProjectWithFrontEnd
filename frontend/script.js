// Frontend runs locally; backend exposed on localhost:5000

/*
Note:
The frontend is not containerized. It communicates with the backend via localhost.
*/
// Utility functions
// API endpoint configuration
// Set in config.js - defaults to localhost for local development
const API_BASE = window.API_BASE_URL || 'http://localhost:5000/api';

function showLoading(elementId) {
    document.getElementById(elementId).style.display = 'block';
}

function hideLoading(elementId) {
    document.getElementById(elementId).style.display = 'none';
}

function showMessage(elementId, message, type = 'success') {
    const element = document.getElementById(elementId);
    element.innerHTML = `<div class="${type}">${message}</div>`;
    setTimeout(() => element.innerHTML = '', 3000);
}

function handleError(error, elementId) {
    console.error('Error:', error);
    showMessage(elementId, `Error: ${error.message || 'Something went wrong'}`, 'error');
}

// Message functions
async function fetchMessage() {
    showLoading('messageLoading');
    try {
        const response = await fetch(`${API_BASE}/message`);
        const data = await response.json();
        document.getElementById('messageOutput').innerHTML = 
            `<div class="data-item">${data.message}</div>`;
    } catch (error) {
        handleError(error, 'messageOutput');
    } finally {
        hideLoading('messageLoading');
    }
}

async function fetchQuote() {
    showLoading('messageLoading');
    try {
        const response = await fetch(`${API_BASE}/random-quote`);
        const data = await response.json();
        document.getElementById('messageOutput').innerHTML = 
            `<div class="data-item">"${data.quote}"</div>`;
    } catch (error) {
        handleError(error, 'messageOutput');
    } finally {
        hideLoading('messageLoading');
    }
}

// User functions
async function fetchUsers() {
    showLoading('usersLoading');
    try {
        const response = await fetch(`${API_BASE}/users`);
        const data = await response.json();
        const usersHtml = data.users.map(user => 
            `<div class="data-item">
                <strong>${user.name}</strong><br>
                Email: ${user.email}<br>
                Role: ${user.role}
            </div>`
        ).join('');
        document.getElementById('usersOutput').innerHTML = usersHtml;
    } catch (error) {
        handleError(error, 'usersOutput');
    } finally {
        hideLoading('usersLoading');
    }
}

async function createUser() {
    const name = document.getElementById('userName').value;
    const email = document.getElementById('userEmail').value;
    const role = document.getElementById('userRole').value;

    if (!name || !email) {
        showMessage('userMessage', 'Please fill in all fields', 'error');
        return;
    }

    try {
        const response = await fetch(`${API_BASE}/users`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ name, email, role })
        });
        const data = await response.json();
        showMessage('userMessage', data.message);
        document.getElementById('userName').value = '';
        document.getElementById('userEmail').value = '';
        fetchUsers(); // Refresh the list
    } catch (error) {
        handleError(error, 'userMessage');
    }
}

// Task functions
async function fetchTasks() {
    showLoading('tasksLoading');
    try {
        const response = await fetch(`${API_BASE}/tasks`);
        const data = await response.json();
        const tasksHtml = data.tasks.map(task => 
            `<div class="data-item priority-${task.priority}">
                <strong>${task.title}</strong><br>
                Status: <span class="status-badge status-${task.status.replace('-', '-')}">${task.status}</span><br>
                Priority: ${task.priority}
            </div>`
        ).join('');
        document.getElementById('tasksOutput').innerHTML = tasksHtml;
    } catch (error) {
        handleError(error, 'tasksOutput');
    } finally {
        hideLoading('tasksLoading');
    }
}

async function createTask() {
    const title = document.getElementById('taskTitle').value;
    const priority = document.getElementById('taskPriority').value;
    const status = document.getElementById('taskStatus').value;

    if (!title) {
        showMessage('taskMessage', 'Please enter a task title', 'error');
        return;
    }

    try {
        const response = await fetch(`${API_BASE}/tasks`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ title, priority, status })
        });
        const data = await response.json();
        showMessage('taskMessage', data.message);
        document.getElementById('taskTitle').value = '';
        fetchTasks(); // Refresh the list
    } catch (error) {
        handleError(error, 'taskMessage');
    }
}

// Stats functions
async function fetchStats() {
    showLoading('statsLoading');
    try {
        const response = await fetch(`${API_BASE}/stats`);
        const data = await response.json();
        const statsHtml = `
            <div class="stat-item">
                <div class="stat-number">${data.total_users}</div>
                <div class="stat-label">Total Users</div>
            </div>
            <div class="stat-item">
                <div class="stat-number">${data.total_tasks}</div>
                <div class="stat-label">Total Tasks</div>
            </div>
            <div class="stat-item">
                <div class="stat-number">${data.completed_tasks}</div>
                <div class="stat-label">Completed</div>
            </div>
            <div class="stat-item">
                <div class="stat-number">${Math.round((data.completed_tasks / data.total_tasks) * 100) || 0}%</div>
                <div class="stat-label">Completion Rate</div>
            </div>
        `;
        document.getElementById('statsOutput').innerHTML = statsHtml;
    } catch (error) {
        handleError(error, 'statsOutput');
    } finally {
        hideLoading('statsLoading');
    }
}

// Auto-refresh stats every 30 seconds
setInterval(fetchStats, 30000);

