// ─────────────────────────────────
// app.js — Main Server File
// ─────────────────────────────────
// This is where everything starts.
// It sets up Express and the routes.
// ─────────────────────────────────

const express = require('express')
const path    = require('path')
require('dotenv').config()

const app = express()

// ── Tell Express to use EJS as the view engine
// This means res.render() will look for .ejs files
app.set('view engine', 'ejs')
app.set('views', path.join(__dirname, 'views'))

// ── Serve static files (style.css, images)
// Any file in /public folder is accessible directly
app.use(express.static(path.join(__dirname, 'public')))

// ── Parse form data
// Without this, req.body would be undefined
app.use(express.urlencoded({ extended: true }))
app.use(express.json())

// ── Routes
// All student routes are in routes/students.js
const studentRoutes = require('./routes/students')
app.use('/', studentRoutes)

// ── Start the server
const PORT = process.env.PORT || 3000
app.listen(PORT, () => {
  console.log(`✅ Server running at http://localhost:${PORT}`)
})