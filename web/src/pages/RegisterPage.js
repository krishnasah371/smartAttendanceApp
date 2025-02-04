import React, { useState } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';

const RegisterPage = () => {
    const [name, setName] = useState('');
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState('');
    const navigate = useNavigate();

    const handleRegister = async () => {
        try {
            const response = await axios.post('http://localhost:5001/api/auth/register', {
                name,
                email,
                password,
            });

            // Store token and user data
            localStorage.setItem('token', response.data.token);
            localStorage.setItem('userData', JSON.stringify(response.data.user));
            
            alert('Registration successful!');
            navigate('/home'); // Navigate to home screen after registration
        } catch (error) {
            console.error('Registration error:', error.response?.data?.message || 'Registration failed');
            setError(error.response?.data?.message || 'Registration failed. Please try again.');
        }

    };

    return (
        <div>
            <h2>Register</h2>
            {error && <p style={{ color: 'red' }}>{error}</p>}
            <input
                type="text"
                placeholder="Name"
                value={name}
                onChange={(e) => setName(e.target.value)}
            />
            <input
                type="email"
                placeholder="Email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
            />
            <input
                type="password"
                placeholder="Password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
            />
            <button onClick={handleRegister}>Register</button>
        </div>
    );
};

export default RegisterPage;
