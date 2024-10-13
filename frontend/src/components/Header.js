import React from 'react';
import { Link } from 'react-router-dom';

const Header = () => (
    <nav>
        <Link to="/">Login</Link> | <Link to="/register">Register</Link> | <Link to="/dashboard">Dashboard</Link>
    </nav>
);

export default Header;
