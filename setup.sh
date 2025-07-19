#!/bin/bash

echo "🚀 Setting up SDB Sample Application..."

# Start database
echo "📊 Starting PostgreSQL database..."
docker-compose up -d

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
sleep 5

# Setup backend
echo "🏗️  Setting up backend..."
cd backend
npm install
npx prisma generate
npx prisma db push
cd ..

# Setup frontend
echo "🎨 Setting up frontend..."
cd frontend
npm install
cd ..

echo "✅ Setup complete!"
echo ""
echo "🎯 Next steps:"
echo "1. Start backend: cd backend && npm run start:dev"
echo "2. Start frontend: cd frontend && npm run dev"
echo "3. Visit http://localhost:3000 to test the application"
echo ""
echo "📋 Available endpoints:"
echo "- Frontend: http://localhost:3000"
echo "- Backend API: http://localhost:3001"
echo "- API Documentation: http://localhost:3001/api"