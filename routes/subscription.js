// Import express and its router component
import express from 'express';

const router = express.Router();

// Import the middlewares and callback functions from the controller directory
import { subscribe } from '../controllers/subscription.js';

router.post('/subscribe', subscribe);

export default router;