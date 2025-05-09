# Use the official Node.js image as the base image
FROM node:20-alpine3.20@sha256:abc123def456ghi789jkl012mno345pqrs678tuv901wxyz234abcd567efgh890

# Set environment variable
ENV NODE_ENV=production

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy the rest of the application code
COPY . .

# Expose the port the app runs on
EXPOSE 3000

# Define the command to run the app
CMD ["npm", "start"]

