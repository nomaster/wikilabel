$LOAD_PATH << './lib'

require 'rubygems'
require 'middleman/rack'
require 'wikilabel'

use Rack::CommonLogger

builder = Rack::Builder.new do
  map  '/label' do
    run WikiLabel
  end
  run Middleman.server
end

Rack::Handler::Mongrel.run builder, :Port => 9292
