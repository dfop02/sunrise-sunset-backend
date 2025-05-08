class ApplicationController < ActionController::API
  before_action :authenticate_api_key!

  private

  def authenticate_api_key!
    expected_key = ENV['BACKEND_API_KEY']
    provided_key = request.headers['HTTP_BACKEND_API_KEY']

    unless ActiveSupport::SecurityUtils.secure_compare(provided_key.to_s, expected_key.to_s)
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end
end
