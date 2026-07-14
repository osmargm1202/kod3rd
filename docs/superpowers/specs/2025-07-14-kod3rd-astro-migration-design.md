# Kod3rd Landing — Migración a Astro

## Goal
Migrar la landing page estática de Kod3rd (originalmente WordPress + Elementor) a **Astro SSG** con contenido en JSON, assets locales, animaciones suaves, y Docker Compose para servir con Nginx.

## Constraints
- Misma identidad visual (colores, tipografías, estilo general)
- Mismas secciones: Hero, Servicios (6 cards), Sobre Nosotros + Valores (4), CTA, Footer
- Contenido extraído a archivos JSON (`src/data/`)
- Assets locales en `public/assets/images/`
- Animaciones de entrada en scroll (fadeIn, slideInUp)
- Formulario de contacto placeholder — Formspree se agrega después
- Docker Compose con Nginx para servir el build estático
- Sin backend runtime, sin SSR

## Non-goals
- Formspree (lo configura el usuario post-migración)
- Contenido final de servicios (se actualiza después)
- Cloudflare Tunnel (fuera de alcance)
- SEO avanzado / analytics

## Architecture

```
┌─────────────┐     astro build     ┌─────────┐     nginx     ┌──────────┐
│  src/data/*.json │ ──────────────→ │  dist/  │ ────────────→ │ Browser │
│  src/components/ │                 │  static │               │          │
│  src/pages/      │                 │  files  │               └──────────┘
│  public/assets/  │                 └─────────┘
└─────────────┘                           ↑
                                    Docker Compose
                                    (nginx:alpine)
```

## Project Structure

```
kod3rd-landing/
├── public/
│   └── assets/
│       └── images/
│           ├── logo.webp
│           ├── consultoria.png
│           ├── landings.webp
│           ├── moviles.webp
│           ├── paginas-web.webp
│           ├── servicios-personalizado.webp
│           └── sistemas-de-control.webp
├── src/
│   ├── components/
│   │   ├── Header.astro
│   │   ├── Hero.astro
│   │   ├── Services.astro
│   │   ├── About.astro
│   │   ├── CTA.astro
│   │   ├── Contact.astro
│   │   └── Footer.astro
│   ├── layouts/
│   │   └── BaseLayout.astro
│   ├── data/
│   │   ├── site.json
│   │   ├── hero.json
│   │   ├── services.json
│   │   ├── about.json
│   │   ├── values.json
│   │   └── footer.json
│   ├── pages/
│   │   └── index.astro
│   └── styles/
│       └── global.css
├── astro.config.mjs
├── package.json
├── tsconfig.json
├── Dockerfile
├── docker-compose.yml
└── nginx.conf
```

## Component Tree

```
BaseLayout (meta, fonts, global CSS, animation JS)
  └── index.astro
        ├── Header
        │   ├── Logo (imagen)
        │   ├── Nav (Inicio, Servicios, Sobre nosotros, Contacto — anchor links)
        │   ├── Email (koderd.44@gmail.com)
        │   └── CTA button ("Contáctanos ahora" → Instagram)
        ├── Hero
        │   ├── Heading: "Impulsa tu éxito digital"
        │   ├── Subheading: "Creamos soluciones tecnológicas..."
        │   ├── Párrafos descriptivos (3)
        │   └── 2 CTAs (email + Instagram)
        ├── Services
        │   ├── Título: "SERVICIOS"
        │   └── Grid 6 cards:
        │       ├── Consultoría tecnológica
        │       ├── Diseños de landing page
        │       ├── Aplicaciones móviles
        │       ├── Páginas web
        │       ├── Software personalizado
        │       └── Sistemas de control
        ├── About
        │   ├── Título: "SOBRE NOSOTROS"
        │   ├── Descripción textual
        │   └── Values grid (4):
        │       ├── Innovación
        │       ├── Viabilidad
        │       ├── Seguridad
        │       └── Calidad
        ├── CTA
        │   ├── Intro: "No lo pienses"
        │   ├── Heading: "Creamos soluciones que hablan por ti"
        │   └── Subheading: "Unimos creatividad + tecnología..."
        ├── Contact (placeholder)
        │   └── Div placeholder para Formspree
        └── Footer
            ├── Copyright
            ├── Email
            └── Instagram link
```

## Data Flow (Build-time)

1. Astro lee archivos JSON de `src/data/` durante el build
2. Cada componente importa su JSON correspondiente
3. Se renderiza HTML estático completo
4. Output en `dist/` listo para servir

No hay data fetching en runtime. Las animaciones corren con un script JS inline mínimo.

## Styling

- **CSS custom properties** definidas en `global.css` con la paleta actual
- **Tipografías**: Poppins (body), DM Serif Display (headings), Montserrat (alternate)
- **Responsive**: breakpoints mobile-first
- **Metodología**: CSS vanilla con clases BEM-lite, sin framework CSS

## Animations

- **IntersectionObserver** vanilla (aprox 30 líneas)
- Efectos: `fadeIn` (opacity 0→1), `slideInUp` (translateY + opacity)
- Trigger al entrar al viewport
- Misma dirección visual que las animaciones originales de Elementor
- Clases utilitarias: `.animate-fade-in`, `.animate-slide-up`, `.animate-delay-{ms}`

## Docker

```yaml
# docker-compose.yml
services:
  web:
    build: .
    ports:
      - "8080:80"
```

```dockerfile
FROM nginx:alpine
COPY dist/ /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
```

```nginx
server {
    listen 80;
    root /usr/share/nginx/html;
    index index.html;
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

## Implementation Order (subagentes)

1. **Setup**: Init Astro project, install deps, configure
2. **Data**: Write all JSON files con contenido extraído del sitio actual
3. **Assets**: Copiar imágenes de wp-content a public/assets/images
4. **Layout + Global CSS**: BaseLayout, custom properties, reset, fonts
5. **Components**: Header → Hero → Services → About → CTA → Contact → Footer
6. **Animations**: IntersectionObserver script + CSS keyframes
7. **Page**: index.astro ensambla todo
8. **Docker**: Dockerfile + docker-compose.yml + nginx.conf
9. **Verify**: Build, revisar visualmente, corregir

## Validation
- `npm run build` exitoso sin errores
- Vista previa local con `npm run preview` se ve correcta
- Mismas secciones, mismo contenido, misma identidad visual
- Animaciones funcionales
- Layout responsivo correcto
