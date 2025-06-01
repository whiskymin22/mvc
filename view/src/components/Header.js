import React from 'react';
import { AppBar, Toolbar, Typography, Button, Box } from '@mui/material';
import { Link as RouterLink } from 'react-router-dom';

export default function Header() {
  return (
    <AppBar
      position="static"
      elevation={0}
      sx={{
        bgcolor: 'var(--bg-color)',      // cream background
        color: 'var(--text-color)',      // dark text
        borderBottom: '1px solid var(--accent-color)',
      }}
    >
      <Toolbar sx={{ justifyContent: 'space-between' }}>
        <Typography
          variant="h6"
          component={RouterLink}
          to="/"
          sx={{
            textDecoration: 'none',
            color: 'inherit',
            fontWeight: 400,
          }}
        >
          MY PORTFOLIOOO
        </Typography>
        <Box>
          <Button
            component={RouterLink}
            to="/"
            sx={{ color: 'inherit' }}
          >
            Home
          </Button>
          <Button
            component={RouterLink}
            to="/expenses"
            sx={{ color: 'inherit', ml: 2 }}
          >
            Expense Tracker
          </Button>
        </Box>
      </Toolbar>
    </AppBar>
  );
}
