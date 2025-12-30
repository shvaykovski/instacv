#!/bin/bash

# --- SETUP: Ensure we are in the script's directory ---
cd "$(dirname "$0")"

CONFIG_FILE=".netlify_id"
TOKEN_FILE=".netlify_token"

# FILES TO EXCLUDE FROM UPLOAD
# We exclude the zip itself, this script, config files, and the .git folder
EXCLUSIONS=("*.git*" "*.DS_Store" "deploy.command" "deploy.sh" "$CONFIG_FILE" "$TOKEN_FILE" "netlify_deploy_temp.zip")

# --- HELPER FUNCTIONS ---
get_json_value() {
    local key=$1
    local json=$2
    echo "$json" | grep -o "\"$key\":\"[^\"]*\"" | head -n 1 | sed -E "s/\"$key\":\"([^\"]*)\"/\1/"
}

# --- STEP 0: HANDLE CLEANUP FLAG ---
if [[ "$1" == "--clean" ]]; then
    echo "Cleaning up configuration files..."
    rm -f "$CONFIG_FILE" "$TOKEN_FILE"
    echo "Configuration reset. You can now run the script again to set up a new project."
    echo "----------------------------------------"
    exit 0
fi

echo "========================================"
echo "      Netlify Smart Deployer"
echo "========================================"
echo ""

# 1. CHECK DEPENDENCIES
if ! command -v zip &> /dev/null; then
    echo "Error: 'zip' utility is missing."
    read -p "Press Enter to exit..."
    exit 1
fi
if ! command -v curl &> /dev/null; then
    echo "Error: 'curl' utility is missing."
    read -p "Press Enter to exit..."
    exit 1
fi

# 2. GET OR PROMPT FOR TOKEN
if [ -f "$TOKEN_FILE" ] && [ -z "$NETLIFY_TOKEN" ]; then
    NETLIFY_TOKEN=$(cat "$TOKEN_FILE" | tr -d '[:space:]')
    echo "Loaded Token from $TOKEN_FILE"
fi

if [ -z "$NETLIFY_TOKEN" ]; then
    echo "To authorize, we need your Netlify Personal Access Token."
    read -s -p "Paste your Token here (hidden) and press Enter: " NETLIFY_TOKEN
    echo "" 
fi

NETLIFY_TOKEN=$(echo "$NETLIFY_TOKEN" | tr -d '[:space:]')

if [ -z "$NETLIFY_TOKEN" ]; then
    echo "Error: Token cannot be empty."
    read -p "Press Enter to exit..."
    exit 1
fi

# 3. VALIDATE TOKEN
echo "Verifying Token..."
USER_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $NETLIFY_TOKEN" "https://api.netlify.com/api/v1/user")

if [ "$USER_RESPONSE" != "200" ]; then
    echo "Error: Invalid Netlify Token (HTTP $USER_RESPONSE)."
    if [ -f "$TOKEN_FILE" ]; then
        echo "The stored token seems to have expired. Please delete '$TOKEN_FILE' and try again."
    else
        echo "Please check your token."
    fi
    read -p "Press Enter to exit..."
    exit 1
else
    if [ ! -f "$TOKEN_FILE" ]; then
        echo "$NETLIFY_TOKEN" > "$TOKEN_FILE"
        echo "   > Token validated and saved to '$TOKEN_FILE'."
    fi
fi

# 4. DETERMINE PROJECT ID
PROJECT_ID=""

if [ -f "$CONFIG_FILE" ]; then
    PROJECT_ID=$(cat "$CONFIG_FILE" | tr -d '[:space:]')
    if [ -n "$PROJECT_ID" ]; then
        echo "Found existing Project ID in configuration."
    fi
fi

if [ -z "$PROJECT_ID" ]; then
    echo ""
    echo "--------------------------------------------------------"
    echo "OPTION 1: Update an existing project (Paste the Project ID)"
    echo "OPTION 2: Create a brand new project (Just press Enter)"
    echo "--------------------------------------------------------"
    read -p "Enter Project ID (or press Enter for new): " USER_INPUT_ID
    
    USER_INPUT_ID=$(echo "$USER_INPUT_ID" | tr -d '[:space:]')

    if [ -n "$USER_INPUT_ID" ]; then
        PROJECT_ID="$USER_INPUT_ID"
    fi
fi

# 5. CREATE OR VALIDATE PROJECT
if [ -z "$PROJECT_ID" ]; then
    echo "Step 1: Creating a NEW project on Netlify..."
    
    CREATE_RESPONSE=$(curl -s -X POST \
        -H "Authorization: Bearer $NETLIFY_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{}" \
        "https://api.netlify.com/api/v1/sites")
    
    PROJECT_ID=$(get_json_value "id" "$CREATE_RESPONSE")
    PROJECT_URL=$(get_json_value "ssl_url" "$CREATE_RESPONSE")
    
    if [ -z "$PROJECT_ID" ]; then
        echo "Error: Could not create project. Check permissions."
        read -p "Press Enter to exit..."
        exit 1
    fi
    
    echo "$PROJECT_ID" > "$CONFIG_FILE"
    echo "   > Project Created! ID saved to $CONFIG_FILE"

else
    echo "Step 1: Verifying access to Project ID: $PROJECT_ID..."
    PROJECT_INFO=$(curl -s -X GET \
        -H "Authorization: Bearer $NETLIFY_TOKEN" \
        "https://api.netlify.com/api/v1/sites/$PROJECT_ID")
    
    PROJECT_URL=$(get_json_value "ssl_url" "$PROJECT_INFO")
    
    if [ -z "$PROJECT_URL" ]; then
        echo "Error: The Project ID '$PROJECT_ID' seems invalid or not found."
        echo "We will NOT save this ID."
        read -p "Press Enter to exit..."
        exit 1
    else 
        if [ ! -f "$CONFIG_FILE" ]; then
             echo "$PROJECT_ID" > "$CONFIG_FILE"
             echo "   > Project ID validated and saved to '$CONFIG_FILE'."
        fi
    fi
fi

# 6. PREPARE ZIP AND UPLOAD
echo "Step 2: Compressing files..."
ZIP_FILE="netlify_deploy_temp.zip"

# Uses the exclusion list defined at the top
zip -r -q "$ZIP_FILE" . -x "${EXCLUSIONS[@]}"

if [ ! -f "$ZIP_FILE" ]; then
    echo "Error: Failed to create zip file."
    read -p "Press Enter to exit..."
    exit 1
fi

echo "Step 3: Uploading to Netlify..."
DEPLOY_RESPONSE=$(curl -s -X POST \
    -H "Authorization: Bearer $NETLIFY_TOKEN" \
    -H "Content-Type: application/zip" \
    --data-binary "@$ZIP_FILE" \
    "https://api.netlify.com/api/v1/sites/$PROJECT_ID/deploys")

# 7. CLEANUP
rm "$ZIP_FILE"

echo ""
echo "========================================"
echo "          DEPLOYMENT SUCCESS!"
echo "========================================"
echo "Live URL: $PROJECT_URL"
echo "========================================"
read -p "Press Enter to close..."
