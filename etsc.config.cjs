const tsconfig = require('./tsconfig.json');

module.exports = {
  outDir: tsconfig.compilerOptions.outDir,
  esbuild: {
    minify: false,
    target: tsconfig.compilerOptions.target,
    plugins: [],
    format: 'esm',
  },
  assets: {
    baseDir: 'src',
    outDir: tsconfig.compilerOptions.outDir,
    filePatterns: ['**/*'],
  },
};
