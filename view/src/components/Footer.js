import React, {useState} from "react";
import {
    Box,
    Container,
    Grid,
    Typography,
    Link,
    ToggleButton,
    ToggleButtonGroup,
} from '@mui/material';

export default function Footer(){
    const [motion, setMotion] = useState('on');
    const handleMotion = (_, newValue) => {
        if(newValue) setMotion(newValue)
    };

    return (
        <Box
            component="footer"
            sx={{
                backgroundColor: 'var(--footer-bg)',
                color: 'var(--cds-color-grey-500)',
                py: {xs: 4, md: 6},
                
            }}
        >
            <Container maxWidth="lg">
                <Grid container spacing={4}>
                    <Grid item xs={6} md={3}>
                        <Typography variant="subtitle2" gutterBottom sx={{mb: 1.5}}>
                            ABOUT
                        </Typography>
                        {['Me', 'Jobs', 'Blog'].map((t) => (
                            <Link key={t} href={`#${t}`} color="inherit" underline="hover" display="block" sx={{mb: 1}}>
                                {t}
                            </Link>
                        ))}
                    </Grid>

                    <Grid item xs={6} md={3}>
                        <Typography variant="subtitle2" gutterBottom sx={{mb: 1.5}}>
                            PROJECTS AT
                        </Typography>
                        {['THISO', 'KIS', 'FUN SIDE'].map((t) => (
                            <Link key={t} href={`#${t}`} color="inherit" underline="hover" display="block" sx={{mb: 1}}>
                                {t}
                            </Link>
                        ))}
                    </Grid>

                    <Grid item xs={6} md={3} sx={{marginLeft: 'auto'}}>
                        <Typography variant="subtitle2" gutterBottom sx={{mb: 1.5}}>
                            CONTACT
                        </Typography>
                        <ToggleButtonGroup
                            value={motion}
                            // exclusive
                            onChange={handleMotion}
                            sx={{
                                backgroundColor: 'var(--bg-color)',
                                '& .MuiToggleButton-root': {
                                    textTransform: 'none',
                                    color: 'var(--cds-color-grey-500)',
                                    px: 2,
                                    '&.Mui-selected': {
                                        backgroundColor: 'var(--text-color)',
                                    },
                                },
                            }}
                        >
                            <ToggleButton 
                                value="email" 
                                sx={{borderRadius: '50px'}} 
                                href="mailto:whiskymin22@gmail.com"
                                target="_blank"
                                rel="noopener noreferrer"
                            > 
                                Email
                            </ToggleButton>
                            <ToggleButton 
                                value="phone" 
                                sx={{borderRadius: '50px'}} 
                                href="https://zalo.me/0919221099"
                                target="_blank"
                                rel="noopener noreferrer"
                            >
                                Zalo
                            </ToggleButton>
                            <ToggleButton 
                                value="facebook" 
                                sx={{borderRadius: '50px'}} 
                                href="https://www.facebook.com/whiskymin22"
                                target="_blank"
                                rel="noopener noreferrer"
                            >
                                Facebook
                            </ToggleButton>
                        </ToggleButtonGroup>
                    </Grid>
                </Grid>

                <Box sx={{mt: 4, textAlign: 'right'}}>
                    <Typography variant="caption" color="var(--cds-color-grey-500)">
                        {new Date().getFullYear()} FROM CHM WITH ❤️
                    </Typography>
                </Box>
            </Container>
        </Box>



    )

};









