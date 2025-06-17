FROM node:18-alpine

WORKDIR /app

# Copy package files first for better caching
COPY package*.json ./

# Install dependencies (use npm install instead of npm ci)
RUN npm install --omit=dev

# Copy source code
COPY server.js ./
COPY controllers/ ./controllers/
COPY routes/ ./routes/
COPY models/ ./models/
COPY utils/ ./utils/

# Expose port
EXPOSE 8080

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:8080/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

# Start the application
CMD ["node", "server.js"]