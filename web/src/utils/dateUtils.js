export const formatDate = (date, format = 'dd-MM-yyyy') => {
  // Handle invalid dates
  if (!date || isNaN(new Date(date).getTime())) {
    return 'Invalid date'
  }
  
  const d = new Date(date)
  
  // Double check date is valid
  if (isNaN(d.getTime())) {
    return 'Invalid date'
  }
  
  const day = String(d.getDate()).padStart(2, '0')
  const month = String(d.getMonth() + 1).padStart(2, '0')
  const year = d.getFullYear()
  const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
  
  return format
    .replace('dd', day)
    .replace('MMM', monthNames[d.getMonth()])
    .replace('MM', month)
    .replace('yyyy', year)
}

export const getDateFromMillis = (millis) => {
  return new Date(parseInt(millis))
}

export const getMillisFromDate = (date) => {
  return date.getTime()
}

export const getStartOfDay = (date) => {
  const d = new Date(date)
  d.setHours(0, 0, 0, 0)
  return d
}

export const getEndOfDay = (date) => {
  const d = new Date(date)
  d.setHours(23, 59, 59, 999)
  return d
}

