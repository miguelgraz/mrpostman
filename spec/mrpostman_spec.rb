require File.expand_path '../spec_helper.rb', __FILE__

describe "Mrpostman parse address" do
  subject { (get '/parse', params) }

  context 'successful requests' do
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

    context 'with a range of house numbers' do
      let(:params) { 'address=Oppenheimer Str. bei 12-18, 70499 Stuttgart, Weilimdorf' }
      it 'returns the data for the first one' do
        expected = {
          'street_number' => '12',
          'street' => 'Oppenheimer Straße',
          'district' => 'Weilimdorf',
          'city' => 'Stuttgart',
          'postal_code' => '70499',
          'state' => 'Baden-Württemberg',
          'country' => 'Germany'
        }

        expect(json_body).to eq expected
        expect(last_response.status).to eq 200
      end
    end
  end


  context 'bad requests' do
    context 'request without address' do
      let(:params) { 'lackofaddressparam' }
      it 'returns a clear error' do
        expected = {
          'error' => 'Address not provided'
        }

        expect(json_body).to eq expected
        expect(last_response.status).to eq 422
      end
    end

    context "returns error when the address can't be processed" do
      let(:params) { 'address=thisdefinitelyisnotavalidaddress' }
      it 'informs that no address have been found' do
        expected = {
          'error' => 'No results have been found'
        }

        expect(json_body).to eq expected
        expect(last_response.status).to eq 200
      end
    end

    context "weird input like '76684 Ãstringen'" do
      let(:params) { 'address=76684 Ãstringen' }
      it 'return an invalid request' do
        expected = {
          'error' => 'Invalid request. One of the input parameters contains a non-UTF-8 string.'
        }

        expect(json_body).to eq expected
        expect(last_response.status).to eq 400
      end
    end

    context 'when the quota was exceeded' do
      let(:params) { 'address=doesntmatter' }
      it 'returns the proper error' do
        allow_any_instance_of(Net::HTTPResponse).to receive(:body).and_return(
          {
            'status' => 'OVER_QUERY_LIMIT',
            'results' => [],
            'error_message' => 'No more requests for you'
          }.to_json
        )
        expected = {
          'error' => 'No more requests for you'
        }

        expect(json_body).to eq expected
        expect(last_response.status).to eq 200
      end
    end

    context 'when the request was denied by Google' do
      let(:params) { 'address=doesntmatter' }
      it 'returns the proper error' do
        allow_any_instance_of(Net::HTTPResponse).to receive(:body).and_return(
          {
            'status' => 'REQUEST_DENIED',
            'results' => [],
            'error_message' => 'Request denied by Google, are they hiding something?'
          }.to_json
        )
        expected = {
          'error' => 'Request denied by Google, are they hiding something?'
        }

        expect(json_body).to eq expected
        expect(last_response.status).to eq 403
      end
    end

    context 'when an unknow error with details from Google happened' do
      let(:params) { 'address=doesntmatter' }
      it 'returns the proper error' do
        allow_any_instance_of(Net::HTTPResponse).to receive(:body).and_return(
          {
            'status' => 'UNKNOWN_ERROR',
            'results' => [],
            'error_message' => "Google's servers exploded"
          }.to_json
        )
        expected = {
          'error' => "Google's servers exploded"
        }

        expect(json_body).to eq expected
        expect(last_response.status).to eq 503
      end
    end

    context 'when an unknow error with details from Google happened' do
      let(:params) { 'address=doesntmatter' }
      it 'returns the proper error' do
        allow_any_instance_of(Net::HTTPResponse).to receive(:body).and_return(
          {
            'status' => 'UNKNOWN_ERROR',
            'results' => []
          }.to_json
        )
        expected = {
          'error' => 'Unknow error'
        }

        expect(json_body).to eq expected
        expect(last_response.status).to eq 503
      end
    end
  end
end
