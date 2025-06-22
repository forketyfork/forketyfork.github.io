const path = require('path');

module.exports = {
  entry: {
    app: './js/app.js',
  },
  output: {
    // the output bundled files are written to the jekyll/dist directory, so that jekyll could pick them up
    path: path.resolve(__dirname, 'jekyll', 'dist'),
    clean: true,
    filename: './js/app.js',
  },
  module: {
    rules: [
      {
        test: /\.css$/i,
        use: ['style-loader', 'css-loader'],
      },
    ],
  },
};
