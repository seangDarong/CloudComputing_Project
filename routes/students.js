// ─────────────────────────────────
// routes/students.js — All Routes
// ─────────────────────────────────
// GET  /           → show registration form
// POST /register   → save student to database
// GET  /students   → show all students
// ─────────────────────────────────

const express = require('express')
const router  = express.Router()
const db      = require('../db')
const multer  = require('multer')
const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3')
const multerS3 = require('multer-s3')
require('dotenv').config()

// ── S3 Client Setup
const s3 = new S3Client({
  region: process.env.AWS_REGION || 'ap-southeast-1'
})

// ── Multer Storage
// Locally: save to /public/uploads folder
// On EC2: switch to multerS3 to save to S3
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'public/uploads/')
  },
  filename: (req, file, cb) => {
    // Create unique filename: timestamp + original name
    const uniqueName = Date.now() + '-' + file.originalname
    cb(null, uniqueName)
  }
})

// Only allow image files
const fileFilter = (req, file, cb) => {
  if (file.mimetype.startsWith('image/')) {
    cb(null, true)  // accept file
  } else {
    cb(null, false) // reject file
  }
}

const upload = multer({
  storage   : storage,
  fileFilter: fileFilter,
  limits    : { fileSize: 5 * 1024 * 1024 } // max 5MB
})

// ─────────────────────────────────
// GET / — Show Registration Form
// ─────────────────────────────────
router.get('/', (req, res) => {
  // render() looks for views/index.ejs
  res.render('index', { success: null, error: null, old: {} })
})

// ─────────────────────────────────
// POST /register — Save Student
// ─────────────────────────────────
router.post('/register', upload.single('photo'), async (req, res) => {

  // Get form data from req.body
  const { name, email, student_id, course } = req.body

  // Validate — make sure nothing is empty
  if (!name || !email || !student_id || !course) {
    return res.render('index', {
      error  : 'Please fill in all fields.',
      success: null,
      old    : req.body // send back old values so form stays filled
    })
  }

  // Get photo path if uploaded
  // Locally: save path to public/uploads
  // On EC2 with S3: this will be the S3 URL
  const photo_url = req.file ? '/uploads/' + req.file.filename : ''

  try {
    // Save to database
    await db.query(
      `INSERT INTO students (name, email, student_id, course, photo_url, registered_at)
       VALUES (?, ?, ?, ?, ?, NOW())`,
      [name, email, student_id, course, photo_url]
    )

    res.render('index', {
      success: `Student "${name}" registered successfully!`,
      error  : null,
      old    : {}
    })

  } catch (err) {
    // Error code ER_DUP_ENTRY = duplicate email or student_id
    const error = err.code === 'ER_DUP_ENTRY'
      ? 'This Student ID or Email is already registered.'
      : 'Something went wrong: ' + err.message

    res.render('index', { error, success: null, old: req.body })
  }
})

// ─────────────────────────────────
// GET /students — Show All Students
// ─────────────────────────────────
router.get('/students', async (req, res) => {
  try {
    // Get all students newest first
    const [students] = await db.query(
      'SELECT * FROM students ORDER BY registered_at DESC'
    )

    res.render('students', { students })

  } catch (err) {
    res.send('Error: ' + err.message)
  }
})

module.exports = router