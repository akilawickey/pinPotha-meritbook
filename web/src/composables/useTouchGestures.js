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
  let touchTarget = null

  // Check if element is interactive (button, link, input, etc.)
  const isInteractiveElement = (element) => {
    if (!element) return false
    
    // Check if it's a button, link, or input
    const tagName = element.tagName?.toLowerCase()
    if (['button', 'a', 'input', 'select', 'textarea'].includes(tagName)) {
      return true
    }
    
    // Check if it has a click handler or is inside an interactive element
    if (element.onclick || element.closest('button, a, [role="button"]')) {
      return true
    }
    
    // Check if it's inside the header/nav bar
    if (element.closest('header, nav, [role="navigation"]')) {
      return true
    }
    
    return false
  }

  const handleTouchStart = (e) => {
    touchTarget = e.target
    
    // Don't trigger if:
    // 1. Not at the top of the page
    // 2. Touch started on an interactive element
    // 3. Touch started on header/nav
    if (window.scrollY === 0 && !isInteractiveElement(touchTarget)) {
      startY = e.touches[0].clientY
      isPulling.value = true
    } else {
      isPulling.value = false
    }
  }

  const handleTouchMove = (e) => {
    if (!isPulling.value) return
    
    // Check if still touching a non-interactive element
    const currentTarget = document.elementFromPoint(
      e.touches[0].clientX,
      e.touches[0].clientY
    )
    
    if (isInteractiveElement(currentTarget) || isInteractiveElement(touchTarget)) {
      isPulling.value = false
      pullDistance.value = 0
      return
    }

    currentY = e.touches[0].clientY
    const distance = currentY - startY

    // Only allow pull down (positive distance)
    if (distance > 0 && window.scrollY === 0) {
      pullDistance.value = Math.min(distance, threshold * 2)
      e.preventDefault()
    } else {
      // Reset if scrolled or moved up
      isPulling.value = false
      pullDistance.value = 0
    }
  }

  const handleTouchEnd = () => {
    if (pullDistance.value >= threshold && onRefresh && isPulling.value) {
      onRefresh()
    }
    isPulling.value = false
    pullDistance.value = 0
    touchTarget = null
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

