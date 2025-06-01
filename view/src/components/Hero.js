import React from 'react';
import { Box, Typography, Grid } from '@mui/material';

export default function Hero(){
    return(
        <Box sx={{ px:4, py:6}}>
            <Grid container spacing={4}>
                <Grid item xs={12} md={6}>
                    <Typography
                        component="h1"
                        sx={{
                            fontSize: {sx: '3rem', md: '5rem'},
                            fontWeight: 300,
                            lineHeight: 1.1,
                        }}
                    >
                        Company<br/>Design
                    </Typography>
                </Grid>
                    
                <Grid item xs={12} md={6}>
                    <Typography sx={{ fontSize:'1rem', lineHeight:1.6}}>
                        We’ve distilled five decades of company-building experience
                        into a discipline we call Company Design—the Sequoia way to
                        start, build and scale enduring companies.
                    </Typography>
                </Grid>
            </Grid>
        </Box>
    )
}