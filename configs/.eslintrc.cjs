/** @type {import('eslint').Linter.Config} */
module.exports = {
  root: true,
  env: { node: true, browser: true, es2022: true, worker: true, jest: true },
  parserOptions: { ecmaVersion: 2022 },
  extends: ['rational', 'rational/react', 'rational/warn', 'rational/prettier'],
  ignorePatterns: ['node_modules', 'lib', 'out', 'dist'],
  overrides: [
    {
      files: ['*.cjs'],
      parserOptions: {
        sourceType: 'script',
      },
    },
    {
      files: ['*.js'],
      parserOptions: {
        sourceType: 'module',
      },
    },
    {
      extends: ['rational/typescript', 'rational/prettier'],
      files: ['*.ts', '*.tsx'],
      parserOptions: {
        project: './tsconfig.json',
      },
    },
  ],
};
