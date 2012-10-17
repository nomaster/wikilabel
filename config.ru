$LOAD_PATH << './lib'

require 'rubygems'
require 'middleman/rack'
require 'wikilabel'

use Rack::CommonLogger

map  '/label' do
  run WikiLabel
end

run Middleman.server
