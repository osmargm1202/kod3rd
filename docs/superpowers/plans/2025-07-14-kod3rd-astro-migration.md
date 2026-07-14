# Kod3rd Astro Migration — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate the Kod3rd WordPress static landing page to Astro SSG with JSON content, local assets, scroll animations, and Docker Compose serving.

**Architecture:** Astro 5.x static site generation. Content sourced from `src/data/*.json` at build time. All components render to static HTML. Nginx serves the built `dist/` folder in Docker.

**Tech Stack:** Astro 5.x, TypeScript, CSS vanilla, JSON data files, Docker + Nginx Alpine

## Global Constraints

- Same visual identity as current site (colors, fonts, layout)
- Same sections: Header, Hero, Services (6 cards), About + Values (4), CTA, Contact placeholder, Footer
- All text content in JSON files under `src/data/` — no hardcoded text in components
- Images in `public/assets/images/` — use relative paths from there
- Fonts: Poppins (body), DM Serif Display (headings), Montserrat (alternate) — loaded from Google Fonts
- Animations: CSS keyframes + IntersectionObserver vanilla (~30 lines), no animation library
- Contact section: empty placeholder div with id="CONTACTO" — Formspree added later
- Responsive: mobile-first CSS
- Docker Compose with nginx:alpine serving `dist/`
- No SSR, no runtime backend, no external API calls
- Build must pass with `npm run build` (zero errors)

---

### Task 1: Project Scaffold and Configuration

**Files:**
- Create: `package.json`
- Create: `astro.config.mjs`
- Create: `tsconfig.json`
- Create: `src/` directory structure (layouts/, components/, data/, pages/, styles/)
- Create: `public/assets/images/` directory

**Interfaces:**
- Consumes: Nothing (first task)
- Produces: Working Astro dev server at `npm run dev`

- [ ] **Step 1: Create package.json**

```json
{
  "name": "kod3rd-landing",
  "type": "module",
  "version": "1.0.0",
  "scripts": {
    "dev": "astro dev",
    "build": "astro build",
    "preview": "astro preview"
  },
  "dependencies": {
    "astro": "^5.0.0"
  }
}
```

- [ ] **Step 2: Create astro.config.mjs**

```js
import { defineConfig } from 'astro/config';

export default defineConfig({
  site: 'https://kod3rd.com',
  outDir: './dist',
  publicDir: './public',
});
```

- [ ] **Step 3: Create tsconfig.json**

```json
{
  "extends": "astro/tsconfigs/strict",
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    }
  }
}
```

- [ ] **Step 4: Create directory structure**

```bash
mkdir -p src/layouts src/components src/data src/pages src/styles public/assets/images
```

- [ ] **Step 5: Create a minimal index.astro placeholder**

```astro
---
// src/pages/index.astro
---
<html>
  <head><title>Kod3RD</title></head>
  <body><h1>Kod3RD</h1></body>
</html>
```

- [ ] **Step 6: Install dependencies and verify build**

```bash
npm install
npm run build
```

Expected: Build succeeds, `dist/` directory created with `index.html`

- [ ] **Step 7: Commit**

```bash
git add package.json astro.config.mjs tsconfig.json src/ public/ package-lock.json
git commit -m "feat: scaffold Astro project"
```

---

### Task 2: Data Layer — JSON Content Files

**Files:**
- Create: `src/data/site.json`
- Create: `src/data/hero.json`
- Create: `src/data/services.json`
- Create: `src/data/about.json`
- Create: `src/data/values.json`
- Create: `src/data/footer.json`

**Interfaces:**
- Consumes: Nothing
- Produces: JSON data structures consumed by all components in later tasks

- [ ] **Step 1: Create site.json** (global site metadata)

```json
{
  "siteName": "Kod3RD",
  "tagline": "Empresa de elaboración de sistemas",
  "email": "koderd.44@gmail.com",
  "instagram": "https://www.instagram.com/kod3rd?igsh=MnkzdWtrbGlucWxi",
  "phone": ["+1 (829) 868-2298", "+1 (809) 988-4985"]
}
```

- [ ] **Step 2: Create hero.json**

```json
{
  "heading": "Impulsa tu éxito digital",
  "subheading": "Creamos soluciones tecnológicas que potencian tu negocio hacia el futuro.",
  "paragraphs": [
    "Creamos soluciones digitales a la medida: páginas web y aplicaciones móviles innovadoras.",
    "Entregamos resultados efectivos y personalizados, cuidando cada detalle con excelencia técnica.",
    "Tecnología desarrollada por profesionales con experiencia, garantizando calidad y seguridad para tu negocio."
  ],
  "primaryCta": {
    "text": "koderd.44@gmail.com",
    "url": "mailto:koderd.44@gmail.com"
  },
  "secondaryCta": {
    "text": "Contáctanos ahora",
    "url": "https://www.instagram.com/kod3rd?igsh=MnkzdWtrbGlucWxi"
  }
}
```

- [ ] **Step 3: Create services.json**

```json
[
  {
    "id": "consultoria",
    "title": "Consultoría tecnológica",
    "description": "Te ayudamos a tomar decisiones correctas en tecnología para tu negocio.",
    "image": "/assets/images/consultoria.png"
  },
  {
    "id": "landing-page",
    "title": "Diseños de landing page",
    "description": "Hacemos páginas cómodas para mostrar y vender tus productos o servicios.",
    "image": "/assets/images/landings.webp"
  },
  {
    "id": "apps",
    "title": "Aplicaciones móviles",
    "description": "Creamos apps para que tus clientes puedan usar tu negocio desde el celular.",
    "image": "/assets/images/moviles.webp"
  },
  {
    "id": "web",
    "title": "Páginas web",
    "description": "Diseñamos tu página para que todos puedan conocer y confiar en tu negocio online.",
    "image": "/assets/images/paginas-web.webp"
  },
  {
    "id": "software",
    "title": "Software personalizado",
    "description": "Creamos sistemas a tu medida para hacer más fácil el manejo de tu negocio.",
    "image": "/assets/images/servicios-personalizado.webp"
  },
  {
    "id": "control",
    "title": "Sistemas de control",
    "description": "Te damos herramientas para llevar el control de ventas, inventario y más.",
    "image": "/assets/images/sistemas-de-control.webp"
  }
]
```

- [ ] **Step 4: Create about.json**

```json
{
  "heading": "SOBRE NOSOTROS",
  "intro": "Construimos el futuro digital, línea por línea",
  "description": "En KOD3RD, nos especializamos en soluciones tecnológicas innovadoras y efectivas adaptadas a tu negocio. Con amplia experiencia en desarrollo de software, aplicaciones móviles y páginas web, impulsamos a empresas y emprendedores hacia el éxito digital con compromiso, creatividad y calidad garantizada."
}
```

- [ ] **Step 5: Create values.json**

```json
[
  {
    "title": "Innovación",
    "description": "Tecnologías modernas aplicadas al desarrollo de soluciones digitales únicas y eficientes."
  },
  {
    "title": "Viabilidad",
    "description": "Soluciones prácticas y rentables diseñadas específicamente para potenciar tu negocio."
  },
  {
    "title": "Seguridad",
    "description": "Priorizamos la protección y confidencialidad de tu información en cada desarrollo."
  },
  {
    "title": "Calidad",
    "description": "Excelencia técnica y atención a cada detalle en todos nuestros proyectos tecnológicos."
  }
]
```

- [ ] **Step 6: Create footer.json**

```json
{
  "copyright": "© 2025 Kod3rd. All rights reserved.",
  "email": "koderd.44@gmail.com",
  "instagram": "https://www.instagram.com/kod3rd?igsh=MnkzdWtrbGlucWxi",
  "instagramHandle": "@kod3rd"
}
```

- [ ] **Step 7: Commit**

```bash
git add src/data/
git commit -m "feat: add JSON content data files"
```

---

### Task 3: Assets — Copy Images from WordPress Export

**Files:**
- Create: `public/assets/images/logo.webp`
- Create: `public/assets/images/consultoria.png`
- Create: `public/assets/images/landings.webp`
- Create: `public/assets/images/moviles.webp`
- Create: `public/assets/images/paginas-web.webp`
- Create: `public/assets/images/servicios-personalizado.webp`
- Create: `public/assets/images/sistemas-de-control.webp`

**Interfaces:**
- Consumes: Files from `wp-content/uploads/` directory
- Produces: Clean local image assets in `public/assets/images/`

- [ ] **Step 1: Copy and rename images from wp-content**

```bash
# Logo
cp wp-content/uploads/2025/05/Logo-recortado.webp public/assets/images/logo.webp

# Service images (thumbnails from elementor/thumbs)
cp "wp-content/uploads/elementor/thumbs/Consultoria-2-r57epgtcu3r1b0ddrcgrc890h8qg5qjpbbxuz9o880.png" public/assets/images/consultoria.png
cp "wp-content/uploads/elementor/thumbs/Landings-r57eie33e02bwone2scv2ij3htlz7rgg0b59xa5x28.webp" public/assets/images/landings.webp
cp "wp-content/uploads/elementor/thumbs/moviles-r57eiqazuuj23m5n3fn0gxg37txqztsydzml5vnstc.webp" public/assets/images/moviles.webp
cp "wp-content/uploads/elementor/thumbs/Paginas-web-1-r586clk6as0et4vxvzwplm00zpuu9u5ggryqq86isg.webp" public/assets/images/paginas-web.webp
cp "wp-content/uploads/elementor/thumbs/Servicios-personalizado-r57ej93rnj8sjtec1nrjuspb3jd39rvl4koarevxcw.webp" public/assets/images/servicios-personalizado.webp
cp "wp-content/uploads/elementor/thumbs/Sistemas-de-control-r57ejfomzdhst34rz8lxu91j98gnrnlphh8p4cm65c.webp" public/assets/images/sistemas-de-control.webp
```

- [ ] **Step 2: Verify all images copied**

```bash
ls -la public/assets/images/
```

Expected: 7 image files present

- [ ] **Step 3: Commit**

```bash
git add public/assets/images/
git commit -m "feat: add local image assets"
```

---

### Task 4: BaseLayout + Global CSS

**Files:**
- Create: `src/styles/global.css`
- Create: `src/layouts/BaseLayout.astro`

**Interfaces:**
- Consumes: `src/data/site.json`
- Produces: Layout wrapper with head, fonts, meta, and global styles
- Used by: `src/pages/index.astro` and all components

- [ ] **Step 1: Create global.css**

```css
/* Custom Properties */
:root {
  /* Colors from original WP site + Elementor */
  --color-black: #000000;
  --color-white: #ffffff;
  --color-dark: #1a1a2e;
  --color-primary: #32373c;
  --color-accent: #0693e3;
  --color-text: #333333;
  --color-bg-light: #f6f7f7;
  --color-bg-dark: #1a1a2e;
  
  /* Typography */
  --font-heading: 'DM Serif Display', serif;
  --font-body: 'Poppins', sans-serif;
  --font-alt: 'Montserrat', sans-serif;
  
  /* Spacing */
  --section-padding: 4rem 1rem;
  --container-max: 1200px;
  --content-max: 800px;
  
  /* Transitions */
  --transition-fast: 0.2s ease;
  --transition-normal: 0.3s ease;
}

/* Reset */
*, *::before, *::after {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

html {
  scroll-behavior: smooth;
  scroll-padding-top: 100px;
}

body {
  font-family: var(--font-body);
  color: var(--color-text);
  line-height: 1.6;
  -webkit-font-smoothing: antialiased;
}

img {
  max-width: 100%;
  height: auto;
  display: block;
}

a {
  color: inherit;
  text-decoration: none;
}

ul {
  list-style: none;
}

/* Container */
.container {
  max-width: var(--container-max);
  margin: 0 auto;
  padding: 0 1rem;
}

/* Section base */
.section {
  padding: var(--section-padding);
}

.section__title {
  font-family: var(--font-heading);
  font-size: 2.5rem;
  text-align: center;
  margin-bottom: 3rem;
  color: var(--color-dark);
}

/* Buttons */
.btn {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.5rem;
  border-radius: 999px;
  font-family: var(--font-body);
  font-weight: 500;
  font-size: 0.95rem;
  cursor: pointer;
  transition: var(--transition-normal);
  border: none;
}

.btn--primary {
  background: var(--color-primary);
  color: var(--color-white);
}

.btn--primary:hover {
  opacity: 0.9;
  transform: scale(1.02);
}

.btn--secondary {
  background: transparent;
  border: 2px solid var(--color-primary);
  color: var(--color-primary);
}

.btn--secondary:hover {
  background: var(--color-primary);
  color: var(--color-white);
}

/* Responsive */
@media (max-width: 768px) {
  :root {
    --section-padding: 2.5rem 1rem;
  }
  
  .section__title {
    font-size: 1.8rem;
  }
}

/* Animation utilities */
.animate-fade-in {
  opacity: 0;
  transition: opacity 0.8s ease;
}

.animate-fade-in.is-visible {
  opacity: 1;
}

.animate-slide-up {
  opacity: 0;
  transform: translateY(40px);
  transition: opacity 0.8s ease, transform 0.8s ease;
}

.animate-slide-up.is-visible {
  opacity: 1;
  transform: translateY(0);
}

.delay-200 { transition-delay: 0.2s; }
.delay-400 { transition-delay: 0.4s; }
.delay-600 { transition-delay: 0.6s; }
```

- [ ] **Step 2: Create BaseLayout.astro**

```astro
---
// src/layouts/BaseLayout.astro
import site from '@/data/site.json';

export interface Props {
  title?: string;
  description?: string;
}

const { title, description } = Astro.props;
const pageTitle = title ? `${title} | ${site.siteName}` : `${site.siteName} – ${site.tagline}`;
---

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover" />
  <title>{pageTitle}</title>
  <meta name="description" content={description || site.tagline} />
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link href="https://fonts.googleapis.com/css2?family=DM+Serif+Display&family=Montserrat:wght@400;500;600&family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
  <link rel="stylesheet" href="/src/styles/global.css" />
</head>
<body>
  <slot />
</body>
</html>
```

Note: In Astro, the CSS import in the layout should use a relative import path. Since `global.css` is in `src/styles/`, we import it via Astro's asset handling:

```astro
---
import '@/styles/global.css';
---
```

Use the above import instead of the link tag for proper CSS processing.

- [ ] **Step 3: Verify build**

```bash
npm run build
```

Expected: Build succeeds

- [ ] **Step 4: Commit**

```bash
git add src/styles/global.css src/layouts/BaseLayout.astro
git commit -m "feat: add BaseLayout and global CSS"
```

---

### Task 5: Header Component

**Files:**
- Create: `src/components/Header.astro`

**Interfaces:**
- Consumes: `src/data/site.json`
- Produces: `<Header />` component with logo, nav links, email, CTA button
- Used by: `index.astro`

- [ ] **Step 1: Create Header.astro**

```astro
---
// src/components/Header.astro
import site from '@/data/site.json';

const navLinks = [
  { label: 'Inicio', href: '#INICIO' },
  { label: 'Servicios', href: '#SERVICIOS' },
  { label: 'Sobre nosotros', href: '#SOBRE' },
  { label: 'Contacto', href: '#CONTACTO' },
];
---

<header class="header" data-scroll="scroll-up">
  <div class="header__container">
    <a href="#INICIO" class="header__logo-link">
      <img src="/assets/images/logo.webp" alt="{site.siteName}" class="header__logo" width="150" height="auto" />
    </a>
    <nav class="header__nav" aria-label="Menu principal">
      <ul class="header__nav-list">
        {navLinks.map((link) => (
          <li>
            <a href={link.href} class="header__nav-link">{link.label}</a>
          </li>
        ))}
      </ul>
    </nav>
    <div class="header__actions">
      <span class="header__email">{site.email}</span>
      <a href={site.instagram} target="_blank" rel="noopener noreferrer" class="btn btn--primary header__cta">
        Contáctanos ahora
      </a>
    </div>
    <button class="header__toggle" aria-label="Menú" aria-expanded="false">
      <span class="header__toggle-bar"></span>
      <span class="header__toggle-bar"></span>
      <span class="header__toggle-bar"></span>
    </button>
  </div>
</header>

<style>
  .header {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    z-index: 1000;
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(8px);
    border-bottom: 1px solid rgba(0, 0, 0, 0.08);
    transition: transform 0.3s ease;
  }

  .header[data-scroll="scroll-up"] {
    transform: translateY(0);
  }

  .header__container {
    max-width: var(--container-max);
    margin: 0 auto;
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0.75rem 1rem;
    gap: 1rem;
  }

  .header__logo {
    max-height: 50px;
    width: auto;
  }

  .header__nav-list {
    display: flex;
    gap: 2rem;
  }

  .header__nav-link {
    font-family: var(--font-body);
    font-weight: 500;
    font-size: 0.95rem;
    color: var(--color-text);
    position: relative;
    padding-bottom: 0.25rem;
    transition: var(--transition-fast);
  }

  .header__nav-link::after {
    content: '';
    position: absolute;
    bottom: 0;
    left: 0;
    width: 0;
    height: 2px;
    background: var(--color-accent);
    transition: width 0.3s ease;
  }

  .header__nav-link:hover::after {
    width: 100%;
  }

  .header__actions {
    display: flex;
    align-items: center;
    gap: 1rem;
  }

  .header__email {
    font-size: 0.85rem;
    color: var(--color-text);
  }

  .header__cta {
    padding: 0.5rem 1.25rem;
    font-size: 0.85rem;
  }

  .header__toggle {
    display: none;
    flex-direction: column;
    gap: 5px;
    background: none;
    border: none;
    cursor: pointer;
    padding: 0.5rem;
  }

  .header__toggle-bar {
    width: 24px;
    height: 2px;
    background: var(--color-dark);
    border-radius: 2px;
    transition: var(--transition-fast);
  }

  @media (max-width: 768px) {
    .header__nav,
    .header__actions {
      display: none;
    }

    .header__toggle {
      display: flex;
    }

    .header__nav.is-open {
      display: block;
      position: absolute;
      top: 100%;
      left: 0;
      right: 0;
      background: var(--color-white);
      padding: 1rem;
      box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    }

    .header__nav.is-open .header__nav-list {
      flex-direction: column;
      gap: 1rem;
    }
  }
</style>
```

- [ ] **Step 2: Commit**

```bash
git add src/components/Header.astro
git commit -m "feat: add Header component"
```

---

### Task 6: Hero Component

**Files:**
- Create: `src/components/Hero.astro`

**Interfaces:**
- Consumes: `src/data/hero.json`
- Produces: `<Hero />` component
- Used by: `index.astro`

- [ ] **Step 1: Create Hero.astro**

```astro
---
// src/components/Hero.astro
import hero from '@/data/hero.json';
---

<section id="INICIO" class="hero animate-fade-in">
  <div class="hero__content">
    <h1 class="hero__heading">{hero.heading}</h1>
    <p class="hero__subheading">{hero.subheading}</p>
    <div class="hero__text">
      {hero.paragraphs.map((p) => (
        <p class="hero__paragraph">{p}</p>
      ))}
    </div>
    <div class="hero__ctas">
      <a href={hero.primaryCta.url} class="btn btn--primary">{hero.primaryCta.text}</a>
      <a href={hero.secondaryCta.url} target="_blank" rel="noopener noreferrer" class="btn btn--secondary">{hero.secondaryCta.text}</a>
    </div>
  </div>
</section>

<style>
  .hero {
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 8rem 1rem 4rem;
    background: linear-gradient(135deg, #f6f7f7 0%, #ffffff 100%);
  }

  .hero__content {
    max-width: var(--container-max);
    width: 100%;
    text-align: center;
  }

  .hero__heading {
    font-family: var(--font-heading);
    font-size: 3.5rem;
    color: var(--color-dark);
    margin-bottom: 1rem;
    line-height: 1.2;
  }

  .hero__subheading {
    font-family: var(--font-alt);
    font-size: 1.25rem;
    color: var(--color-text);
    margin-bottom: 2.5rem;
    max-width: var(--content-max);
    margin-left: auto;
    margin-right: auto;
  }

  .hero__text {
    max-width: var(--content-max);
    margin: 0 auto 2.5rem;
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
  }

  .hero__paragraph {
    font-size: 1.05rem;
    line-height: 1.7;
    color: var(--color-text);
  }

  .hero__ctas {
    display: flex;
    gap: 1rem;
    justify-content: center;
    flex-wrap: wrap;
  }

  @media (max-width: 768px) {
    .hero__heading {
      font-size: 2.2rem;
    }
    
    .hero__subheading {
      font-size: 1.05rem;
    }
  }
</style>
```

- [ ] **Step 2: Commit**

```bash
git add src/components/Hero.astro
git commit -m "feat: add Hero component"
```

---

### Task 7: Services Component

**Files:**
- Create: `src/components/Services.astro`

**Interfaces:**
- Consumes: `src/data/services.json`
- Produces: `<Services />` component with 6-card grid
- Used by: `index.astro`

- [ ] **Step 1: Create Services.astro**

```astro
---
// src/components/Services.astro
import services from '@/data/services.json';
---

<section id="SERVICIOS" class="section services">
  <div class="container">
    <h2 class="section__title animate-slide-up">SERVICIOS</h2>
    <div class="services__grid">
      {services.map((service, index) => (
        <article class={`service-card animate-slide-up delay-${(index % 3) * 200 + 200}`}>
          <img
            src={service.image}
            alt={service.title}
            class="service-card__image"
            width="80"
            height="80"
            loading="lazy"
          />
          <h3 class="service-card__title">{service.title}</h3>
          <p class="service-card__description">{service.description}</p>
        </article>
      ))}
    </div>
  </div>
</section>

<style>
  .services {
    background: var(--color-bg-light);
  }

  .services__grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 2rem;
  }

  .service-card {
    background: var(--color-white);
    padding: 2rem;
    border-radius: 12px;
    text-align: center;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
    transition: transform 0.3s ease, box-shadow 0.3s ease;
  }

  .service-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
  }

  .service-card__image {
    margin: 0 auto 1.25rem;
    border-radius: 8px;
  }

  .service-card__title {
    font-family: var(--font-alt);
    font-size: 1.15rem;
    font-weight: 600;
    color: var(--color-dark);
    margin-bottom: 0.75rem;
  }

  .service-card__description {
    font-size: 0.95rem;
    line-height: 1.6;
    color: var(--color-text);
  }

  @media (max-width: 768px) {
    .services__grid {
      grid-template-columns: 1fr;
      gap: 1.5rem;
    }
  }

  @media (min-width: 769px) and (max-width: 1024px) {
    .services__grid {
      grid-template-columns: repeat(2, 1fr);
    }
  }
</style>
```

- [ ] **Step 2: Commit**

```bash
git add src/components/Services.astro
git commit -m "feat: add Services component"
```

---

### Task 8: About + Values Component

**Files:**
- Create: `src/components/About.astro`

**Interfaces:**
- Consumes: `src/data/about.json`, `src/data/values.json`
- Produces: `<About />` component with about text + 4 value cards
- Used by: `index.astro`

- [ ] **Step 1: Create About.astro**

```astro
---
// src/components/About.astro
import about from '@/data/about.json';
import values from '@/data/values.json';
---

<section id="SOBRE" class="section about">
  <div class="container">
    <div class="about__grid">
      <div class="about__values-grid">
        {values.slice(0, 2).map((value, i) => (
          <div class={`about__value-card animate-slide-up delay-${(i * 200) + 200}`}>
            <h3 class="about__value-title">{value.title}</h3>
            <p class="about__value-text">{value.description}</p>
          </div>
        ))}
      </div>
      <div class="about__main animate-slide-up">
        <h2 class="section__title">{about.heading}</h2>
        <p class="about__intro">{about.intro}</p>
        <p class="about__description">{about.description}</p>
      </div>
      <div class="about__values-grid">
        {values.slice(2, 4).map((value, i) => (
          <div class={`about__value-card animate-slide-up delay-${(i * 200) + 200}`}>
            <h3 class="about__value-title">{value.title}</h3>
            <p class="about__value-text">{value.description}</p>
          </div>
        ))}
      </div>
    </div>
  </div>
</section>

<style>
  .about {
    background: var(--color-white);
  }

  .about__grid {
    display: grid;
    grid-template-columns: 1fr 1.5fr 1fr;
    gap: 2rem;
    align-items: start;
  }

  .about__main {
    text-align: center;
    padding: 2rem 0;
  }

  .about__intro {
    font-family: var(--font-heading);
    font-size: 1.5rem;
    color: var(--color-dark);
    margin-bottom: 1.5rem;
    line-height: 1.4;
  }

  .about__description {
    font-size: 1rem;
    line-height: 1.8;
    color: var(--color-text);
    max-width: var(--content-max);
    margin: 0 auto;
  }

  .about__values-grid {
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
  }

  .about__value-card {
    background: var(--color-bg-light);
    padding: 1.5rem;
    border-radius: 8px;
    border-left: 3px solid var(--color-accent);
  }

  .about__value-title {
    font-family: var(--font-alt);
    font-size: 1.15rem;
    font-weight: 600;
    color: var(--color-dark);
    margin-bottom: 0.5rem;
  }

  .about__value-text {
    font-size: 0.9rem;
    line-height: 1.6;
    color: var(--color-text);
  }

  @media (max-width: 768px) {
    .about__grid {
      grid-template-columns: 1fr;
    }

    .about__values-grid {
      flex-direction: row;
      flex-wrap: wrap;
    }

    .about__value-card {
      flex: 1 1 calc(50% - 0.75rem);
    }
  }
</style>
```

- [ ] **Step 2: Commit**

```bash
git add src/components/About.astro
git commit -m "feat: add About component with values"
```

---

### Task 9: CTA, Contact, and Footer Components

**Files:**
- Create: `src/components/CTA.astro`
- Create: `src/components/Contact.astro`
- Create: `src/components/Footer.astro`

**Interfaces:**
- Consumes: `src/data/site.json`, `src/data/footer.json`
- Produces: CTA section, Contact placeholder, Footer component
- Used by: `index.astro`

- [ ] **Step 1: Create CTA.astro**

```astro
---
// src/components/CTA.astro
---

<section class="cta animate-fade-in">
  <div class="cta__content">
    <p class="cta__intro">No lo pienses</p>
    <h2 class="cta__heading">Creamos soluciones que hablan por ti</h2>
    <p class="cta__subheading">Unimos creatividad + tecnología para transformar ideas</p>
  </div>
</section>

<style>
  .cta {
    padding: 6rem 1rem;
    background: linear-gradient(135deg, var(--color-dark) 0%, #2d2d44 100%);
    color: var(--color-white);
    text-align: center;
  }

  .cta__content {
    max-width: var(--content-max);
    margin: 0 auto;
  }

  .cta__intro {
    font-family: var(--font-alt);
    font-size: 1rem;
    text-transform: uppercase;
    letter-spacing: 3px;
    margin-bottom: 1rem;
    opacity: 0.8;
  }

  .cta__heading {
    font-family: var(--font-heading);
    font-size: 2.5rem;
    line-height: 1.2;
    margin-bottom: 1rem;
  }

  .cta__subheading {
    font-size: 1.15rem;
    opacity: 0.9;
    line-height: 1.6;
  }

  @media (max-width: 768px) {
    .cta {
      padding: 4rem 1rem;
    }

    .cta__heading {
      font-size: 1.8rem;
    }
  }
</style>
```

- [ ] **Step 2: Create Contact.astro**

```astro
---
// src/components/Contact.astro
import site from '@/data/site.json';
---

<section id="CONTACTO" class="section contact">
  <div class="container">
    <h2 class="section__title animate-slide-up">CONTACTO</h2>
    <div class="contact__content animate-slide-up">
      <p class="contact__text">Estamos listos para impulsar tu proyecto.</p>
      <div class="contact__info">
        <a href={`mailto:${site.email}`} class="contact__link">{site.email}</a>
      </div>
      <!-- Formspree placeholder: el código del formulario se agrega aquí después -->
      <div id="formspree-placeholder" class="contact__form-placeholder"></div>
    </div>
  </div>
</section>

<style>
  .contact {
    background: var(--color-bg-light);
    text-align: center;
  }

  .contact__content {
    max-width: var(--content-max);
    margin: 0 auto;
  }

  .contact__text {
    font-size: 1.1rem;
    margin-bottom: 1.5rem;
  }

  .contact__info {
    margin-bottom: 2rem;
  }

  .contact__link {
    font-family: var(--font-alt);
    font-size: 1.2rem;
    font-weight: 600;
    color: var(--color-accent);
    transition: var(--transition-fast);
  }

  .contact__link:hover {
    text-decoration: underline;
  }

  .contact__form-placeholder {
    min-height: 100px;
    border: 2px dashed #ccc;
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #999;
    font-size: 0.9rem;
  }
</style>
```

- [ ] **Step 3: Create Footer.astro**

```astro
---
// src/components/Footer.astro
import footer from '@/data/footer.json';
---

<footer class="footer">
  <div class="container footer__container">
    <p class="footer__copyright">{footer.copyright}</p>
    <div class="footer__links">
      <a href={`mailto:${footer.email}`} class="footer__link">{footer.email}</a>
      <a href={footer.instagram} target="_blank" rel="noopener noreferrer" class="footer__link">
        {footer.instagramHandle}
      </a>
    </div>
  </div>
</footer>

<style>
  .footer {
    background: var(--color-dark);
    color: var(--color-white);
    padding: 2rem 0;
  }

  .footer__container {
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 1rem;
  }

  .footer__copyright {
    font-size: 0.85rem;
    opacity: 0.8;
  }

  .footer__links {
    display: flex;
    gap: 1.5rem;
  }

  .footer__link {
    font-size: 0.85rem;
    opacity: 0.8;
    transition: var(--transition-fast);
  }

  .footer__link:hover {
    opacity: 1;
    text-decoration: underline;
  }

  @media (max-width: 768px) {
    .footer__container {
      flex-direction: column;
      text-align: center;
    }
  }
</style>
```

- [ ] **Step 4: Commit**

```bash
git add src/components/CTA.astro src/components/Contact.astro src/components/Footer.astro
git commit -m "feat: add CTA, Contact, and Footer components"
```

---

### Task 10: Page Assembly — index.astro + Animations

**Files:**
- Create: `src/pages/index.astro` (overwrite placeholder)
- Create: `src/scripts/animations.js`

**Interfaces:**
- Consumes: All components (Header, Hero, Services, About, CTA, Contact, Footer)
- Produces: Complete landing page with scroll animations

- [ ] **Step 1: Create animations.js**

```js
// src/scripts/animations.js
document.addEventListener('DOMContentLoaded', () => {
  const animateElements = document.querySelectorAll('.animate-fade-in, .animate-slide-up');

  if (!animateElements.length) return;

  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add('is-visible');
          observer.unobserve(entry.target);
        }
      });
    },
    {
      threshold: 0.1,
      rootMargin: '0px 0px -50px 0px',
    }
  );

  animateElements.forEach((el) => observer.observe(el));
});
```

- [ ] **Step 2: Create index.astro**

```astro
---
// src/pages/index.astro
import BaseLayout from '@/layouts/BaseLayout.astro';
import Header from '@/components/Header.astro';
import Hero from '@/components/Hero.astro';
import Services from '@/components/Services.astro';
import About from '@/components/About.astro';
import CTA from '@/components/CTA.astro';
import Contact from '@/components/Contact.astro';
import Footer from '@/components/Footer.astro';
import '@/styles/global.css';
---

<BaseLayout>
  <Header />
  <main>
    <Hero />
    <Services />
    <About />
    <CTA />
    <Contact />
  </main>
  <Footer />
  <script src="/src/scripts/animations.js"></script>
</BaseLayout>
```

- [ ] **Step 3: Verify build**

```bash
npm run build
```

Expected: Build succeeds, `dist/index.html` contains full page with all sections

- [ ] **Step 4: Commit**

```bash
git add src/pages/index.astro src/scripts/animations.js
git commit -m "feat: assemble index page with animations"
```

---

### Task 11: Docker Compose Setup

**Files:**
- Create: `Dockerfile`
- Create: `docker-compose.yml`
- Create: `nginx.conf`

**Interfaces:**
- Consumes: `dist/` directory (produced by `npm run build`)
- Produces: Dockerized nginx serving the built site on port 8080

- [ ] **Step 1: Create Dockerfile**

```dockerfile
FROM nginx:alpine
COPY dist/ /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
```

- [ ] **Step 2: Create nginx.conf**

```nginx
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # Cache static assets
    location /assets/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

- [ ] **Step 3: Create docker-compose.yml**

```yaml
services:
  web:
    build: .
    ports:
      - "8080:80"
    restart: unless-stopped
```

- [ ] **Step 4: Verify Docker build**

```bash
docker compose build
```

Expected: Build succeeds

- [ ] **Step 5: Test container**

```bash
docker compose up -d
curl -s -o /dev/null -w "%{http_code}" http://localhost:8080
```

Expected: 200

```bash
docker compose down
```

- [ ] **Step 6: Commit**

```bash
git add Dockerfile docker-compose.yml nginx.conf
git commit -m "feat: add Docker Compose for nginx serving"
```
