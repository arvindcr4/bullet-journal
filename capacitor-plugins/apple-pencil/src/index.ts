import { registerPlugin } from '@capacitor/core';

import type { ApplePencilPlugin } from './definitions';

const ApplePencil = registerPlugin<ApplePencilPlugin>('ApplePencil', {
  web: () => import('./web').then(m => new m.ApplePencilWeb()),
});

export * from './definitions';
export { ApplePencil };