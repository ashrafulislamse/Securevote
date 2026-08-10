#!/bin/bash

# SecureVote Web Portal - Quick Deploy Script

echo "🚀 SecureVote Web Portal Deployment"
echo "===================================="
echo ""

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: package.json not found. Run this script from securevote_web_portal folder"
    exit 1
fi

# Test build first
echo "📦 Testing build..."
npm run build

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    echo "Next steps:"
    echo "1. Push to GitHub: git add . && git commit -m 'Deploy web portal' && git push"
    echo "2. Go to https://vercel.com"
    echo "3. Import your GitHub repo"
    echo "4. Deploy!"
    echo ""
    echo "Or use Vercel CLI:"
    echo "  npm install -g vercel"
    echo "  vercel --prod"
else
    echo "❌ Build failed. Fix errors before deploying."
    exit 1
fi
