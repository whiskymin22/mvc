import formidable from 'formidable';
import { endOfDay, startOfDay } from 'date-fns';
import pool from '../models/database.js';
import { fieldValidator } from '../utils/index.js';

export const create = (req, res) => {
  const form = new formidable.IncomingForm();
  form.keepExtensions = true;
  form.parse(req, async (err, fields) => {
    const { title, price, category, essential, created_at } = fields;
    // check for all fields
    if (fieldValidator(fields)) {
      return res.status(400).json(fieldValidator(fields));
    }
    try {
      const newExpense = await pool.query(
        'INSERT INTO expenses (title, price, category, essential, created_at) VALUES ($1, $2, $3, $4, $5)',
        [title, price, category, essential, created_at]
      );
      return res.status(201).send(`User added: ${newExpense.rowCount}`);
    } catch (error) {
      return res.status(400).json({
        error,
      });
    }
  });
};
export const update = (req, res) => {
  const form = new formidable.IncomingForm();
  const id = Number(req.params.id);
  form.keepExtensions = true;
  form.parse(req, async (err, fields) => {
    // check for all fields
    const { title, price, category, essential, created_at } = fields;
    if (fieldValidator(fields)) {
      return res.status(400).json(fieldValidator(fields));
    }
    try {
      await pool.query(
        'UPDATE expenses SET title = $1, price = $2, category = $3, essential = $4, created_at = $5 WHERE expense_id = $6',
        [title, price, category, essential, created_at, id]
      );

      return res.status(200).send(`User modified with ID: ${id}`);
    } catch (error) {
      return res.status(400).json({
        error,
      });
    }
  });
};

export const expenseById = async (req, res, next) => {
  const id = Number(req.params.id);
  try {
    const expense = await pool.query(
      'SELECT * FROM expenses WHERE expense_id = $1',
      [id]
    );
    req.expense = expense.rows;
    return next();
  } catch (err) {
    return res.status(400).json({
      error: err,
    });
  }
};

export const expenseByDate = async (req, res, next) => {
  const expenseDate = Number(req.params.expenseDate);
  console.log('Fetching expenses for date:', expenseDate);
  console.log('Date object:', new Date(expenseDate));
  
  try {
    const startDate = startOfDay(new Date(expenseDate)).toISOString();
    const endDate = endOfDay(new Date(expenseDate)).toISOString();
    
    console.log('Query date range:', { startDate, endDate });
    
    const expenseQuery = await pool.query(
      'SELECT * FROM expenses WHERE created_at BETWEEN $1 AND $2',
      [startDate, endDate]
    );
    
    console.log('Query result:', expenseQuery.rows);
    
    const expenseList = expenseQuery.rows;
    req.expense =
      expenseList.length > 0
        ? expenseList
        : `No expenses were found on this date.`;
    return next();
  } catch (error) {
    console.error('Database error:', error);
    return res.status(400).json({
      error: error.message,
    });
  }
};

export const read = (req, res) => res.json(req.expense);

export const remove = async (req, res) => {
  const id = Number(req.params.id);
  try {
    await pool.query('DELETE FROM expenses WHERE expense_id = $1', [id]);
    return res.status(200).send(`User deleted with ID: ${id}`);
  } catch (error) {
    return res.status(400).json({
      error,
    });
  }
};
