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
# Note: better-sqlite3 ships prebuilt binaries for most platforms,
# so npm install usually succeeds without any build tools.
# If it fails (e.g. no matching prebuilt binary for this arch/OS),
# we auto-detect the distro and install build tools as a fallback.
echo ""
echo "📦 Installing dependencies..."
if npm install --production 2>&1; then
  echo "✅ Dependencies installed"
else
  echo ""
  echo "⚠️  npm install failed (likely better-sqlite3 needs to compile from source)."
  echo "   Auto-detecting system and installing build tools..."
  echo ""

  INSTALLED_BUILD_TOOLS=false

  if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
      ubuntu|debian|linuxmint|pop)
        echo "🔧 Detected Debian/Ubuntu — running: apt-get install -y build-essential python3"
        apt-get install -y build-essential python3 && INSTALLED_BUILD_TOOLS=true
        ;;
      centos|rhel|fedora|opencloudos|anolis|rocky|almalinux)
        echo "🔧 Detected RHEL/CentOS/OpenCloudOS — running: yum install -y gcc gcc-c++ make python3"
        yum install -y gcc gcc-c++ make python3 && INSTALLED_BUILD_TOOLS=true
        ;;
      alpine)
        echo "🔧 Detected Alpine — running: apk add build-base python3"
        apk add --no-cache build-base python3 && INSTALLED_BUILD_TOOLS=true
        ;;
      *)
        echo "❌ Unknown distro ($ID). Please manually install C++ build tools and Python 3,"
        echo "   then re-run this script."
        exit 1
        ;;
    esac
  else
    echo "❌ Cannot detect OS (/etc/os-release not found). Please install build tools manually."
    exit 1
  fi

  if [ "$INSTALLED_BUILD_TOOLS" = true ]; then
    echo ""
    echo "🔄 Retrying npm install --production..."
    if npm install --production 2>&1; then
      echo "✅ Dependencies installed (with compiled native modules)"
    else
      echo "❌ npm install failed even after installing build tools."
      echo "   Check the error above and ensure Node.js headers are available."
      exit 1
    fi
  fi
fi

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
