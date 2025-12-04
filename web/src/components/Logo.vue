<template>
  <div class="flex items-center gap-4">
    <!-- Logo SVG -->
    <div class="flex-shrink-0">
      <svg
        width="80"
        height="80"
        viewBox="0 0 100 100"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        class="logo-animation"
      >
        <!-- Smartphone -->
        <rect
          x="15"
          y="10"
          width="35"
          height="60"
          rx="4"
          fill="#1e3a5f"
          stroke="#152d4a"
          stroke-width="2"
        />
        <!-- Phone screen -->
        <rect
          x="18"
          y="15"
          width="29"
          height="48"
          rx="2"
          fill="#ffffff"
        />
        <!-- Home button -->
        <circle
          cx="32.5"
          cy="68"
          r="2.5"
          fill="#1e3a5f"
        />
        <!-- Book emerging from phone -->
        <g transform="translate(48, 20)">
          <!-- Book pages (orange-yellow) -->
          <rect
            x="0"
            y="0"
            width="30"
            height="40"
            rx="2"
            fill="#ff8c42"
          />
          <!-- Book spine (dark blue) -->
          <rect
            x="0"
            y="0"
            width="6"
            height="40"
            rx="2"
            fill="#1e3a5f"
          />
          <!-- Book pages detail -->
          <line
            x1="8"
            y1="15"
            x2="25"
            y2="15"
            stroke="#ffb380"
            stroke-width="1"
            opacity="0.6"
          />
          <line
            x1="8"
            y1="20"
            x2="25"
            y2="20"
            stroke="#ffb380"
            stroke-width="1"
            opacity="0.6"
          />
          <line
            x1="8"
            y1="25"
            x2="25"
            y2="25"
            stroke="#ffb380"
            stroke-width="1"
            opacity="0.6"
          />
        </g>
      </svg>
    </div>
    
    <!-- Text -->
    <div class="flex flex-col">
      <span class="text-brand-accent font-bold text-2xl sm:text-3xl">Digital</span>
      <span class="text-brand-accent font-bold text-xl sm:text-2xl mt-1" style="font-family: 'Noto Sans Sinhala', sans-serif;">
        පින් පොත
      </span>
      <span class="text-brand-dark text-xs mt-1 opacity-70">powered by leafylanka</span>
    </div>
  </div>
</template>

<script setup>
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

