<template>
  <div class="flex items-center gap-3 sm:gap-4">
    <!-- Logo Image -->
    <div class="flex-shrink-0">
      <img
        :src="logoImage"
        alt="Digital පින් පොත Logo"
        :class="logoSizeClass"
        class="logo-animation w-auto object-contain"
      />
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

// Props
const props = defineProps({
  size: {
    type: String,
    default: 'medium', // 'small', 'medium', 'large', 'xlarge'
    validator: (value) => ['small', 'medium', 'large', 'xlarge'].includes(value)
  }
})

// Size classes mapping
const logoSizeClass = computed(() => {
  const sizeMap = {
    small: 'h-10 sm:h-12',        // 40px / 48px - for dashboard
    medium: 'h-16 sm:h-20 md:h-24', // 64px / 80px / 96px - default
    large: 'h-24 sm:h-32 md:h-40',  // 96px / 128px / 160px - for login
    xlarge: 'h-32 sm:h-40 md:h-48'  // 128px / 160px / 192px - extra large
  }
  return sizeMap[props.size] || sizeMap.medium
})

// Import your logo image
// Place your logo file in: src/assets/images/logo.{extension}
// Supported formats: .png, .svg, .jpg, .jpeg, .webp
// 
// Update the import path below to match your logo file format:
// - For PNG: import logoImage from '../assets/images/logo.png'
// - For SVG: import logoImage from '../assets/images/logo.svg'
// - For JPG: import logoImage from '../assets/images/logo.jpg'

// Default: expecting logo.png - change the extension if needed
import logoImage from '../assets/images/logo.png'
</script>

<style scoped>
.logo-animation {
  animation: float 3s ease-in-out infinite;
}

@keyframes float {
  0%, 100% {
    transform: translateY(0px);
  }
  50% {
    transform: translateY(-5px);
  }
}
</style>
