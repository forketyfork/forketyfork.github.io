const path = require('path');
const fs = require('fs');
const { merge } = require('webpack-merge');
const common = require('./webpack.common.js');
const CopyPlugin = require('copy-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const CssMinimizerPlugin = require('css-minimizer-webpack-plugin');

// Emit jekyll/_data/manifest.json mapping logical asset names to their
// content-hashed output files. Jekyll reads it as site.data.manifest and links
// the fingerprinted URLs, so a content change produces a new URL and the CDN /
// browser cache can no longer serve a stale bundle.
class JekyllManifestPlugin {
  apply(compiler) {
    compiler.hooks.done.tap('JekyllManifestPlugin', (stats) => {
      const manifest = {};
      Object.keys(stats.compilation.assets).forEach((name) => {
        if (name.startsWith('js/app.') && name.endsWith('.js')) {
          manifest['app.js'] = '/' + name;
        } else if (name.startsWith('css/style.') && name.endsWith('.css')) {
          manifest['style.css'] = '/' + name;
        }
      });
      const dataDir = path.resolve(__dirname, 'jekyll', '_data');
      fs.mkdirSync(dataDir, { recursive: true });
      fs.writeFileSync(
        path.join(dataDir, 'manifest.json'),
        JSON.stringify(manifest, null, 2) + '\n'
      );
    });
  }
}

module.exports = merge(common, {
  mode: 'production',
  output: {
    filename: 'js/app.[contenthash].js',
  },
  module: {
    rules: [
      {
        test: /\.css$/i,
        use: [MiniCssExtractPlugin.loader, 'css-loader'],
      },
    ],
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: 'css/style.[contenthash].css',
    }),
    new CopyPlugin({
      patterns: [
        { from: 'img', to: 'img' },
        { from: 'js/vendor', to: 'js/vendor' },
        { from: 'favicon.ico', to: 'favicon.ico' },
        { from: 'icon.png', to: 'icon.png' },
        { from: 'css/giscus-custom.css', to: 'css/giscus-custom.css' },
      ],
    }),
    new JekyllManifestPlugin(),
  ],
  optimization: {
    minimizer: [
      `...`,
      new CssMinimizerPlugin(),
    ],
  },
});
