require File.expand_path '../spec_helper.rb', __FILE__

describe "Mrpostman parse address" do
  subject { (get '/parse', params) }

  context 'with postal code and city' do
    let(:params) { 'address=14467 Potsdam' }
    it 'returns postal code, city, state and country' do
      expected = {
        'postal_code' => '14467',
        'city' => 'Potsdam',
        'state' => 'Brandenburg',
        'country' => 'Germany'
      }

      expect(json_body).to eq expected
      expect(last_response.status).to eq 200
    end
  end

  context 'with district and city' do
    let(:params) { 'address=West, Stuttgart' }
    it 'returns district, city, state and country' do
      expected = {
        'district' => 'Stuttgart-West',
        'city' => 'Stuttgart',
        'state' => 'Baden-Württemberg',
        'country' => 'Germany'
      }

      expect(json_body).to eq expected
      expect(last_response.status).to eq 200
    end
  end

  context 'with street and street number' do
    let(:params) { 'address=Friedhofweg 13, 78628 Rottweil-Neukirch, Rottweil' }
    it 'returns street, street_number, district, city, postal_code, state and country' do
      expected = {
        'street' => 'Friedhofweg',
        'street_number' => '13',
        'district' => 'Neukirch',
        'city' => 'Rottweil',
        'postal_code' => '78628',
        'state' => 'Baden-Württemberg',
        'country' => 'Germany'
      }

      expect(json_body).to eq expected
      expect(last_response.status).to eq 200
    end
  end

  context 'with a slash and the apartment number' do
    let(:params) { 'address=Schloßbergallee 69/1, 74357 Bönnigheim, Ludwigsburg (Kreis)' }
    it 'returns street, street_number, city, postal_code, state and country' do
      expected = {
        'street' => 'Schloßbergallee',
        'street_number' => '69',
        'city' => 'Bönnigheim',
        'postal_code' => '74357',
        'state' => 'Baden-Württemberg',
        'country' => 'Germany'
      }

      expect(json_body).to eq expected
      expect(last_response.status).to eq 200
    end
  end

  context 'with two or more Xs' do
    let(:params) { 'address=Hubmaierstraße xxx, 85051 Ingolstadt Unterbrunnenreut, Süd' }
    it 'ignores the Xs for the google request' do
      expected = {
        'street' => 'Hubmaierstraße',
        'district' => 'Unterbrunnenreuth',
        'city' => 'Ingolstadt',
        'postal_code' => '85051',
        'state' => 'Bayern',
        'country' => 'Germany'
      }

      expect(json_body).to eq expected
      expect(last_response.status).to eq 200
    end
  end

  context 'with a range of house numbers'
  # 'Krebspfad 7-9, 75177 Pforzheim, Nordstadt'

  context 'request without address'
  context "returns error when the address can't be processed"
  context 'with zero results from google'
  context "weird input like '76684 Ãstringen'"
end
