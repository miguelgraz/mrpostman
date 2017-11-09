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
    halt 422, { error: 'Address not provided' }.to_json unless params[:address]

    uri = uri_for_curated_address(params[:address])
    geocode = JSON.parse(Net::HTTP.get_response(uri).body)
    halt handle_error(geocode) if geocode['status'] != 'OK' || geocode['results'].empty?

    results = parse_geocode(geocode)
    results.to_json
  end

  def uri_for_curated_address(raw)
    raw.gsub!(/x{2,}/i, '')
    encoded = URI.encode("#{API_URL}?address=#{raw}&#{API_KEY}")
    URI.parse(encoded)
  end

  def parse_geocode(geocode)
    geocode['results'].first['address_components'].map do |component|
      next unless type = component['types'].detect { |t| ELEMENTS.key?(t) }
      [ELEMENTS[type], component['long_name']]
    end.compact.to_h
  end

  def handle_error(geocode)
    case geocode['status']
      when 'ZERO_RESULTS'
        { error: 'No results have been found' }.to_json
      when 'INVALID_REQUEST'
        [400, { error: (geocode['error_message'] || 'Invalid request') }.to_json]
      when 'OVER_QUERY_LIMIT'
        { error: (geocode['error_message'] || 'Quota of requests exceeded for the day') }.to_json
      when 'REQUEST_DENIED'
        [403, { error: (geocode['error_message'] || 'Request denied') }.to_json]
      else
        [503, { error: (geocode['error_message'] || 'Unknow error') }.to_json]
    end
  end
end
