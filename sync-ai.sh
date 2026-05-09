#!/bin/bash

# Define project structure
SUBMODULE_PATH="sepr-groupphase-template"
BACKEND_PATH="$SUBMODULE_PATH/backend"

# Map of source files to destinations
# Format: "source_file:destination_file"
FILES=(
    ".ai-configs/claude-md/root-CLAUDE.md:CLAUDE.md"
    ".ai-configs/claude-md/backend-CLAUDE.md:$BACKEND_PATH/CLAUDE.md"
    ".ai-configs/gemini-md/root-GEMINI.md:GEMINI.md"
    ".ai-configs/gemini-md/backend-GEMINI.md:$BACKEND_PATH/GEMINI.md"
    ".ai-configs/agents-md/root-AGENTS.md:AGENTS.md"
    ".ai-configs/agents-md/backend-AGENTS.md:$BACKEND_PATH/AGENTS.md"
)

echo "🔄 Synchronizing AI configuration files..."

# 1. Sync files
for entry in "${FILES[@]}"; do
    SRC="${entry%%:*}"
    DEST="${entry#*:}"
    
    if [ -f "$SRC" ]; then
        # Create directory if it doesn't exist (e.g. backend path)
        mkdir -p "$(dirname "$DEST")"
        cp "$SRC" "$DEST"
        echo "✅ Synchronized: $SRC -> $DEST"
    else
        echo "⚠️ Warning: Source file $SRC not found. Skipping."
    fi
done

# 2. Update local ignore rules in submodule
if [ -d "$SUBMODULE_PATH/.git" ] || [ -f "$SUBMODULE_PATH/.git" ]; then
    EXCLUDE_FILE=$(git -C "$SUBMODULE_PATH" rev-parse --git-path info/exclude 2>/dev/null)
    
    if [ -n "$EXCLUDE_FILE" ]; then
        # Rules to add to submodule's local exclude file
        RULES=("backend/CLAUDE.md" "backend/GEMINI.md" "backend/AGENTS.md")
        
        for rule in "${RULES[@]}"; do
            grep -q "^$rule$" "$EXCLUDE_FILE" || echo "$rule" >> "$EXCLUDE_FILE"
        done
        echo "✅ Local ignore rules updated in submodule ($EXCLUDE_FILE)."
    else
        echo "⚠️ Warning: Could not find git exclude file for submodule."
    fi
else
    echo "⚠️ Warning: $SUBMODULE_PATH/.git not found. Submodule ignore rules not updated."
fi

echo "✨ Synchronization complete."
