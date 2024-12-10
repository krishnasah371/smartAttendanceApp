import React, { useState } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';

const LoginPage = () => {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState('');
    const navigate = useNavigate();

    const handleLogin = async () => {
        try {
            const response = await axios.post('http://localhost:5001/api/auth/login', {
                email,
                password,
            });

            // Store token and user data consistently
            localStorage.setItem('token', response.data.token);
            localStorage.setItem('userData', JSON.stringify(response.data.user));
            
            alert('Login successful!');
            navigate('/home'); // Navigate to home screen after login
        } catch (error) {
            console.error('Login error:', error.response?.data?.message || 'Login failed');
            setError(error.response?.data?.message || 'Invalid email or password.');
        }
    };

    return (
        <div>
            <h2>Login</h2>
            {error && <p style={{ color: 'red' }}>{error}</p>}
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
            <button onClick={handleLogin}>Login</button>
        </div>
    );
};

export default LoginPage;
