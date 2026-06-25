import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  optimizeDeps: {
    // Exclude the large MUI icons package from pre-bundling.
    // We import icons via direct deep paths (e.g. @mui/icons-material/Apps)
    // which Vite handles efficiently without a full barrel scan.
    exclude: ['@mui/icons-material'],
  },
  build: {
    rollupOptions: {
      output: {
        // Split MUI icons into their own chunk to keep bundles manageable
        manualChunks(id) {
          if (id.includes('@mui/icons-material')) return 'mui-icons'
          if (id.includes('@mui/material'))       return 'mui-core'
          if (id.includes('react-dom'))           return 'react-dom'
        },
      },
    },
  },
  server: {
    port: 5173,
    host: true,
  },
})

