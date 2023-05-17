import { createRoot } from 'react-dom/client';

import { targets } from './targets.js';

const {
  base,
  includePath = true,
  includeSearch = true,
  includeHash = true,
} = targets[window.location.hostname] ?? targets.default;

const href = `${base.replace(/\/$/u, '')}${includePath ? window.location.pathname : ''}${
  includeSearch ? window.location.search : ''
}${includeHash ? window.location.hash : ''}`;

createRoot(document.getElementById('root') as HTMLElement).render(
  <div>
    Redirecting to <a href={href}>{href}</a>...
  </div>,
);

window.location.replace(href);
