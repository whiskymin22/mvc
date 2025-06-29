import React from 'react';
import Hero from '../components/Hero';
import CardGrid from '../components/CardGrid';
import Mailing from '../components/Mailing';

import { Avatar, Typography, Box, Container, Card } from '@mui/material';


import avatarImg from '../assets/20250526_Ghibli-Inspired Dinner Moment.png';
import benduthuyenview1 from '../assets/Ben du thuyen view 1.png';
import benduthuyenview2 from '../assets/Ben du thuyen view 2.png';
import marinabeach from '../assets/Marina Beach.png';
import asteria1 from '../assets/Asteria1.png';
import asteria2 from '../assets/Asteria2.png';
import selectum2 from '../assets/Selectum2.png';
import selectum3 from '../assets/Selectum3.png';



export default function Profile() {
  return (
    <>
      <Box
        component="section"
        sx={{
          backgroundColor: 'var(--bg-color)',
          py: { xs: 4, md: 8 },
        }}
      >
        <Container maxWidth="sm" sx={{ textAlign: 'center' }}>
          <Avatar
            alt="Cao Hữu Minh"
            src={avatarImg}
            sx={{ width: 120, height: 120, mx: 'auto' }}
          />

          <Typography
            component="h1"
            sx={{
              mt: 3,
              fontWeight: 300,
              lineHeight: 1.1,
              fontSize: { xs: '2.5rem', md: '4rem' },
              color: 'var(--text-color)',
            }}
          >
            Cao Hữu Minh
          </Typography>

          <Typography variant="h6" sx={{ mt: 1, color: 'text.secondary' }}>
            Age: 28
          </Typography>

          <Typography
            variant="body1"
            sx={{ mt: 2, color: 'var(--text-color)', lineHeight: 1.6 }}
          >
            I’m passionate about a future where AI and robots enrich our lives.
          </Typography>
        </Container>
      </Box>

      <Hero reverse/>
      <CardGrid 
        items={[
          {type: 'image', src: benduthuyenview1, xs:12, md:12, href:"https://www.facebook.com/AnaMarinaNhaTrang"},
          {type: 'image', src: benduthuyenview2, xs:12, md:6, href:"https://anamarina.com/"},
          {type: 'image', src: marinabeach, xs:12, md:6, href:"https://www.facebook.com/marinabeachclubnt"},
        ]}
      />

      <Hero 
        title="My Family"
        description="My family is my everything. I love them more than anything in the world. I'm so grateful to have them in my life."
      />
      <CardGrid
        items={[
          {type:'image', src: asteria1, xs:12, md:7.13, href:""},
          {type:'image', src: asteria2, xs:12, md:4.87, href:""},
        ]}
      />

      <Hero
        reverse
        title="Selectum"
        description='The greatest resort'
      />

      <CardGrid 
        items={[
          {type:Image, src: selectum3, xs:12, md:6, href:""},
          {type:Image, src:selectum2, xs:12, md:6, href:""},
        ]}
      
      />


      <Mailing />
    </>
  );
}
