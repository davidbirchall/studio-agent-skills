#!/usr/bin/env bash
# Sync @davidbirchall/squad-skills across all your Squad projects
# 
# Usage:
#   ./scripts/sync-skills.sh /path/to/projects  # Sync all projects in a directory
#   ./scripts/sync-skills.sh                     # Sync current project only
#   ./scripts/sync-skills.sh --check             # Show which skills are out of sync

set -e

PROJECT_DIR="${1:-.}"
CHECK_ONLY=false

if [ "$1" = "--check" ]; then
  CHECK_ONLY=true
  PROJECT_DIR="${2:-.}"
fi

SKILLS_PKG_VERSION=$(node -p "require('./package.json').version" 2>/dev/null || echo "unknown")

echo "📦 Syncing @davidbirchall/squad-skills v${SKILLS_PKG_VERSION}"
echo

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

sync_project() {
  local project_path=$1
  local project_name=$(basename "$project_path")

  if [ ! -f "$project_path/package.json" ]; then
    echo -e "${YELLOW}⊘${NC} $project_name — not a Node project (no package.json)"
    return 0
  fi

  # Check if project has @davidbirchall/squad-skills as a dependency
  if ! grep -q "@davidbirchall/squad-skills" "$project_path/package.json" 2>/dev/null; then
    echo -e "${YELLOW}⊘${NC} $project_name — doesn't depend on @davidbirchall/squad-skills"
    return 0
  fi

  local local_version=$(grep '"@davidbirchall/squad-skills"' "$project_path/package.json" | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")

  if [ "$local_version" = "$SKILLS_PKG_VERSION" ]; then
    echo -e "${GREEN}✓${NC} $project_name — v${local_version} (up to date)"
  else
    echo -e "${YELLOW}↻${NC} $project_name — v${local_version} → v${SKILLS_PKG_VERSION}"
    
    if [ "$CHECK_ONLY" = false ]; then
      cd "$project_path"
      npm update @davidbirchall/squad-skills --save-dev
      
      # Copy skills to project
      if [ -d "node_modules/@davidbirchall/squad-skills/.github/skills" ]; then
        mkdir -p .github
        rm -rf .github/skills
        cp -r node_modules/@davidbirchall/squad-skills/.github/skills .github/
        echo -e "  ${GREEN}→ Copied .github/skills${NC}"
      fi
      cd - > /dev/null
    fi
  fi
}

if [ "$PROJECT_DIR" = "." ]; then
  # Sync current project only
  sync_project "."
else
  # Sync all projects in the directory
  if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}✗ Directory not found: $PROJECT_DIR${NC}"
    exit 1
  fi

  echo "Scanning $PROJECT_DIR for Squad projects..."
  echo

  found_any=false
  for project in "$PROJECT_DIR"/*; do
    if [ -d "$project" ] && [ -f "$project/package.json" ]; then
      sync_project "$project"
      found_any=true
    fi
  done

  if [ "$found_any" = false ]; then
    echo -e "${YELLOW}No projects found in $PROJECT_DIR${NC}"
  fi
fi

echo
if [ "$CHECK_ONLY" = true ]; then
  echo "✓ Check complete (no changes made)"
else
  echo "✓ Sync complete"
fi
