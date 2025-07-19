import pool from './database.js'

export async function saveSubscriber(email){
    const query = 'INSERT INTO subscribers (email) VALUES ($1)';
    const values = [email];
    await pool.query(query, values);
    return true;
}