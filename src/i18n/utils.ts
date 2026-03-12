import de from './de.json';
import en from './en.json';

const translations: Record<string, typeof de> = { de, en };

export function getLangFromUrl(url: URL): string {
  const [, lang] = url.pathname.split('/');
  if (lang === 'en') return 'en';
  return 'de';
}

export function useTranslations(lang: string) {
  return translations[lang] || translations['de'];
}

export function getLocalizedPath(path: string, lang: string): string {
  const cleanPath = path.replace(/^\/(en)\//, '/').replace(/^\/(en)$/, '/');
  if (lang === 'en') {
    return cleanPath === '/' ? '/en/' : `/en${cleanPath}`;
  }
  return cleanPath;
}
