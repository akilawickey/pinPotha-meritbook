import { ref as dbRef, push, set, remove, onValue } from 'firebase/database'
import { ref as storageRef, uploadBytes, getDownloadURL, deleteObject } from 'firebase/storage'
import { database, storage } from '../firebase/config'
import { formatDate } from './dateUtils'

export const getUserEmailPath = (email) => {
  return email.replace('.', ',')
}

export const createPost = async (userId, postData, date = null) => {
  const emailPath = getUserEmailPath(userId)
  const postDate = date ? formatDate(date, 'dd-MM-yyyy') : formatDate(new Date(), 'dd-MM-yyyy')
  
  const postsRef = dbRef(database, `posts/${emailPath}/${postDate}`)
  const newPostRef = push(postsRef)
  
  const post = {
    ...postData,
    postId: newPostRef.key,
    timeStamp: {
      server_time: date ? date.getTime() : Date.now()
    }
  }
  
  await set(newPostRef, post)
  return post
}

export const uploadImage = async (file) => {
  const randomId = Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15)
  const imageRef = storageRef(storage, `photos/${randomId}`)
  
  await uploadBytes(imageRef, file)
  const downloadURL = await getDownloadURL(imageRef)
  
  return downloadURL
}

export const deletePost = async (userId, postId, date, photoUrl = null) => {
  const emailPath = getUserEmailPath(userId)
  const postDate = formatDate(date, 'dd-MM-yyyy')
  
  const postRef = dbRef(database, `posts/${emailPath}/${postDate}/${postId}`)
  await remove(postRef)
  
  if (photoUrl) {
    try {
      // Extract the path from the full URL
      // Firebase Storage URLs are like: https://firebasestorage.googleapis.com/v0/b/{bucket}/o/{path}?alt=media
      const url = new URL(photoUrl)
      const pathMatch = url.pathname.match(/\/o\/(.+)\?/)
      if (pathMatch) {
        const decodedPath = decodeURIComponent(pathMatch[1])
        const imageRef = storageRef(storage, decodedPath)
        await deleteObject(imageRef)
      }
    } catch (error) {
      console.error('Error deleting image:', error)
      // Continue even if image deletion fails
    }
  }
}

export const getPostsByDate = (userId, date, callback) => {
  const emailPath = getUserEmailPath(userId)
  const postDate = formatDate(date, 'dd-MM-yyyy')
  const postsRef = dbRef(database, `posts/${emailPath}/${postDate}`)
  
  const unsubscribe = onValue(postsRef, (snapshot) => {
    const posts = []
    if (snapshot.exists()) {
      snapshot.forEach((childSnapshot) => {
        posts.push(childSnapshot.val())
      })
    }
    callback(posts)
  })
  
  return unsubscribe
}

export const getAllPosts = (userId, callback) => {
  const emailPath = getUserEmailPath(userId)
  const postsRef = dbRef(database, `posts/${emailPath}`)
  
  const unsubscribe = onValue(postsRef, (snapshot) => {
    const posts = []
    if (snapshot.exists()) {
      snapshot.forEach((dateSnapshot) => {
        dateSnapshot.forEach((postSnapshot) => {
          posts.push(postSnapshot.val())
        })
      })
    }
    callback(posts)
  })
  
  return unsubscribe
}

export const getPostDates = (userId, callback) => {
  const emailPath = getUserEmailPath(userId)
  const postsRef = dbRef(database, `posts/${emailPath}`)
  
  const unsubscribe = onValue(postsRef, (snapshot) => {
    const dates = []
    if (snapshot.exists()) {
      snapshot.forEach((dateSnapshot) => {
        dateSnapshot.forEach((postSnapshot) => {
          const post = postSnapshot.val()
          if (post.timeStamp && post.timeStamp.server_time) {
            dates.push(parseInt(post.timeStamp.server_time))
          }
        })
      })
    }
    callback(dates)
  })
  
  return unsubscribe
}

