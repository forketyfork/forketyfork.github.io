const { merge } = require('webpack-merge');
const common = require('./webpack.common.js');
const CopyPlugin = require('copy-webpack-plugin');

module.exports = merge(common, {
  mode: 'development',
  devtool: 'inline-source-map',
  plugins: [
    new CopyPlugin({
      patterns: [
        { from: 'css/giscus-custom.css', to: 'css/giscus-custom.css' },
      ],
    }),
  ],
  devServer: {
    liveReload: true,
    hot: true,
    open: true,
    static: ['./'],
  },
});
