import typescript from '@rollup/plugin-typescript';
import { externals } from 'rollup-plugin-node-externals';

export default {
  input: 'src/main.ts',
  output: {
    dir: 'lib',
    format: 'esm',
    entryFileNames: '[name].mjs',
    sourcemap: true,
  },
  plugins: [typescript({ declaration: false }), externals({ deps: false, peerDeps: false })],
};
