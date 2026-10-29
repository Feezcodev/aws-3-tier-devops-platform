const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const fs = require('fs');
require('dotenv').config();

const app = express();
app.use(express.json());
app.use(cors());

// Read a secret from a mounted file when configured,
// otherwise fall back to the environment variable.
function getConfigValue(name, fallback) {
    const filePath = process.env[`${name}_FILE`];

    if (filePath) {
        return fs.readFileSync(filePath, 'utf8').trim();
    }

    return process.env[name] || fallback;
}

// Database connection pool
const pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: getConfigValue('DB_PASSWORD', 'password'),
    database: getConfigValue('DB_NAME', 'app_db'),
    port: Number(process.env.DB_PORT || 3306),
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// Health check endpoint
app.get('/health', (req, res) => {
    res.status(200).json({
        status: 'UP',
        timestamp: new Date()
    });
});

// API items endpoint
app.get('/api/items', (req, res) => {
    pool.query('SELECT * FROM items', (err, results) => {
        if (err) {
            console.error('Database query error:', err.message);
            return res.status(500).json({
                error: 'Database connection failed'
            });
        }

        res.json(results);
    });
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
    console.log(`Backend server running on port ${PORT}`);
});