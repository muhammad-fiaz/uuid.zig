<script setup lang="ts">
import DefaultTheme from "vitepress/theme";
import { computed } from "vue";
import { useData } from "vitepress";

const { page, site } = useData();

const crumbs = computed(() => {
  if (page.value.isNotFound) return [];
  const rel = page.value.relativePath.replace(/\.md$/, "");
  const isIndex = rel === "" || rel.endsWith("/index");
  if (isIndex) return [];
  const parts = rel.split("/");
  const trail: { name: string; link?: string }[] = [];
  let acc = "";
  for (let i = 0; i < parts.length; i++) {
    const raw = parts[i];
    acc += "/" + raw;
    const name = raw
      .split("-")
      .map((s) => (s ? s[0].toUpperCase() + s.slice(1) : s))
      .join(" ");
    const isLast = i === parts.length - 1;
    if (i < parts.length - 1) {
      trail.push({ name, link: acc });
    } else {
      trail.push({ name: isLast ? page.value.title || name : name });
    }
  }
  return trail;
});

const homeName = computed(() => site.value.title || "Home");
</script>

<template>
  <DefaultTheme.Layout>
    <template #doc-before>
      <nav v-if="crumbs.length > 0" class="doc-breadcrumbs" aria-label="Breadcrumb">
        <a href="/">{{ homeName }}</a>
        <span class="sep">/</span>
        <template v-for="(crumb, i) in crumbs" :key="i">
          <a v-if="crumb.link" :href="crumb.link">{{ crumb.name }}</a>
          <span v-else aria-current="page">{{ crumb.name }}</span>
          <span v-if="i < crumbs.length - 1" class="sep">/</span>
        </template>
      </nav>
    </template>
  </DefaultTheme.Layout>
</template>
