if (require.extensions['.coffee']) {
  module.exports = require('./lib/event-pipe.coffee');
} else {
  module.exports = require('./out/release/lib/event-pipe.js');
}
