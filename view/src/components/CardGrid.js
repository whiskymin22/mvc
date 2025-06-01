import React from 'react';
import { Grid, Box } from '@mui/material';
import muppet from "../assets/Muppet Hip-Hop Legends.png"
import alienvid from "../assets/Alien Invasion Begins.mp4"


function Card({children}){
    return(
        <Box 
            sx={{
                background: 'var(--card-bg)',
                borderRadius: 2,
                overflow: 'hidden',
                boxShadow: '0 4px 8px rgba(0,0,0,0.05)',
                position: 'relative',
            }}
        >
            <Box
                component='span'
                sx={{
                    position:'absolute',
                    top:8, left:8,
                    color: 'var(--border-accent)',
                    fontSize: '0.75rem',
                }}                
            >
                +
            </Box>
            {children}
        </Box>
    );
}


export default function CardGrid(){
    return(
        <Grid container spacing={4} sx={{px:4, pb:6}}>
            <Grid item sx={12} md={6}>
                <Card>
                    <img
                       src={muppet}
                       alt=""
                       style={{ width: '100%', display: 'block'}}
                    />
                </Card>
            </Grid>
            <Grid item sx={12} md={6}>
                <Card>
                    <video
                        controls
                        style={{width: '100%', display: 'block'}}
                    >
                        <source src={alienvid} type="video/mp4" />
                    </video>
                </Card>
            </Grid>
        </Grid>
    );
}