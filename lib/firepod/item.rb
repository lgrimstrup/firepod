module Firepod
  class Item
    attr_accessor :title, :description, :category, :status, :service_desk_url

    # PODIO_ATTRIBUTES = %w(title description category status)

    # PODIO_ATTRIBUTES.each do |attribute|
    #   attr_accessor attribute.to_sym
    # end

    def set_attributes_from_podio(item_id)
      Podio.client.authenticate_with_credentials(PODIO[:username], PODIO[:password])
      item = Podio::Item.find(item_id)

      self.title = podio_attribute(item, 'feature')
      self.description = podio_attribute(item, 'details-of-feature-request')
      self.category = podio_attribute(item, 'category2')
      self.status = podio_attribute(item, 'status2')
      self.service_desk_url = podio_attribute(item, 'service-desk-url')

      self
    end

    def send_to_service_desk?
      ['Scoping', 'Planned', 'In Development', 'Released'].include?(status) && service_desk_url.blank?
    end

    private

    def podio_attribute(item, name)
      field = item.fields.detect{|f| f['external_id'] == name }
      return if field.nil?

      value = field['values'].try(:first)
      
      if value['value'].is_a?(Hash) 
        value['value']['text']
      elsif value['embed']
        value['embed']['original_url']
      else 
        value['value']
      end
    end
  end

end
