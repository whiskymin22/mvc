import { React } from 'react';
import { Box, Container,Typography, TextField, Button } from '@mui/material';

export default function Mailing() {
    const [email, setEmail] = useState('');

    const handleSubmit = (e) => {
        e.preventDefault();
        // 
        console.log('Subcribing:', email);
        setEmail('');
    };

    return(
        
    );
}