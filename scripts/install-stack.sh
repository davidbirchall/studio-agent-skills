#!/bin/bash
# Install a stack of plugins from @davidbirchall/squad-skills
# Usage: ./scripts/install-stack.sh <stack-name>
# Example: ./scripts/install-stack.sh web

set -e

SKILLS_PKG="./node_modules/@davidbirchall/squad-skills"

if [ ! -d "$SKILLS_PKG" ]; then
  echo "❌ Error: @davidbirchall/squad-skills not found in node_modules"
  echo ""
  echo "Install it first:"
  echo "  npm install --save-dev @davidbirchall/squad-skills"
  exit 1
fi

stack=$1

case "$stack" in
  web)
    plugins=("shared" "frontend" "backend" "data" "platform-engineering" "agent-practices" "workflows")
    ;;
  game)
    plugins=("shared" "game-development" "creative-technology" "game" "agent-practices" "workflows")
    ;;
  ai)
    plugins=("shared" "backend" "ai-engineering" "platform-engineering" "agent-practices" "workflows")
    ;;
  process)
    plugins=("product" "game" "creative" "production" "knowledge" "business")
    ;;
  all)
    plugins=("shared" "frontend" "backend" "data" "platform-engineering" "ai-engineering" "game-development" "creative-technology" "product" "game" "creative" "production" "agent-practices" "business" "knowledge" "workflows")
    ;;
  *)
    echo "❌ Unknown stack: $stack"
    echo ""
    echo "Available stacks:"
    echo "  web      - Frontend, backend, data, platform engineering"
    echo "  game     - Game development, creative technology"
    echo "  ai       - Backend, AI engineering, platform engineering"
    echo "  process  - Product, game design, creative, production"
    echo "  all      - All plugins"
    exit 1
    ;;
esac

echo "📦 Installing '$stack' stack..."
echo ""

for plugin in "${plugins[@]}"; do
  plugin_path="$SKILLS_PKG/plugins/$plugin"
  
  if [ ! -d "$plugin_path" ]; then
    echo "⚠️  Plugin not found: $plugin"
    continue
  fi
  
  echo "  📌 Installing squad-skills-$plugin..."
  copilot plugin install "$plugin_path"
done

echo ""
echo "✅ Stack '$stack' installed!"
echo ""
echo "Verify installation:"
echo "  copilot plugin list"
echo ""
echo "See all skills:"
echo "  /skills list"
