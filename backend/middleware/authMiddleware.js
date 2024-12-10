const jwt = require('jsonwebtoken');
const User = require('../models/User'); 

const authMiddleware = async (req, res, next) => {
    try {
        // Get token from header
        const token = req.header('Authorization')?.replace('Bearer ', '');
        
        // Check if no token
        if (!token) {
            return res.status(401).json({ message: 'Authentication failed. No token provided.' });
        }

        try {
            // Verify token
            const decoded = jwt.verify(token, process.env.JWT_SECRET);
            
            // Find user by id
            const user = await User.findById(decoded.id).select('-password');
            
            if (!user) {
                return res.status(401).json({ message: 'User not found' });
            }

            // Add user object to request
            req.user = user;
            next();
        } catch (error) {
            return res.status(401).json({ message: 'Token is invalid or expired' });
        }
    } catch (error) {
        console.error('Auth middleware error:', error);
        res.status(500).json({ message: 'Server error' });
    }
};

module.exports = authMiddleware;