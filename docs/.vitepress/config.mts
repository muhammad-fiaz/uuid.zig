import { defineConfig } from "vitepress";
import llmstxt from "vitepress-plugin-llms";

export const SITE_URL = "https://muhammad-fiaz.github.io/uuid.zig";
export const SITE_NAME = "uuid.zig";
export const SITE_DESCRIPTION = "A production-ready, high-performance UUID library for Zig with v1-v8 support, strict parsing, multiple formats, and zero-allocation core operations.";

export const GA_ID = "G-6BVYCRK57P";
export const GTM_ID = "GTM-P4M9T8ZR";
export const ADSENSE_CLIENT_ID = "ca-pub-2040560600290490";

export const KEYWORDS = "zig, uuid, guid, v4, v7, parsing, formatting, deterministic, namespace, production, performance, zero-allocation, cryptographic";

export default defineConfig({
  lang: "en-US",
  title: SITE_NAME,
  description: SITE_DESCRIPTION,
  base: "/uuid.zig/",
  lastUpdated: true,
  cleanUrls: false,

  sitemap: {
    hostname: SITE_URL,
  },

  vite: {
    plugins: [llmstxt()],
  },

  head: [
    ["meta", { name: "title", content: SITE_NAME }],
    ["meta", { name: "description", content: SITE_DESCRIPTION }],
    ["meta", { name: "keywords", content: KEYWORDS }],
    ["meta", { name: "author", content: "Muhammad Fiaz" }],
    ["meta", { name: "robots", content: "index, follow" }],
    ["meta", { name: "language", content: "English" }],
    ["meta", { name: "revisit-after", content: "7 days" }],
    ["meta", { name: "generator", content: "VitePress" }],

    ["meta", { property: "og:type", content: "website" }],
    ["meta", { property: "og:url", content: SITE_URL }],
    ["meta", { property: "og:title", content: SITE_NAME }],
    ["meta", { property: "og:description", content: SITE_DESCRIPTION }],
    ["meta", { property: "og:image", content: `${SITE_URL}/cover.png` }],
    ["meta", { property: "og:image:width", content: "1200" }],
    ["meta", { property: "og:image:height", content: "630" }],
    ["meta", { property: "og:image:alt", content: "uuid.zig - High Performance Zig UUID Library" }],
    ["meta", { property: "og:image:secure_url", content: `${SITE_URL}/cover.png` }],
    ["meta", { property: "og:site_name", content: SITE_NAME }],
    ["meta", { property: "og:locale", content: "en_US" }],

    ["meta", { name: "twitter:card", content: "summary_large_image" }],
    ["meta", { name: "twitter:url", content: SITE_URL }],
    ["meta", { name: "twitter:title", content: SITE_NAME }],
    ["meta", { name: "twitter:description", content: SITE_DESCRIPTION }],
    ["meta", { name: "twitter:image", content: `${SITE_URL}/cover.png` }],
    ["meta", { name: "twitter:image:alt", content: "uuid.zig - High Performance Zig UUID Library" }],
    ["meta", { name: "twitter:site", content: "@muhammadfiaz_" }],
    ["meta", { name: "twitter:creator", content: "@muhammadfiaz_" }],

    ["link", { rel: "canonical", href: SITE_URL }],

    ["link", { rel: "icon", href: "/uuid.zig/favicon.ico" }],
    ["link", { rel: "icon", type: "image/png", sizes: "16x16", href: "/uuid.zig/favicon-16x16.png" }],
    ["link", { rel: "icon", type: "image/png", sizes: "32x32", href: "/uuid.zig/favicon-32x32.png" }],
    ["link", { rel: "apple-touch-icon", sizes: "180x180", href: "/uuid.zig/apple-touch-icon.png" }],
    ["link", { rel: "icon", type: "image/png", sizes: "192x192", href: "/uuid.zig/android-chrome-192x192.png" }],
    ["link", { rel: "icon", type: "image/png", sizes: "512x512", href: "/uuid.zig/android-chrome-512x512.png" }],
    ["link", { rel: "manifest", href: "/uuid.zig/site.webmanifest" }],

    ["meta", { name: "theme-color", content: "#f7a41d" }],
    ["meta", { name: "msapplication-TileColor", content: "#f7a41d" }],

    [
      "script",
      { async: "", src: `https://www.googletagmanager.com/gtag/js?id=${GA_ID}` },
    ],
    [
      "script",
      {},
      `window.dataLayer = window.dataLayer || [];
function gtag(){dataLayer.push(arguments);}
gtag('js', new Date());
gtag('config', '${GA_ID}');`,
    ],

    ...(GTM_ID
      ? ([
          [
            "script",
            {},
            `(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start': new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0], j=d.createElement(s), dl=l!='dataLayer'?'&l='+l:''; j.async=true; j.src='https://www.googletagmanager.com/gtm.js?id='+i+dl; f.parentNode.insertBefore(j,f);})(window,document,'script','dataLayer','${GTM_ID}');`,
          ],
          [
            "noscript",
            {},
            `<iframe src="https://www.googletagmanager.com/ns.html?id=${GTM_ID}" height="0" width="0" style="display:none;visibility:hidden"></iframe>`,
          ],
        ] as [string, Record<string, string>, string][])
      : []),

    [
      "script",
      {
        async: "",
        src: `https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=${ADSENSE_CLIENT_ID}`,
        crossorigin: "anonymous",
      },
    ],
  ],

  ignoreDeadLinks: [/.*\.zig$/],

  transformPageData(pageData: any) {
    const pageTitle = pageData.title || SITE_NAME;
    const pageDescription = pageData.description || SITE_DESCRIPTION;
    const normalizedPath = pageData.relativePath
      .replace(/\.md$/, "")
      .replace(/(^|\/)index$/, "$1")
      .replace(/\/$/, "");
    const canonicalUrl = normalizedPath.length > 0 ? `${SITE_URL}/${normalizedPath}` : SITE_URL;

    pageData.frontmatter.head ??= [];
    pageData.frontmatter.head.push(
      ["link", { rel: "canonical", href: canonicalUrl }],
      ["meta", { property: "og:title", content: `${pageTitle} | ${SITE_NAME}` }],
      ["meta", { property: "og:url", content: canonicalUrl }]
    );

    if (pageData.frontmatter.description) {
      pageData.frontmatter.head.push(
        ["meta", { property: "og:description", content: pageData.frontmatter.description }],
        ["meta", { name: "description", content: pageData.frontmatter.description }]
      );
    }

    const isHome = pageData.relativePath === 'index.md';
    const lastUpdated = pageData.lastUpdated
      ? new Date(pageData.lastUpdated).toISOString()
      : new Date().toISOString();

    const graph: any[] = [];

    if (isHome) {
      graph.push({
        "@type": "WebSite",
        "name": SITE_NAME,
        "url": SITE_URL,
        "description": SITE_DESCRIPTION,
        "author": {
          "@type": "Person",
          "name": "Muhammad Fiaz",
          "url": "https://github.com/muhammad-fiaz"
        }
      });
    }

    const authorSchema = {
      "@type": "Person",
      "name": "Muhammad Fiaz",
      "url": "https://muhammadfiaz.com",
      "sameAs": [
        "https://github.com/muhammad-fiaz",
        "https://www.linkedin.com/in/muhammad-fiaz-",
        "https://x.com/muhammadfiaz_"
      ]
    };

    const primarySchema: Record<string, any> = {
      "@type": isHome ? "SoftwareApplication" : "TechArticle",
      "name": isHome ? SITE_NAME : pageTitle,
      "description": pageDescription,
      "url": canonicalUrl,
      "image": `${SITE_URL}/cover.png`,
      "author": authorSchema,
      "publisher": {
        "@type": "Organization",
        "name": "uuid.zig",
        "url": SITE_URL,
        "logo": {
          "@type": "ImageObject",
          "url": `${SITE_URL}/logo.png`
        }
      }
    };

    if (isHome) {
      Object.assign(primarySchema, {
        "applicationCategory": "DeveloperApplication",
        "operatingSystem": "Cross-platform",
        "programmingLanguage": "Zig",
        "offers": {
          "@type": "Offer",
          "price": "0",
          "priceCurrency": "USD"
        },
        "downloadUrl": "https://github.com/muhammad-fiaz/uuid.zig",
        "softwareVersion": "0.0.1",
        "license": "https://opensource.org/licenses/MIT"
      });
    } else {
      const pathParts = pageData.relativePath.split('/');
      const section = pathParts.length > 1
        ? pathParts[0].charAt(0).toUpperCase() + pathParts[0].slice(1)
        : 'Documentation';

      Object.assign(primarySchema, {
        "headline": pageTitle,
        "articleSection": section,
        "mainEntityOfPage": {
          "@type": "WebPage",
          "@id": canonicalUrl
        },
        "datePublished": "2026-01-01T00:00:00Z",
        "dateModified": lastUpdated
      });
    }
    graph.push(primarySchema);

    const breadcrumbs: any[] = [
      {
        "@type": "ListItem",
        "position": 1,
        "name": "Home",
        "item": SITE_URL
      }
    ];

    if (!isHome) {
      const pathParts = pageData.relativePath.replace(/\.md$/, '').split('/');
      let currentPath = SITE_URL;

      pathParts.forEach((part: string, index: number) => {
        currentPath += `/${part}`;
        const name = part.split('-').map(s => s.charAt(0).toUpperCase() + s.slice(1)).join(' ');

        breadcrumbs.push({
          "@type": "ListItem",
          "position": index + 2,
          "name": name,
          "item": index === pathParts.length - 1 ? canonicalUrl : currentPath
        });
      });
    }

    graph.push({
      "@type": "BreadcrumbList",
      "itemListElement": breadcrumbs
    });

    pageData.frontmatter.head.push([
      "script",
      { type: "application/ld+json" },
      JSON.stringify({
        "@context": "https://schema.org",
        "@graph": graph
      })
    ]);
  },

  themeConfig: {
    logo: "/logo.png",
    siteTitle: "uuid.zig",

    nav: [
      { text: "Home", link: "/" },
      { text: "Guide", link: "/guide/getting-started" },
      { text: "API", link: "/api/" },
      { text: "Examples", link: "/examples/" },
      { text: "Releases", link: "https://github.com/muhammad-fiaz/uuid.zig/releases" },
      {
        text: "Support",
        items: [
          { text: "Sponsor", link: "https://github.com/sponsors/muhammad-fiaz" },
          { text: "Donate", link: "https://pay.muhammadfiaz.com" },
        ],
      },
      { text: "GitHub", link: "https://github.com/muhammad-fiaz/uuid.zig" },
    ],

    sidebar: [
      {
        text: "Introduction",
        items: [
          { text: "Getting Started", link: "/guide/getting-started" },
          { text: "Installation", link: "/guide/installation" },
        ],
      },
      {
        text: "Guide",
        items: [
          { text: "API Overview", link: "/guide/api-overview" },
          { text: "UUID Versions", link: "/guide/uuid-versions" },
          { text: "Parsing & Formatting", link: "/guide/parsing-formatting" },
          { text: "Comparison & Conversion", link: "/guide/comparison-conversion" },
          { text: "Custom Generation", link: "/guide/custom-generation" },
          { text: "Allocator & Io Model", link: "/guide/allocator-io" },
          { text: "Generator", link: "/guide/generator" },
        ],
      },
      {
        text: "Examples",
        items: [
          { text: "All Examples", link: "/examples/" },
          { text: "Basic Usage", link: "/examples/basic-usage" },
          { text: "v1 Time-Based", link: "/examples/v1-time-based" },
          { text: "v3 MD5 Namespace", link: "/examples/v3-md5-namespace" },
          { text: "v4 Random", link: "/examples/v4-random" },
          { text: "v5 SHA-1 Namespace", link: "/examples/v5-sha1-namespace" },
          { text: "v6 Reordered", link: "/examples/v6-reordered" },
          { text: "v7 Time-Ordered", link: "/examples/v7-time-ordered" },
          { text: "v8 Application-Specific", link: "/examples/v8-application-specific" },
          { text: "Batch Generation", link: "/examples/batch-generation" },
          { text: "Deterministic", link: "/examples/deterministic" },
          { text: "Hash Map", link: "/examples/hash-map" },
          { text: "Namespaces", link: "/examples/namespaces" },
          { text: "Parsing & Formats", link: "/examples/parsing-formats" },
          { text: "Comparison", link: "/examples/comparison" },
          { text: "Version Detection", link: "/examples/version-detection" },
          { text: "Generator", link: "/examples/generator" },
          { text: "UUID Internals", link: "/examples/uuid-internals" },
          { text: "Sequential IDs", link: "/examples/sequential-ids" },
        ],
      },
      {
        text: "API Reference",
        items: [
          { text: "API Overview", link: "/api/" },
          { text: "Uuid", link: "/api/uuid" },
          { text: "Version", link: "/api/version" },
          { text: "Variant", link: "/api/variant" },
          { text: "Namespace", link: "/api/namespace" },
          { text: "Generator", link: "/api/generator-api" },
          { text: "Parse", link: "/api/parse" },
          { text: "Format", link: "/api/format" },
        ],
      },
    ],

    socialLinks: [
      { icon: "github", link: "https://github.com/muhammad-fiaz/uuid.zig" },
    ],

    footer: {
      message: "Released under the MIT License.",
      copyright: "Copyright 2026 Muhammad Fiaz",
    },

    search: {
      provider: "local",
    },

    editLink: {
      pattern: "https://github.com/muhammad-fiaz/uuid.zig/edit/main/docs/:path",
      text: "Edit this page on GitHub",
    },

    lastUpdated: {
      text: "Last updated",
      formatOptions: {
        dateStyle: "medium",
        timeStyle: "short",
      },
    },
  },
});
