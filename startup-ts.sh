#!/usr/bin/env zsh

# ------------------------------------------------------
# Startup script for initializing a new TypeScript project
# Usage: ./startup-ts.sh [projectName]
# ------------------------------------------------------

# 1. Project setup
PROJECT_NAME="${1:-projectName}"   # Use given name or default to "projectName"
mkdir "$PROJECT_NAME"
cd "$PROJECT_NAME"

# 2. Initialize git repository
git init

# 3. Setup Node.js version (via nvm)
nvm install
touch .nvmrc
echo 22.15.0 > .nvmrc
nvm use

# 4. Create environment file
touch .env

# 5. Initialize npm and install dev dependencies
npm init -y
npm install -D typescript @types/node tsx

# 6. Create TypeScript config
cat > tsconfig.json << JSON
{
  "compilerOptions": {
    "baseUrl": ".",
    "target": "esnext",
    "module": "esnext",
    "rootDir": "./src",
    "outDir": "./dist",
    "strict": true,
    "moduleResolution": "Node",
    "esModuleInterop": true,
    "skipLibCheck": true
  },
  "include": ["./src/**/*.ts"],
  "exclude": ["node_modules"]
}
JSON

# 7. Overwrite package.json with project defaults
cat > package.json << JSON
{
  "name": "$PROJECT_NAME",
  "version": "1.0.0",
  "type": "module",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "start": "tsx ./src/index.ts",
    "build": "npx tsc",
    "generate": "npx drizzle-kit generate",
    "migrate" : "npx drizzle-kit migrate"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "description": "",
  "devDependencies": {
    "@types/node": "^24.3.0",
    "tsx": "^4.20.5",
    "typescript": "^5.9.2"
  }
}
JSON

# 8. Create source directory and entrypoint
mkdir src
cat > ./src/index.ts << 'TS'
function main() {
  console.log("Hello, world!");
}

main();
TS

# 9. Setup .gitignore
cat > .gitignore << 'GIT'
node_modules
dist
.DS_Store
.env
GIT

# 10. Setup database-related directories
mkdir src/db
mkdir src/migrations

# 11. Drizzle config
cat > ./drizzle.config.ts << 'TS'
import { defineConfig } from "drizzle-kit";

export default defineConfig({
  schema: "src/db/schema.ts",      // schema location
  out: "src/db/migrations",        // migrations directory
  dialect: "postgresql",
  dbCredentials: {
    url: '"postgres://username:@localhost:5432/db?sslmode=disable"', // connection string
  },
});
TS

# 12. Database index file
cat > ./src/db/index.ts << 'TS'
import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";

import * as schema from "./schema.js";
import { config } from "../config.js"; // Or wherever else the config is loaded from

const conn = postgres(config.dbURL);
export const db = drizzle(conn, { schema });
TS
