if (require.extensions['.coffee']) {
  func = require.extensions['.coffee'].toString();
  if (0 === func.indexOf('function (module, filename)')) {
    module.exports = require('./lib/event-pipe.coffee');
  } else {
    module.exports = require('./out/release/lib/event-pipe.js');
  }
} else {
  module.exports = require('./out/release/lib/event-pipe.js');
}
