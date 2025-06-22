#!/bin/bash

# Check for name argument
if [ -z "$1" ]; then
  echo "Usage: $0 <migration-name>"
  exit 1
fi

MIGRATION_NAME="$1"
TIMESTAMP=$(date -u +"%Y%m%d%H%M%S")

UP_FILE="migrations/${TIMESTAMP}_${MIGRATION_NAME}.up.sql"
DOWN_FILE="migrations/${TIMESTAMP}_${MIGRATION_NAME}.down.sql"

# Create migrations folder if not exists
mkdir -p migrations

# Create up migration
cat << EOF > "$UP_FILE"
-- ${TIMESTAMP}_${MIGRATION_NAME}.up.sql

-- Write your UP migration here
-- Example:
-- ALTER TABLE auth.users ADD COLUMN IF NOT EXISTS phone_confirmed BOOLEAN DEFAULT FALSE;
EOF

# Create down migration
cat << EOF > "$DOWN_FILE"
-- ${TIMESTAMP}_${MIGRATION_NAME}.down.sql

-- Write your DOWN migration here
-- Example:
-- ALTER TABLE auth.users DROP COLUMN IF EXISTS phone_confirmed;
EOF

echo "Created migration files:"
echo "- $UP_FILE"
echo "- $DOWN_FILE"