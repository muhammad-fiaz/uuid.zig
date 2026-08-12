import Layout from "./Layout.vue";
import { defineAsyncComponent } from "vue";
import "./custom.css";

export default {
  Layout,
  enhanceApp({ app }) {
    app.component(
      "VersionBadge",
      defineAsyncComponent(() => import("../components/VersionBadge.vue"))
    );
    app.component(
      "UuidCode",
      defineAsyncComponent(() => import("../components/UuidCode.vue"))
    );
  },
};
