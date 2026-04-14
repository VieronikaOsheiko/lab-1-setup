import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  // Required for GitHub Pages when repository is named "lab-1-setup".
  base: '/lab-1-setup/',
  plugins: [react()],
})
