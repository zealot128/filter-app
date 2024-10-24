module.exports = {
  plugins: [
    require('postcss-import'),
    require('postcss-preset-env')({
      autoprefixer: {},
      stage: 3
    })
  ]
}
