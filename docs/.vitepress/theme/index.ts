import DefaultTheme from "vitepress/theme";
import { defineAsyncComponent } from "vue";
import type { Theme } from "vitepress";
import "./custom.css";

export default {
  extends: DefaultTheme,
  enhanceApp({ app }) {
    app.component(
      "VersionBadge",
      defineAsyncComponent(() => import("../components/VersionBadge.vue")),
    );
    app.component(
      "UuidCode",
      defineAsyncComponent(() => import("../components/UuidCode.vue")),
    );
  },
} satisfies Theme;
