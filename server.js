import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import pool from './models/database.js';
dotenv.config();

const app = express();
const port = process.env.PORT || 8000;

// Essential middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Initialize server
const startServer = async () => {

// Health check endpoint (required for Cloud Run)
app.get('/', (req, res) => {
  res.json({ message: 'MVC Backend is running!', status: 'OK' });
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'OK', timestamp: new Date().toISOString() });
});

app.get('/test-db', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW()');
    res.json({ 
      status: 'Database connected', 
      timestamp: result.rows[0].now,
      message: 'Database connection successful'
    });
  } catch (error) {
    res.status(500).json({ 
      status: 'Database error', 
      error: error.message 
    });
  }
});

// Routes
try {
  const expenseRoutes = await import('./routes/expense.js');
  const subscriptionRoutes = await import('./routes/subscription.js');
  
  app.use('/api', expenseRoutes.default);
  app.use('/api', subscriptionRoutes.default);
} catch (error) {
  console.error('Error loading routes:', error);
}

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

// Handle 404
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

    // Listen on all interfaces (important for Cloud Run)
  app.listen(port, '0.0.0.0', () => {
    console.log(`App listening at http://0.0.0.0:${port}`);
    console.log('Environment:', process.env.NODE_ENV || 'development');
  });

  // Graceful shutdown
  process.on('SIGTERM', () => {
    console.log('SIGTERM received, shutting down gracefully');
    process.exit(0);
  });
};


// Start the server
startServer().catch(console.error);


