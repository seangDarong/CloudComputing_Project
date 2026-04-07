// ─────────────────────────────────
// db.js — Database Connection
// ─────────────────────────────────
// This file connects to MySQL/RDS
// Every other file imports this
// ─────────────────────────────────

const mysql = require('mysql2/promise')
require('dotenv').config()

// Create a connection pool
// Pool = multiple connections ready to use
// Better than creating a new connection every request
const pool = mysql.createPool({
  host     : process.env.DB_HOST,
  user     : process.env.DB_USER,
  password : process.env.DB_PASSWORD,
  database : process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit   : 10,
})

async function initializeSchema() {
  const dbName = process.env.DB_NAME

  if (!dbName) {
    throw new Error('DB_NAME is missing in environment variables')
  }

  if (!/^[A-Za-z0-9_]+$/.test(dbName)) {
    throw new Error('DB_NAME contains invalid characters. Use letters, numbers, and underscore only.')
  }

  const adminConnection = await mysql.createConnection({
    host     : process.env.DB_HOST,
    user     : process.env.DB_USER,
    password : process.env.DB_PASSWORD,
  })

  try {
    await adminConnection.query(`CREATE DATABASE IF NOT EXISTS \`${dbName}\``)
  } finally {
    await adminConnection.end()
  }

  await pool.query(`
    CREATE TABLE IF NOT EXISTS students (
      id INT AUTO_INCREMENT PRIMARY KEY,
      name VARCHAR(255) NOT NULL,
      email VARCHAR(255) NOT NULL UNIQUE,
      student_id VARCHAR(100) NOT NULL UNIQUE,
      course VARCHAR(255) NOT NULL,
      photo_url TEXT,
      registered_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
  `)
}

module.exports = Object.assign(pool, { initializeSchema })