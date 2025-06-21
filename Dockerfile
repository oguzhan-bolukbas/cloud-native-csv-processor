# Use official Node.js LTS image with multi-platform support
FROM --platform=$BUILDPLATFORM node:18-alpine AS build-stage

# Set working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies (including dev dependencies for build)
RUN npm ci --only=production && npm cache clean --force

# Multi-stage build - Final stage
FROM node:18-alpine AS production-stage

# Set working directory
WORKDIR /usr/src/app

# Copy package files
COPY package*.json ./

# Copy node_modules from build stage
COPY --from=build-stage /usr/src/app/node_modules ./node_modules

# Copy the rest of the application code
COPY . .

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Change ownership of the app directory
RUN chown -R nodejs:nodejs /usr/src/app

# Switch to non-root user
USER nodejs

# Expose the port the app runs on
EXPOSE 3000

# Set environment variables (override in production as needed)
ENV NODE_ENV=production

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/ || exit 1

# Start the app
CMD ["node", "src/app.js"]
