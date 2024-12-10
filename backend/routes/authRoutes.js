const express = require('express');
const { registerUser, loginUser } = require('../controllers/authController');
const { check, validationResult } = require('express-validator');
const router = express.Router();

// User Registration Route
router.post(
    '/register',
    [
        check('name', 'Name is required').not().isEmpty(),
        check('email', 'Please include a valid email').isEmail(),
        check('password', 'Password must be at least 6 characters long').isLength({ min: 6 }),
    ],
    async (req, res) => {
        console.log(req)
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }
        registerUser(req, res);
    }
);

// User Login Route
router.post(
    '/login',
    [
        check('email', 'Please include a valid email').isEmail(),
        check('password', 'Password is required').exists(),
    ],
    async (req, res) => {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }
        loginUser(req, res);
    }
);

module.exports = router;
