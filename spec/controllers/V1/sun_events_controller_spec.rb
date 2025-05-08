require 'rails_helper'

RSpec.describe V1::SunEventsController, type: :controller do
  render_views

  let(:json_response) { JSON.parse(response.body) }

  describe 'GET #index' do
    let(:valid_params) do
      {
        city: 'Lisbon',
        start_date: '2024-01-01',
        end_date: '2024-01-01'
      }
    end

    describe 'when all parameters are missing' do
      it 'returns 400 Bad Request' do
        get :index
        expect(response).to have_http_status(:bad_request)
        expect(json_response).to eq({ 'error' => 'Missing parameters' })
      end
    end

    describe 'when SunsetSunriseService returns an error' do
      it 'returns 422 Unprocessable Entity' do
        allow(SunsetSunriseService).to receive(:new).and_return(double(fetch_sun_day: { error: 'Invalid location' }))

        get :index, params: valid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response).to eq({ 'error' => 'Invalid location' })
      end
    end

    describe 'when service returns data from DB or API' do
      let(:build_history) { build(:sun_history) }

      it 'renders the Jbuilder index template with data' do
        data = [
          build_stubbed(:sun_history, city: 'lisbon', date: '2024-01-01', sunrise: '2024-01-01T07:00:00Z', sunset: '2024-01-01T17:00:00Z')
        ]
        allow(SunsetSunriseService).to receive(:new).and_return(double(fetch_sun_day: { data: data }))

        get :index, params: valid_params
        expect(response).to have_http_status(:ok)
        expect(json_response).to be_an(Array)
        expect(json_response.first['city']).to eq('lisbon')
        expect(json_response.first['sunrise']).to include('07:00')
      end
    end
  end
end
