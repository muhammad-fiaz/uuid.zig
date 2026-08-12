<script setup lang="ts">
const props = defineProps<{
  value: string;
  copyable?: boolean;
}>();

function copy(): void {
  if (!props.copyable && props.copyable !== undefined) return;
  void navigator.clipboard?.writeText(props.value);
}
</script>

<template>
  <code
    class="uuid-code"
    :class="{ 'uuid-code--copyable': copyable }"
    @click="copy"
    :title="copyable ? 'Click to copy' : undefined"
  >
    {{ value }}
  </code>
</template>

<style scoped>
.uuid-code {
  font-family: var(--vp-font-family-mono);
  font-size: 0.9em;
  padding: 0.15rem 0.45rem;
  border-radius: 0.35rem;
  background: var(--vp-code-bg);
  color: var(--vp-code-color);
  user-select: all;
  white-space: nowrap;
}

.uuid-code--copyable {
  cursor: pointer;
  transition: background 0.15s ease;
}

.uuid-code--copyable:hover {
  background: var(--vp-c-brand-soft, rgba(127, 127, 127, 0.12));
}
</style>
