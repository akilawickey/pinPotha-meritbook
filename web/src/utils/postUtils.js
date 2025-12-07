import { ref as dbRef, push, set, remove, onValue } from 'firebase/database'
import { ref as storageRef, uploadBytes, getDownloadURL, deleteObject } from 'firebase/storage'
import { database, storage } from '../firebase/config'
import { formatDate } from './dateUtils'

export const getUserEmailPath = (email) => {
  return email.replace(/\./g, ',')
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

export const updatePost = async (userId, postId, date, postData, oldPhotoUrl = null) => {
  const emailPath = getUserEmailPath(userId)
  const postDate = formatDate(date, 'dd-MM-yyyy')
  
  // Construct the post reference path
  const postRef = dbRef(database, `posts/${emailPath}/${postDate}/${postId}`)
  
  console.log('Updating post at path:', `posts/${emailPath}/${postDate}/${postId}`)
  
  try {
    // Get existing post data to preserve postId and timeStamp
    const existingPost = {
      postId: postId,
      timeStamp: {
        server_time: date.getTime()
      },
      ...postData
    }
    
    // Update the post in database
    await set(postRef, existingPost)
    console.log('Post updated in database successfully')
    
    // If a new image was uploaded and there's an old image, delete the old one
    if (postData.photoUrl && oldPhotoUrl && postData.photoUrl !== oldPhotoUrl) {
      try {
        const url = new URL(oldPhotoUrl)
        const pathMatch = url.pathname.match(/\/o\/(.+)/)
        if (pathMatch) {
          const decodedPath = decodeURIComponent(pathMatch[1])
          const imageRef = storageRef(storage, decodedPath)
          await deleteObject(imageRef)
          console.log('Old image deleted from storage successfully')
        }
      } catch (error) {
        console.error('Error deleting old image from storage:', error)
        // Don't throw - old image deletion failure shouldn't prevent post update
      }
    }
    
    return existingPost
  } catch (error) {
    console.error('Error updating post in database:', error)
    throw new Error('Failed to update post: ' + error.message)
  }
}

export const deletePost = async (userId, postId, date, photoUrl = null) => {
  const emailPath = getUserEmailPath(userId)
  const postDate = formatDate(date, 'dd-MM-yyyy')
  
  // Construct the post reference path
  const postRef = dbRef(database, `posts/${emailPath}/${postDate}/${postId}`)
  
  console.log('Deleting post from path:', `posts/${emailPath}/${postDate}/${postId}`)
  
  try {
    // Delete the post from database first
    await remove(postRef)
    console.log('Post deleted from database successfully')
  } catch (error) {
    console.error('Error deleting post from database:', error)
    throw new Error('Failed to delete post from database: ' + error.message)
  }
  
  // Delete the image from storage if it exists
  if (photoUrl) {
    try {
      // Extract the path from the full URL
      // Firebase Storage URLs are like: https://firebasestorage.googleapis.com/v0/b/{bucket}/o/{path}?alt=media
      const url = new URL(photoUrl)
      const pathMatch = url.pathname.match(/\/o\/(.+)/)
      if (pathMatch) {
        const decodedPath = decodeURIComponent(pathMatch[1])
        const imageRef = storageRef(storage, decodedPath)
        await deleteObject(imageRef)
        console.log('Image deleted from storage successfully')
      } else {
        console.warn('Could not extract path from photoUrl:', photoUrl)
      }
    } catch (error) {
      console.error('Error deleting image from storage:', error)
      // Don't throw - image deletion failure shouldn't prevent post deletion
      // The post is already deleted, so we just log the error
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

