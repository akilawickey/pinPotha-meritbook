# Logo Image

## 📋 Instructions

1. **Place your logo image file in this directory** (`web/src/assets/images/`)

2. **Name it exactly**: `logo.png` (or change the import in `Logo.vue` to match your file format)

3. **Supported formats**: `.png`, `.svg`, `.jpg`, `.jpeg`, `.webp`

## 📝 Current Setup

The `Logo.vue` component is currently configured to import:
```javascript
import logoImage from '../assets/images/logo.png'
```

**If your logo is in a different format**, update the import in `web/src/components/Logo.vue`:
- For SVG: `import logoImage from '../assets/images/logo.svg'`
- For JPG: `import logoImage from '../assets/images/logo.jpg'`
- For WebP: `import logoImage from '../assets/images/logo.webp'`

## 🎨 Recommended Specifications

- **Format**: PNG (with transparency) or SVG (for scalability)
- **Dimensions**: At least 200x200px (will be automatically scaled)
- **Aspect Ratio**: Maintain original aspect ratio
- **Background**: Transparent (PNG) or white background
- **File Size**: Optimize for web (under 100KB recommended)

## 📍 Usage

The logo is automatically loaded by the `Logo.vue` component and displayed in:
- ✅ Sign-in page
- ✅ Dashboard header
- ✅ Other navigation areas throughout the app

## ⚠️ Note

If the logo file is missing, the build will fail with an import error. Make sure to add your logo file before building the application.

