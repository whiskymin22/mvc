export const fieldValidator = (fields) => {
  // 1. Destructure the required fields from the input
  const { title, price, category, essential, created_at } = fields;
  
  // 2. Check if any required field is missing
  if (!title || !price || !category || !essential || !created_at) {
    
    // 3. Find which specific fields are empty
    const emptyFields = [];
    Object.keys(fields).forEach((field) => {
      if (fields[field].length <= 0) {
        emptyFields.push(field);
      }
    });
    
    // 4. Return error object with details
    return {
      error: 'All fields are required',
      emptyFields,
    };
  }
  
  // 5. Return null if validation passes
  return null;
};