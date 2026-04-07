// ─────────────────────────────────
// routes/students.js — All Routes
// ─────────────────────────────────
// GET  /           → show registration form
// POST /register   → save student to database
// GET  /students   → show all students
// GET  /database   → database connectivity/config status
// GET  /storage    → storage (S3/local) status
// ─────────────────────────────────

const express = require('express')
const router  = express.Router()
const db      = require('../db')
const multer  = require('multer')
const { S3Client } = require('@aws-sdk/client-s3')
const multerS3 = require('multer-s3')
require('dotenv').config()

// ── S3 Client Setup
const s3 = new S3Client({
  region: process.env.AWS_REGION || 'ap-southeast-1'
})

const useS3Storage = Boolean(process.env.S3_BUCKET)

// ── Multer Storage
// Locally: save to /public/uploads folder
// On EC2: switch to multerS3 to save to S3
const storage = useS3Storage
  ? multerS3({
      s3,
      bucket: process.env.S3_BUCKET,
      contentType: multerS3.AUTO_CONTENT_TYPE,
      key: (req, file, cb) => {
        const uniqueName = `uploads/${Date.now()}-${file.originalname}`
        cb(null, uniqueName)
      }
    })
  : multer.diskStorage({
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
  const photo_url = req.file
    ? (useS3Storage ? req.file.location : '/uploads/' + req.file.filename)
    : ''

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

// ─────────────────────────────────
// GET /database — Show DB Status
// ─────────────────────────────────
router.get('/database', async (req, res) => {
  try {
    await db.query('SELECT 1')

    res.json({
      status  : 'ok',
      engine  : 'mysql',
      host    : process.env.DB_HOST || null,
      database: process.env.DB_NAME || null,
      port    : Number(process.env.DB_PORT || 3306),
      message : 'Database connection is healthy.'
    })
  } catch (err) {
    res.status(500).json({
      status : 'error',
      engine : 'mysql',
      host   : process.env.DB_HOST || null,
      message: 'Database connection failed.',
      error  : err.message
    })
  }
})

// ─────────────────────────────────
// GET /storage — Show Storage Status
// ─────────────────────────────────
router.get('/storage', (req, res) => {
  const bucket = process.env.S3_BUCKET || null
  const region = process.env.AWS_REGION || 'ap-southeast-1'

  res.json({
    status      : 'ok',
    provider    : useS3Storage ? 's3' : 'local',
    bucket,
    region,
    uploadsPath : useS3Storage
      ? `https://${bucket}.s3.${region}.amazonaws.com/uploads/`
      : '/uploads/',
    message     : useS3Storage
      ? 'Using S3 for student photo uploads.'
      : 'Using local disk for student photo uploads.'
  })
})

module.exports = router