import pool from '../models/database.js'

export async function subscribe(req, res) {
    const { email } = req.body;
    if (!email) {
        return res.status(400).json({ error: 'Email is required' });
    }

    try {
        // Add function from model
        await pool.query('INSERT INTO subscribers (email) VAlUES ($1)', [email]);
        return res.status(201).json({ message: 'Subscription successful' });
    } catch (error) {
        return res.status(500).json({ error: 'Failed to subscribe' });
    }
}

