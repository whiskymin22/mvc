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
                    <Grid item xs={12} md={4}>
                        <Typography variant="h6" gutterBottom>
                            ABOUT
                        </Typography>
                        {['Me', 'Jobs', 'Blog'].map((t) => (
                            <Link key={t} href={`#${t}`} color="inherit" underline="hover" display="block">
                                {t}
                            </Link>
                        ))}
                    </Grid>
                </Grid>
            </Container>
        </Box>



    )

};









