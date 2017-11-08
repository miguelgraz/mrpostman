require 'bundler'
Bundler.require

API_KEY = 'AIzaSyBKGxoS7MDstNAdTFZjUzrxlgBW4T6xW1k'
API_URL = 'https://maps.googleapis.com/maps/api/geocode/json'

ELEMENTS = {
  'postal_code' => 'postal_code',
  'locality' => 'city',
  'administrative_area_level_1' => 'state',
  'country' => 'country',
  'sublocality' => 'district',
  'route' => 'street',
  'street_number' => 'street_number'
}

class Mrpostman < Sinatra::Application
  get '/parse' do
    content_type :json

    uri = uri_for_curated_address(params[:address])
    geocode = JSON.parse(Net::HTTP.get_response(uri).body)

    results = {}
    geocode['results'].first['address_components'].map do |component|
      if type = component['types'].detect { |t| ELEMENTS.key?(t) }
        results[ELEMENTS[type]] = component['long_name']
      end
    end

    results.to_json
  end

  def uri_for_curated_address(raw)
    raw.gsub!(/x{2,}/i, '')
    encoded = URI.encode("#{API_URL}?address=#{raw}&#{API_KEY}")
    URI.parse(encoded)
  end
end
