// Prefix a site path with the GitHub Pages base (e.g. /Cooking-blog/).
export function url(path = '') {
  return import.meta.env.BASE_URL.replace(/\/$/, '') + '/' + path.replace(/^\//, '');
}

export function formatDate(iso: string) {
  return new Date(iso).toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' });
}

// Everything users type is escaped before it is put into the page.
export function esc(value: unknown) {
  return String(value ?? '').replace(
    /[&<>"']/g,
    (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c]!,
  );
}

// Blank lines separate paragraphs; single newlines become line breaks.
export function paragraphs(text: string) {
  return text
    .split(/\n\s*\n/)
    .map((p) => p.trim())
    .filter(Boolean)
    .map((p) => `<p>${esc(p).replace(/\n/g, '<br>')}</p>`)
    .join('');
}

export function lines(text: string) {
  return text
    .split('\n')
    .map((l) => l.trim())
    .filter(Boolean);
}
