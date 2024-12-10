import React, { useState } from 'react';
import { View, TextInput, Button, Text, StyleSheet, TouchableOpacity } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import axios from 'axios';

const LoginScreen = ({ navigation }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  const handleLogin = async () => {
    try {
      const response = await axios.post('http://192.168.1.243:5001/api/auth/login', {
        email,
        password,
      });
      
      // Store token with Bearer prefix
      await AsyncStorage.setItem('token', `Bearer ${response.data.token}`);
      
      // Store user data if needed
      if (response.data.user) {
        await AsyncStorage.setItem('userData', JSON.stringify(response.data.user));
      }

      console.log('Login successful, token stored'); // Debug log
      navigation.replace('Home');
    } catch (err) {
      console.error('Login error:', err.response?.data || err.message);
      setError(err.response?.data?.message || 'Invalid credentials. Please try again.');
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Login</Text>
      <TextInput 
        placeholder="Email" 
        value={email} 
        onChangeText={setEmail} 
        style={styles.input} 
        keyboardType="email-address" 
        autoCapitalize="none"
      />
      <TextInput 
        placeholder="Password" 
        secureTextEntry 
        value={password} 
        onChangeText={setPassword} 
        style={styles.input}
      />
      {error ? <Text style={styles.errorText}>{error}</Text> : null}
      <TouchableOpacity style={styles.button} onPress={handleLogin}>
        <Text style={styles.buttonText}>Login</Text>
      </TouchableOpacity>
      <Text style={styles.switchText}>Don't have an account?</Text>
      <TouchableOpacity onPress={() => navigation.navigate('Register')}>
        <Text style={styles.switchLink}>Register here</Text>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, justifyContent: 'center', alignItems: 'center', padding: 20, backgroundColor: '#f5f5f5' },
  title: { fontSize: 24, fontWeight: 'bold', marginBottom: 20, color: '#333' },
  input: { width: '100%', padding: 15, marginVertical: 10, borderRadius: 8, backgroundColor: '#fff', borderColor: '#ddd', borderWidth: 1 },
  button: { backgroundColor: '#1877f2', padding: 15, borderRadius: 8, alignItems: 'center', marginTop: 20, width: '100%' },
  buttonText: { color: '#fff', fontSize: 16, fontWeight: '600' },
  errorText: { color: 'red', marginBottom: 10 },
  switchText: { marginTop: 20, color: '#666' },
  switchLink: { color: '#1877f2', fontWeight: '600', marginTop: 5 },
});

export default LoginScreen;
