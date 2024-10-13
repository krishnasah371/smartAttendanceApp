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
            // Register the user
            await axios.post('http://localhost:5000/api/auth/register', {
                name,
                email,
                password,
            });
            
            // Automatically log in after registration
            const loginResponse = await axios.post('http://localhost:5000/api/auth/login', {
                email,
                password,
            });

            console.log('Login success after registration:', loginResponse.data);
            localStorage.setItem('token', loginResponse.data.token); // Store the JWT token
            alert('Registration and login successful!');
            navigate('/dashboard'); // Redirect to the dashboard
        } catch (error) {
            console.error('Registration or login error:', error);
            setError('Registration failed. Please try again.');
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
