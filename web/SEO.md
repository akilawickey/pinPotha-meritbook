# SEO Implementation Guide for PinPotha

This document outlines the SEO features implemented in the PinPotha web application.

## Overview

The application includes comprehensive SEO optimization to improve visibility in Google search results and other search engines.

## Features Implemented

### 1. Meta Tags
- **Primary Meta Tags**: Title, description, keywords, author, robots
- **Open Graph Tags**: For better social media sharing (Facebook, LinkedIn)
- **Twitter Cards**: For enhanced Twitter sharing
- **Dynamic Meta Tags**: Updated per route for better relevance

### 2. Structured Data (JSON-LD)
- **WebApplication Schema**: Main application information
- **Article Schema**: For individual posts (when viewing post details)
- **BreadcrumbList Schema**: For navigation (can be added per route)

### 3. Technical SEO
- **robots.txt**: Controls search engine crawling
- **sitemap.xml**: Helps search engines discover pages
- **Canonical URLs**: Prevents duplicate content issues
- **Site Manifest**: PWA support and mobile optimization

### 4. Performance Optimization
- **Preconnect**: For faster resource loading (fonts, Firebase)
- **Optimized Build**: Code splitting and minification
- **Mobile-First**: Responsive design for all devices

## Files Structure

```
web/
├── public/
│   ├── robots.txt          # Search engine crawling rules
│   ├── sitemap.xml         # Sitemap for search engines
│   └── site.webmanifest    # PWA manifest
├── src/
│   ├── utils/
│   │   └── seo.js          # SEO utility functions
│   ├── composables/
│   │   └── useSEO.js       # Vue composable for SEO
│   └── router/
│       └── index.js        # Route-based SEO configuration
└── index.html              # Base HTML with meta tags
```

## Usage

### Automatic SEO (Router-based)
SEO is automatically set per route via the router configuration:

```javascript
{
  path: '/dashboard',
  meta: {
    seo: {
      title: 'Dashboard - PinPotha',
      description: 'View your good thoughts',
      keywords: 'pinpotha dashboard'
    }
  }
}
```

### Manual SEO in Components
Use the `useSEO` composable in Vue components:

```vue
<script setup>
import { useSEO } from '@/composables/useSEO'

useSEO({
  title: 'Custom Page Title',
  description: 'Custom description',
  structuredData: {
    '@type': 'WebPage',
    // ... structured data
  }
})
</script>
```

### Dynamic SEO for Posts
PostDetails component automatically updates SEO when a post is loaded, including:
- Dynamic title based on post content
- Article structured data
- Open Graph image from post photo

## Configuration

### Update Base URL
Update the base URL in these files:
- `web/index.html` - Canonical URLs and Open Graph URLs
- `web/src/router/index.js` - Base URL in `router.afterEach`
- `web/src/utils/seo.js` - Default SEO URL

### Update Domain
Replace `https://pinpotha.lk` with your actual domain in:
- `web/index.html`
- `web/public/robots.txt`
- `web/public/sitemap.xml`
- `web/src/utils/seo.js`

## Google Search Console Setup

1. **Verify Ownership**: Add your domain to Google Search Console
2. **Submit Sitemap**: Submit `https://yourdomain.com/sitemap.xml`
3. **Monitor**: Check indexing status and search performance

## Testing SEO

### Tools to Use
- **Google Rich Results Test**: https://search.google.com/test/rich-results
- **Google PageSpeed Insights**: https://pagespeed.web.dev/
- **Schema Markup Validator**: https://validator.schema.org/
- **Facebook Sharing Debugger**: https://developers.facebook.com/tools/debug/
- **Twitter Card Validator**: https://cards-dev.twitter.com/validator

### Checklist
- [ ] Meta tags present and correct
- [ ] Structured data valid
- [ ] robots.txt accessible
- [ ] sitemap.xml accessible
- [ ] Canonical URLs correct
- [ ] Mobile-friendly (responsive)
- [ ] Fast page load times
- [ ] Open Graph images work
- [ ] Twitter Cards work

## Important Notes

1. **Private Routes**: Dashboard, Add, and Post pages are behind authentication and should NOT be indexed. The robots.txt disallows these paths.

2. **Dynamic Content**: Post details pages are private and won't be indexed. Only the public landing page should be indexed.

3. **Images**: Ensure you have:
   - `/favicon.png` (192x192 or larger)
   - `/apple-touch-icon.png` (180x180)
   - `/og-image.png` (1200x630 for social sharing)
   - `/favicon-32x32.png` (32x32)
   - `/favicon-16x16.png` (16x16)

4. **Sitemap Updates**: Currently static. For dynamic content, consider generating sitemap programmatically.

## Future Enhancements

- [ ] Dynamic sitemap generation
- [ ] RSS feed for posts (if made public)
- [ ] Blog section for SEO content
- [ ] Multi-language support (Sinhala/English)
- [ ] AMP pages (if needed)
- [ ] Server-side rendering (SSR) for better SEO

## Resources

- [Google SEO Starter Guide](https://developers.google.com/search/docs/beginner/seo-starter-guide)
- [Schema.org Documentation](https://schema.org/)
- [Open Graph Protocol](https://ogp.me/)
- [Twitter Cards](https://developer.twitter.com/en/docs/twitter-for-websites/cards/overview/abouts-cards)

