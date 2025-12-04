import { initializeApp } from 'firebase/app'
import { getAuth, GoogleAuthProvider } from 'firebase/auth'
import { getDatabase } from 'firebase/database'
import { getStorage } from 'firebase/storage'

const firebaseConfig = {
  apiKey: "AIzaSyBbz7tp2TJV0xQkbaI1fkpGz3ixejiCkCA",
  authDomain: "pinpotha-1295.firebaseapp.com",
  databaseURL: "https://pinpotha-1295.firebaseio.com",
  projectId: "pinpotha-1295",
  storageBucket: "pinpotha-1295.appspot.com",
  messagingSenderId: "313883222202",
  appId: "1:313883222202:android:3c6058dd460aa9c4d36283"
}

// Initialize Firebase
const app = initializeApp(firebaseConfig)

// Initialize Firebase services
export const auth = getAuth(app)
export const database = getDatabase(app)
export const storage = getStorage(app)
export const googleProvider = new GoogleAuthProvider()

export default app

