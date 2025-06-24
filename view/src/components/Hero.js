import React from 'react';
import { Box, Typography, Grid } from '@mui/material';

export default function Hero({
    title='Support My Family & I',
    description='As a close collaborator, I\'d like to share some AMAZING products below. Please keep these WONDERFUL places in mind when you have the change to visit them.',
    titleSx={},
    descriptionSx={},
    reverse=false,
}){
    const defaultTitleSx = {
        fontSize: {xs: '3rem', md: '5rem'},
        fontWeight: 300,
        lineHeight: 1.1,
    }
    const defaultDescriptionSx = {
        fontSize: '1rem',
        lineHeight: 1.6,
    }
    return(
        <Box sx={{ px:4, py:6}}>
            <Grid container spacing={4}>
                {reverse ? (
                    <>  
                    <Grid item xs={12} md={6}>
                        <Typography
                            sx={{
                                ...defaultTitleSx,
                                ...titleSx,
                            }}
                        >
                            {title}
                        </Typography>
                    </Grid>

                    <Grid item xs={12} md={6}>
                        <Typography
                            sx={{
                                ...defaultDescriptionSx,
                                ...descriptionSx,
                            }}
                        >
                            {description}
                        </Typography>
                    </Grid>
                    </>
            ) : (
                <>
                    <Grid item xs={12} md={6}>
                        <Typography
                            sx={{
                                ...defaultDescriptionSx,
                                ...descriptionSx,
                            }}
                        >
                            {description}
                        </Typography>
                    </Grid>

                    <Grid item xs={12} md={6}>
                        <Typography
                            sx={{
                                ...defaultTitleSx,
                                ...titleSx,
                            }}
                        >
                            {title}
                        </Typography>
                    </Grid>   
                </>
                )} 
            </Grid>
        </Box> 
    )
}