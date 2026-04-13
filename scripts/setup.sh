#!/bin/bash
# ai-site-builder setup script
# One-command deploy: checks environment, installs deps, starts with pm2

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# If running from scripts/ dir, go up to project root
if [ -f "$PROJECT_DIR/server.js" ]; then
  cd "$PROJECT_DIR"
elif [ -f "$SCRIPT_DIR/server.js" ]; then
  cd "$SCRIPT_DIR"
else
  echo "❌ Cannot find server.js. Run this script from the project directory."
  exit 1
fi

echo "🚀 AI Site Builder - Setup"
echo "=========================="
echo ""

# 1. Check Node.js
if ! command -v node &>/dev/null; then
  echo "❌ Node.js not found. Please install Node.js >= 18."
  exit 1
fi

NODE_VERSION=$(node -v | sed 's/v//' | cut -d. -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
  echo "❌ Node.js >= 18 required (found v$(node -v))"
  exit 1
fi
echo "✅ Node.js $(node -v)"

# 2. Check npm
if ! command -v npm &>/dev/null; then
  echo "❌ npm not found."
  exit 1
fi
echo "✅ npm $(npm -v)"

# 3. Install dependencies
echo ""
echo "📦 Installing dependencies..."
npm install --production
echo "✅ Dependencies installed"

# 4. Check config.json
CONFIG_FILE="./config.json"
if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ config.json not found!"
  exit 1
fi

# Check if apiKey is configured
API_KEY=$(node -e "const c=require('./config.json'); console.log(c.ai.apiKey||'')")
if [ -z "$API_KEY" ]; then
  echo ""
  echo "⚠️  WARNING: ai.apiKey is empty in config.json"
  echo "   Chat feature will not work without an API key."
  echo "   Edit config.json to add your API key."
  echo ""
fi

# Read config values
SITE_NAME=$(node -e "const c=require('./config.json'); console.log(c.name||'AI Site')")
SITE_PORT=$(node -e "const c=require('./config.json'); console.log(c.port||8891)")
PM2_NAME=$(echo "$SITE_NAME" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')

echo "✅ Config loaded: $SITE_NAME (port $SITE_PORT)"

# 5. Check pm2
if ! command -v pm2 &>/dev/null; then
  echo ""
  echo "⚠️  pm2 not found. Installing globally..."
  npm install -g pm2
fi
echo "✅ pm2 $(pm2 -v)"

# 6. Stop existing instance if running
pm2 delete "$PM2_NAME" 2>/dev/null || true

# 7. Start with pm2
echo ""
echo "🚀 Starting $SITE_NAME..."
pm2 start server.js --name "$PM2_NAME"
pm2 save

echo ""
echo "=========================================="
echo "✅ $SITE_NAME is running!"
echo ""
echo "   🌐 Local:   http://localhost:$SITE_PORT"
echo "   📋 Manage:  pm2 logs $PM2_NAME"
echo "   🛑 Stop:    pm2 stop $PM2_NAME"
echo "   🔄 Restart: pm2 restart $PM2_NAME"
echo "=========================================="
