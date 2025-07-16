import React, { useState } from 'react';
import { Box, Container,Typography, TextField, Button } from '@mui/material';

export default function Mailing() {
    const [email, setEmail] = useState('');

    const handleSubmit = (e) => {
        e.preventDefault();
        // ---------------------------------------------------------------------------------
        console.log('Subcribing:', email);
        setEmail('');
    };

    return(
        <Box
            component="section"
            sx={{
                backgroundColor:'var(--bg-color)',
                borderTop: '1px solid var(--accent-color)',
                borderBottom: '1px solid var(--accent-color)',
                py: { xs:4, md:6},
            }}
        >
            <Container maxWidth="md" sx={{ textAlign: 'center'}}>
                <Typography
                    variant='overline'
                    sx={{
                        fontFamily: 'var(--font-mono)',
                        letterSpacing: 2,
                        color: 'var(--text-color)',
                        mb:1,
                    }}
                >
                    JOIN OUR MAILING LIST
                </Typography>
                <Typography
                    component="h2"
                    sx={{
                        fontSize: {xs: '1.75rem', md:'2.5rem'},
                        fontWeight:300,
                        lineHeight:1.2,
                        mb:4,
                        color: 'var(--text-color)'
                    }}
                >
                    Send me your offer hihi 
                </Typography>

                <Box
                    component="form"
                    onSubmit={handleSubmit}
                    sx={{
                        display: 'flex',
                        justifyContent: 'center',
                        gap: 2,
                        flexWrap: 'wrap',
                    }}
                >
                    <TextField
                        variant="outlined"
                        placeholder='Email Address'
                        value="email"
                        onChange={(e) => setEmail(e.target.value)}
                        sx={{
                            flex: '1 1 300px',
                            maxWidth: 400,
                            '& .MuiOutlinedInput-root':{
                                borderRadius: '50px',
                            },
                        }}    
                    />
                    <Button
                        type='submit'
                        variant='contained'
                        sx={{
                            borderRadius: '50px',
                            textTransform: 'none',
                            px: 4,
                            bgcolor: 'var(--text-color)',
                            color: 'var(--cds-color-black)',
                            '&:hover': {bgcolor: 'var(--text-color)'},
                        }}
                    >
                        Submit
                    </Button>
                </Box>
            </Container>
        </Box>
        
    );
}