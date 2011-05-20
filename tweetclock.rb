require 'sinatra'
require 'eventmachine'
require 'em-http'
require 'json'

get '/' do
  "Hello world!"
end
