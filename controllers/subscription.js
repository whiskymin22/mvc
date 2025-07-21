import pool from '../models/database.js'
import { saveSubscriber } from '../models/subscription.js'


export async function subscribe(req, res) {
    const { email } = req.body;
    if (!email) {
        return res.status(400).json({ error: 'Email is required' });
    }

    try {
        // Add function from model
        await saveSubscriber(email);
        return res.status(201).json({ message: 'Subscription successful' });
    } catch (error) {
        return res.status(500).json({ error: 'Failed to subscribe' });
    }
}

