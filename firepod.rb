require_relative 'config/config'
require 'sinatra'
require 'podio'

class Firepod < Sinatra::Base
  configure :production, :development do
    enable :logging
  end

  Podio.setup(
    :api_key    => PODIO[:api_key],
    :api_secret => PODIO[:api_secret]
  )

  get '/' do
    "Firepod is running..."
  end

  post '/' do
    case params['type']
      when 'hook.verify'
        # Validate the webhook
        Podio::Hook.validate(params['hook_id'], params['code'])

      when 'item.create', 'item.update'
        Podio.client.authenticate_with_credentials(PODIO[:username], PODIO[:password])

        logger.info params.inspect
        params.inspect
      when 'item.delete'
        # Do something. item_id is available in params['item_id']
    end
  end
end