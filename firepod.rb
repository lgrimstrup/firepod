require 'sinatra'

class Firepod < Sinatra::Base
  configure :production, :development do
    enable :logging
  end

  get '/' do
    logger.info params.inspect
    "Hello"
  end
end