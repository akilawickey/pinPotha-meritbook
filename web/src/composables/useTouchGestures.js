import { ref, onMounted, onUnmounted } from 'vue'

export function useSwipe(element, options = {}) {
  const { onSwipeLeft, onSwipeRight, onSwipeUp, onSwipeDown, threshold = 50 } = options

  let touchStartX = 0
  let touchStartY = 0
  let touchEndX = 0
  let touchEndY = 0

  const handleTouchStart = (e) => {
    touchStartX = e.changedTouches[0].screenX
    touchStartY = e.changedTouches[0].screenY
  }

  const handleTouchEnd = (e) => {
    touchEndX = e.changedTouches[0].screenX
    touchEndY = e.changedTouches[0].screenY
    handleSwipe()
  }

  const handleSwipe = () => {
    const deltaX = touchEndX - touchStartX
    const deltaY = touchEndY - touchStartY

    // Check if swipe is more horizontal or vertical
    if (Math.abs(deltaX) > Math.abs(deltaY)) {
      // Horizontal swipe
      if (Math.abs(deltaX) > threshold) {
        if (deltaX > 0 && onSwipeRight) {
          onSwipeRight()
        } else if (deltaX < 0 && onSwipeLeft) {
          onSwipeLeft()
        }
      }
    } else {
      // Vertical swipe
      if (Math.abs(deltaY) > threshold) {
        if (deltaY > 0 && onSwipeDown) {
          onSwipeDown()
        } else if (deltaY < 0 && onSwipeUp) {
          onSwipeUp()
        }
      }
    }
  }

  onMounted(() => {
    if (element.value) {
      element.value.addEventListener('touchstart', handleTouchStart, { passive: true })
      element.value.addEventListener('touchend', handleTouchEnd, { passive: true })
    }
  })

  onUnmounted(() => {
    if (element.value) {
      element.value.removeEventListener('touchstart', handleTouchStart)
      element.value.removeEventListener('touchend', handleTouchEnd)
    }
  })

  return {
    touchStartX,
    touchStartY,
    touchEndX,
    touchEndY
  }
}

export function usePullToRefresh(onRefresh) {
  const isPulling = ref(false)
  const pullDistance = ref(0)
  const threshold = 80

  let startY = 0
  let currentY = 0

  const handleTouchStart = (e) => {
    if (window.scrollY === 0) {
      startY = e.touches[0].clientY
      isPulling.value = true
    }
  }

  const handleTouchMove = (e) => {
    if (!isPulling.value) return

    currentY = e.touches[0].clientY
    const distance = currentY - startY

    if (distance > 0) {
      pullDistance.value = Math.min(distance, threshold * 2)
      e.preventDefault()
    }
  }

  const handleTouchEnd = () => {
    if (pullDistance.value >= threshold && onRefresh) {
      onRefresh()
    }
    isPulling.value = false
    pullDistance.value = 0
  }

  onMounted(() => {
    window.addEventListener('touchstart', handleTouchStart, { passive: true })
    window.addEventListener('touchmove', handleTouchMove, { passive: false })
    window.addEventListener('touchend', handleTouchEnd, { passive: true })
  })

  onUnmounted(() => {
    window.removeEventListener('touchstart', handleTouchStart)
    window.removeEventListener('touchmove', handleTouchMove)
    window.removeEventListener('touchend', handleTouchEnd)
  })

  return {
    isPulling,
    pullDistance,
    threshold
  }
}

