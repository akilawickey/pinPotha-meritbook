import { getFunctions, httpsCallable } from 'firebase/functions'
import app from '../firebase/config'

const functions = getFunctions(app, 'us-central1')
const sendAccountDeletionCodeCallable = httpsCallable(functions, 'sendAccountDeletionCode')
const confirmAccountDeletionCallable = httpsCallable(functions, 'confirmAccountDeletion')

export const sendAccountDeletionCode = async (email) => {
  const result = await sendAccountDeletionCodeCallable({ email })
  return result.data
}

export const confirmAccountDeletion = async (email, code) => {
  const result = await confirmAccountDeletionCallable({ email, code })
  return result.data
}
