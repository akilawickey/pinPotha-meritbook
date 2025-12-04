/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        // Brand colors from logo
        brand: {
          // Dark blue (smartphone, book spine)
          dark: '#1e3a5f',
          'dark-hover': '#152d4a',
          // Orange-yellow (book pages, text)
          accent: '#ff8c42',
          'accent-hover': '#ff7a2e',
          'accent-light': '#ffb380',
          // White
          white: '#ffffff',
        },
        primary: {
          // Using brand colors
          50: '#fff5f0',
          100: '#ffe8dc',
          200: '#ffd1b8',
          300: '#ffb380',
          400: '#ff8c42',
          500: '#ff6b1a',
          600: '#e55a0f',
          700: '#cc4f0d',
          800: '#b3440b',
          900: '#9a3909',
        },
        secondary: {
          // Dark blue shades
          50: '#e8edf3',
          100: '#c5d4e2',
          200: '#9fb8ce',
          300: '#789cb9',
          400: '#5a87a9',
          500: '#1e3a5f',
          600: '#1a3254',
          700: '#152d4a',
          800: '#112640',
          900: '#0a1a2e',
        },
      },
    },
  },
  plugins: [],
}
