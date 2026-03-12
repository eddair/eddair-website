# EDDAIR Website

Premium Digital Signage Displays — Astro + Tailwind + Supabase

## Setup

1. **Abhängigkeiten installieren**
   ```bash
   npm install
   ```

2. **Umgebungsvariablen**
   - Kopiere `.env.example` nach `.env`
   - Trage Supabase URL und Anon Key ein
   - Optional: n8n Webhook URL für Kontaktformular

3. **Supabase Tabelle erstellen**
   ```sql
   CREATE TABLE contact_requests (
     id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
     name TEXT NOT NULL,
     email TEXT NOT NULL,
     company TEXT,
     message TEXT NOT NULL,
     created_at TIMESTAMPTZ DEFAULT NOW()
   );
   ```

## Entwicklung

```bash
npm run dev
```

## Build (Cloudflare Pages)

```bash
npm run build
```

- **Build command:** `npm run build`
- **Output directory:** `dist`
- **Node version:** 18+

## Projektstruktur

```
src/
├── layouts/BaseLayout.astro
├── components/
│   ├── Header.astro
│   ├── Hero.astro
│   ├── ProductShowcase.astro
│   ├── Features.astro
│   ├── UseCases.astro
│   ├── CTASection.astro
│   ├── ContactForm.astro
│   └── Footer.astro
├── pages/
│   ├── index.astro
│   ├── products.astro
│   ├── contact.astro
│   └── api/contact.ts
├── lib/supabase.ts
└── styles/global.css
```
