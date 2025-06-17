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
                        Support My Family & I
                    </Typography>
                </Grid>
                    
                <Grid item xs={12} md={6}>
                    <Typography sx={{ fontSize:'1rem', lineHeight:1.6}}>
                        As a close collaborator, I'd like to share some AMAZING products below. Please keep 
                        these WONDERFUL places in mind when you have the change to visit them.
                    </Typography>
                </Grid>
            </Grid>
        </Box>
    )
}