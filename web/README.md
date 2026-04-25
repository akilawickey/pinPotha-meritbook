# PinPotha Web - Good Thoughts

A web application built with Vue.js to record and remember the good things you've done in your life. This is the web version of the PinPotha Android app, bringing the same functionality to the browser with a modern, mobile-friendly interface.

## Features

- 🔐 **Google Sign-In Authentication** - Secure authentication using Firebase Auth
- 📅 **Calendar View** - Visual calendar showing dates with posts
- 📝 **Add Posts** - Create posts with text notes and/or photos
- 📸 **Image Upload** - Upload photos from gallery or take photos with camera
- 🔍 **Search** - Search posts by note content
- 📱 **Mobile Responsive** - Beautiful UI/UX optimized for mobile devices
- 🗑️ **Delete Posts** - Remove posts you no longer need
- 🔗 **Share Posts** - Share your good thoughts with others

## Tech Stack

- **Vue 3** - Progressive JavaScript framework
- **Vue Router** - Official router for Vue.js
- **Pinia** - State management for Vue
- **Firebase** - Backend services:
  - Authentication (Google Sign-In)
  - Realtime Database
  - Storage (for images)
- **Tailwind CSS** - Utility-first CSS framework
- **Vite** - Next generation frontend tooling

## Project Structure

```
web/
├── src/
│   ├── components/       # Reusable Vue components
│   ├── views/            # Page components
│   │   ├── SignIn.vue    # Authentication page
│   │   ├── Dashboard.vue # Main dashboard with calendar
│   │   ├── AddPost.vue   # Add new post page
│   │   ├── PostList.vue  # Posts for a specific date
│   │   └── PostDetails.vue # Post detail view
│   ├── stores/          # Pinia stores
│   │   └── auth.js      # Authentication store
│   ├── utils/           # Utility functions
│   │   ├── dateUtils.js # Date formatting utilities
│   │   └── postUtils.js # Post CRUD operations
│   ├── firebase/        # Firebase configuration
│   │   └── config.js    # Firebase setup
│   ├── router/          # Vue Router configuration
│   │   └── index.js     # Route definitions
│   ├── App.vue          # Root component
│   ├── main.js          # Application entry point
│   └── style.css        # Global styles
├── index.html           # HTML template
├── package.json         # Dependencies
├── vite.config.js       # Vite configuration
└── tailwind.config.js   # Tailwind CSS configuration
```

## Getting Started

### Prerequisites

- Node.js (v16 or higher)
- npm or yarn

### Installation

1. Navigate to the web directory:
```bash
cd web
```

2. Install dependencies:
```bash
npm install
```

3. Start the development server:
```bash
npm run dev
```

The application will be available at `http://localhost:3000`

### Building for Production

```bash
npm run build
```

The built files will be in the `dist` directory.

### Preview Production Build

```bash
npm run preview
```

## Firebase Configuration

The app uses Firebase for backend services. The Firebase configuration is already set up in `src/firebase/config.js` using the same Firebase project as the Android app.

### Firebase Services Used

1. **Authentication** - Google Sign-In
2. **Realtime Database** - Stores posts structure:
   ```
   posts/
     {userEmail}/
       dd-MM-yyyy/
         {postId}/
           note: string
           photoUrl: string
           postId: string
           timeStamp: { server_time: number }
   ```
3. **Storage** - Stores uploaded images in `photos/` folder

## Features in Detail

### Authentication
- Google Sign-In integration
- Automatic redirect to dashboard after sign-in
- Protected routes requiring authentication
- Sign out functionality

### Dashboard
- Calendar view showing all months
- Visual indicators for dates with posts
- Grid view of all posts
- Search functionality to filter posts
- Responsive navigation menu

### Add Post
- Text note input
- Image upload from gallery
- Camera capture support (on mobile devices)
- Date selection for posts
- Image preview before posting

### Post Management
- View post details
- Delete posts with confirmation
- Share posts using Web Share API
- Navigate to posts by date

## Mobile-Friendly Design

The application is designed with mobile-first approach:
- Responsive grid layouts
- Touch-friendly buttons and interactions
- Optimized for small screens
- Smooth animations and transitions
- Native-like experience

## Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)
- Mobile browsers (iOS Safari, Chrome Mobile)

## Development

### Adding New Features

1. Create new components in `src/components/`
2. Add routes in `src/router/index.js`
3. Create views in `src/views/`
4. Add utility functions in `src/utils/`

### State Management

The app uses Pinia for state management. The auth store manages user authentication state.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available for contribution.

## Acknowledgments

- Inspired by the ancient "PIN POTHA" tradition
- Built with modern web technologies
- Designed for bringing back the good habit of recording positive thoughts

