import React from 'react';
import { Grid, Box } from '@mui/material';
import benduthuyenview2 from "../assets/Ben du thuyen view 2.png"
import marinabeach from "../assets/Marina Beach.png"
import benduthuyenview1 from "../assets/Ben du thuyen view 1.png"

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
        <>
            <Grid container spacing={4} sx={{px:4, pb:6}}>
                <Grid item sx={12} md={12}>
                    <Card>
                        <img
                           src={benduthuyenview1}
                           alt=""
                           style={{ width: '100%', display: 'block'}}
                        />
                    </Card>
                </Grid>
            </Grid>        

            <Grid container spacing={4} sx={{px:4, pb:6}}>
                <Grid item sx={12} md={6}>
                    <Card>
                        <img
                           src={benduthuyenview2}
                           alt=""
                           style={{ width: '100%', display: 'block'}}
                        />
                    </Card>
                </Grid>
                <Grid item sx={12} md={6}>
                    <Card>
                        <a
                           href="https://www.youtube.com/watch?v=Q1b0d2k3g6E"
                           target="_blank"
                           rel="noopener noreferrer"
                        >
                            <img
                               src={marinabeach}
                               alt=""
                               style={{ width: '100%', display: 'block'}}
                            />
                        </a>
                        {/* <video
                            controls
                            style={{width: '100%', display: 'block'}}
                        >
                            <source src={alienvid} type="video/mp4" />
                        </video> */}
                    </Card>
                </Grid>
            </Grid>
        </>
    );
}