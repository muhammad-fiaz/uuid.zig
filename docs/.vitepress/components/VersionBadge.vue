<script setup lang="ts">
defineProps<{
  version: string;
}>();
</script>

<template>
  <span :class="`version-badge version-badge--${version}`">
    v{{ version }}
  </span>
</template>

<style scoped>
.version-badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 2.5rem;
  padding: 0.1rem 0.55rem;
  border-radius: 0.45rem;
  font-size: 0.75rem;
  font-weight: 700;
  line-height: 1.5;
  border: 1px solid transparent;
  vertical-align: middle;
}

.version-badge--1,
.version-badge--6 {
  color: #065f46;
  background: #d1fae5;
  border-color: #6ee7b7;
}
.version-badge--3,
.version-badge--5 {
  color: #713f12;
  background: #fef3c7;
  border-color: #fcd34d;
}
.version-badge--4,
.version-badge--7 {
  color: #1e3a8a;
  background: #dbeafe;
  border-color: #93c5fd;
}
.version-badge--8 {
  color: #4c1d95;
  background: #ede9fe;
  border-color: #c4b5fd;
}

.dark .version-badge--1,
.dark .version-badge--6 {
  color: #6ee7b7;
  background: #064e3b;
}
.dark .version-badge--3,
.dark .version-badge--5 {
  color: #fcd34d;
  background: #451a03;
}
.dark .version-badge--4,
.dark .version-badge--7 {
  color: #93c5fd;
  background: #172554;
}
.dark .version-badge--8 {
  color: #c4b5fd;
  background: #312e81;
}
</style>
