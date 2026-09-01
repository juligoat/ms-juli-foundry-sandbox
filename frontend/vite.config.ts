import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import path from "path";

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
  server: {
    proxy: {
      "/ws": {
        target: "http://localhost:8000",
        ws: true,
      },
      "/health": "http://localhost:8000",
      "/config": "http://localhost:8000",
      "/languages": "http://localhost:8000",
    },
  },
  build: {
    outDir: "dist",
  },
});
