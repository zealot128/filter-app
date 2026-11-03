import { defineConfig } from 'vite';
import RubyPlugin from "vite-plugin-ruby"
import FullReload from "vite-plugin-full-reload"
import path from 'path';
import fs from 'fs'
import vue from '@vitejs/plugin-vue2'

const isProd = process.env.NODE_ENV === "production" || process.env.RAILS_ENV === "production"

console.log("WS-HOST: ", process.env.VITE_WSS_HOST)

const items = fs.readdirSync("app/javascript")
const directories = items.filter(item => fs.lstatSync(path.join("app/javascript", item)).isDirectory())

const aliasesFromJavascriptRoot = {}
directories.forEach(directory => {
  aliasesFromJavascriptRoot[directory] = path.resolve(__dirname, "app/javascript", directory)
})

// https://vitejs.dev/config/
export default defineConfig({
  server: {
    hmr: {
      host: process.env.VITE_WSS_HOST,
      clientPort: 443,
      protocol: "wss",
    },
  },
  resolve: {
    alias: {
      ...aliasesFromJavascriptRoot,
      vue: 'vue/dist/vue.esm.js'
    },
  },
  plugins: [
    RubyPlugin(),
    vue(),
    FullReload(["config/routes.rb", "app/views/**/*", "app/controllers/**/*"], {
      delay: 200,
    }),
  ],
  build: {
    emptyOutDir: !isProd,
    sourcemap: true,
    rollupOptions: {
      output: {
        globals: {
          jquery: 'window.$',
          $: 'window.$',
        }
      }
    }
  }
})
