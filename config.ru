$LOAD_PATH << './lib'

require 'rubygems'
require 'rack'
require 'wikilabel'

use Rack::CommonLogger

builder = Rack::Builder.new do
  map  '/' do
    run WikiLabel
  end
end

Rack::Handler::Mongrel.run builder, :Port => 9292
