export async function subscribe (req, res){
    const {email} = req.body;
    if (!email){
        return res.status(400).json({error: 'Email is required'});
    }
}

