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

module.exports = pool