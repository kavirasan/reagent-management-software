#!/usr/bin/env bash
set -euo pipefail

ISSUE_NUMBER="${1:-}"
ISSUE_TITLE="${2:-}"
ISSUE_LABELS="${3:-}"

if [[ -z "$ISSUE_NUMBER" ]]; then
  echo "Issue number is required."
  exit 1
fi

matches_project_setup=false
if [[ "$ISSUE_NUMBER" == "1" ]]; then
  matches_project_setup=true
fi
if [[ "$ISSUE_TITLE" =~ [Pp]roject[[:space:]]+[Ss]etup ]]; then
  matches_project_setup=true
fi
if [[ "$ISSUE_LABELS" == *"Package Installation"* ]]; then
  matches_project_setup=true
fi

if [[ "$matches_project_setup" != "true" ]]; then
  echo "No bootstrap template matched for issue #$ISSUE_NUMBER. Skipping scaffold changes."
  exit 0
fi

write_if_missing() {
  local target="$1"
  shift
  if [[ -f "$target" ]]; then
    return 0
  fi
  mkdir -p "$(dirname "$target")"
  cat >"$target"
}

touch_if_missing() {
  local target="$1"
  mkdir -p "$(dirname "$target")"
  if [[ ! -f "$target" ]]; then
    : >"$target"
  fi
}

mkdir -p \
  backend/app/models \
  backend/app/schemas \
  backend/app/routers \
  backend/app/services \
  backend/app/utils

touch_if_missing backend/app/__init__.py
touch_if_missing backend/app/models/__init__.py
touch_if_missing backend/app/schemas/__init__.py
touch_if_missing backend/app/routers/__init__.py
touch_if_missing backend/app/services/__init__.py
touch_if_missing backend/app/utils/__init__.py

write_if_missing backend/app/main.py <<'PYEOF'
from fastapi import FastAPI

app = FastAPI(title="Reagent Management API", version="0.1.0")


@app.get("/health", tags=["system"])
def healthcheck() -> dict[str, str]:
    return {"status": "ok"}
PYEOF

write_if_missing backend/app/config.py <<'PYEOF'
import os
from dataclasses import dataclass


@dataclass(frozen=True)
class Settings:
    app_name: str = os.getenv("APP_NAME", "Reagent Management API")
    database_url: str = os.getenv(
        "DATABASE_URL",
        "postgresql+psycopg2://postgres:postgres@localhost:5432/reagent_management_db",
    )


settings = Settings()
PYEOF

write_if_missing backend/app/database.py <<'PYEOF'
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import NullPool

from app.config import settings

engine = create_engine(settings.database_url, poolclass=NullPool, future=True)
SessionLocal = sessionmaker(bind=engine, autocommit=False, autoflush=False, future=True)
PYEOF

write_if_missing backend/requirements.txt <<'TXTEOF'
fastapi
uvicorn
sqlalchemy
psycopg2-binary
pydantic
python-dotenv
alembic
passlib[bcrypt]
python-jose
TXTEOF

mkdir -p frontend/src/components/ui frontend/src/lib

write_if_missing frontend/package.json <<'JSONEOF'
{
  "name": "frontend",
  "private": true,
  "version": "0.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "@tanstack/react-query": "^5.59.0",
    "axios": "^1.7.7",
    "class-variance-authority": "^0.7.0",
    "clsx": "^2.1.1",
    "lucide-react": "^0.460.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.27.0",
    "recharts": "^2.12.7",
    "tailwind-merge": "^2.5.4"
  },
  "devDependencies": {
    "@types/react": "^18.3.12",
    "@types/react-dom": "^18.3.1",
    "@vitejs/plugin-react": "^4.3.3",
    "autoprefixer": "^10.4.20",
    "postcss": "^8.4.49",
    "tailwindcss": "^3.4.14",
    "vite": "^5.4.10"
  }
}
JSONEOF

write_if_missing frontend/index.html <<'HTMLEOF'
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Reagent Management</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
HTMLEOF

write_if_missing frontend/vite.config.js <<'JSEOF'
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import { fileURLToPath, URL } from "node:url";

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      "@": fileURLToPath(new URL("./src", import.meta.url))
    }
  }
});
JSEOF

write_if_missing frontend/postcss.config.cjs <<'JSEOF'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {}
  }
}
JSEOF

write_if_missing frontend/tailwind.config.cjs <<'JSEOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {}
  },
  plugins: []
}
JSEOF

write_if_missing frontend/components.json <<'JSONEOF'
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "default",
  "rsc": false,
  "tsx": false,
  "tailwind": {
    "config": "tailwind.config.cjs",
    "css": "src/index.css",
    "baseColor": "zinc",
    "cssVariables": true
  },
  "aliases": {
    "components": "@/components",
    "utils": "@/lib/utils"
  }
}
JSONEOF

write_if_missing frontend/jsconfig.json <<'JSONEOF'
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    }
  }
}
JSONEOF

write_if_missing frontend/src/index.css <<'CSSEOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

body {
  margin: 0;
  font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
  background: #f8fafc;
  color: #0f172a;
}
CSSEOF

write_if_missing frontend/src/main.jsx <<'JSEOF'
import React from "react";
import ReactDOM from "react-dom/client";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter } from "react-router-dom";
import App from "./App";
import "./index.css";

const queryClient = new QueryClient();

ReactDOM.createRoot(document.getElementById("root")).render(
  <React.StrictMode>
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <App />
      </BrowserRouter>
    </QueryClientProvider>
  </React.StrictMode>
);
JSEOF

write_if_missing frontend/src/App.jsx <<'JSEOF'
function App() {
  return (
    <main style={{ minHeight: "100vh", display: "grid", placeItems: "center" }}>
      <section style={{ textAlign: "center" }}>
        <h1>Reagent Management Dashboard</h1>
        <p>Project scaffolding is ready for feature development.</p>
      </section>
    </main>
  );
}

export default App;
JSEOF

write_if_missing frontend/src/lib/utils.js <<'JSEOF'
import { clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs) {
  return twMerge(clsx(inputs));
}
JSEOF

write_if_missing frontend/src/components/ui/button.jsx <<'JSEOF'
import React from "react";
import { cva } from "class-variance-authority";
import { cn } from "@/lib/utils";

const buttonVariants = cva(
  "inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-400 disabled:pointer-events-none disabled:opacity-50 h-10 px-4 py-2",
  {
    variants: {
      variant: {
        default: "bg-slate-900 text-white hover:bg-slate-700",
        outline: "border border-slate-300 bg-white text-slate-900 hover:bg-slate-100"
      }
    },
    defaultVariants: {
      variant: "default"
    }
  }
);

const Button = React.forwardRef(({ className, variant, ...props }, ref) => {
  return <button className={cn(buttonVariants({ variant }), className)} ref={ref} {...props} />;
});

Button.displayName = "Button";

export { Button, buttonVariants };
JSEOF

echo "Bootstrap template applied for issue #$ISSUE_NUMBER."
