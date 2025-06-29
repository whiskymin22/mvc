import React from 'react';
import { Grid, Box } from '@mui/material';


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


export default function CardGrid({items=[], gridSx={}}){
    return(
        <Grid container spacing={4} sx={{px: 4, py: 6,...gridSx}}>
            {items.map((item, idx)=>{
                const {type, src, xs=12, md=6} = item || {};
                return(
                    <Grid item xs={xs} md={md} key={idx}>
                        <Card>
                            {type === 'video' ? (
                                <video controls style={{width: '100%', height: 'auto'}}>
                                    <source src={src} type='video/mp4' />
                                </video>
                            ) : (
                                <a href={item.href || '#'} target="_blank" rel="noopener noreferrer">
                                    <img src={src} alt="" style={{width: '100%', height: 'auto'}} />
                                </a>
                            )}
                        </Card>
                    </Grid>
                )
            }
            )}
        </Grid>
    )
}