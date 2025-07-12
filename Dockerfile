# Stage 1: Build environment
FROM node:18-alpine as builder

WORKDIR /app

# Copy package files first to leverage Docker cache
COPY package*.json ./
COPY capacitor.config.json ./

# Install dependencies (including devDependencies for build)
RUN npm install

# Copy all source files
COPY . .

# Build the application
RUN npm run build

# Stage 2: Production environment
FROM node:18-alpine

WORKDIR /app

# Copy built assets from builder
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./

# Install only production dependencies
RUN npm install --only=production

# Install serve for static file serving
RUN npm install -g serve

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000 || exit 1

# Environment variables
ENV NODE_ENV=production
ENV PORT=3000
EXPOSE 3000

# Start the application
CMD ["serve", "-s", "dist", "-l", "3000"]
