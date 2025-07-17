import db from '../database';

export async function saveSubscriber(email){
    const query = 'INSERT INTO subscribers (email) VALUES ($1)';
    const values = [email];
    await db.query(query, values);
    return true;
}