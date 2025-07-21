// Import express and its router component
import express from 'express';

const router = express.Router();

// Import the middlewares and callback functions from the controller directory
import {
  create,
  expenseById,
  read,
  update,
  remove,
  expenseByDate,
} from '../controllers/index.js';

// Create POST route to create an expense
router.post('/expense/create', create);
// Create GET route to read an expense
router.get('/expense/:id', expenseById, read);
// Create PUT route to update an expense
router.put('/expense/:id', expenseById, update);
// Create DELETE route to remove an expense
router.delete('/expense/:id', remove);
// Create GET route to read a list of expenses
router.get('/expense/list/:expenseDate', expenseByDate, read);

export default router;
