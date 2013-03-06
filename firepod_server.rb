require_relative 'config/config'
require_relative 'lib/firepod/item'
require 'sinatra'
require 'podio'

class FirepodServer < Sinatra::Base
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
        logger.info "Validating Webhook"
        Podio::Hook.validate(params['hook_id'], params['code'])
      when 'item.create', 'item.update'
        Podio.client.authenticate_with_credentials(PODIO[:username], PODIO[:password])
        
        item = Podio::Item.find(params['item_id'])
        Firepod::Item.from_podio(item)
  
        logger.info params.inspect        
        logger.info item.fields.inspect
      when 'item.delete'
        # Do something. item_id is available in params['item_id']
    end
  end

  get '/items/:id' do
    item = Firepod::Item.new.set_attributes_from_podio(params[:id])

    "
      title: #{item.title} <br />
      description: #{item.description} <br />
      category: #{item.category} <br />
      status: #{item.status} <br />
      URL: #{item.service_desk_url} <br />
      <br />
      Send to SD? #{item.send_to_service_desk?.inspect}
    ".html_safe
  end
end