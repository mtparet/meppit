module API
  class APIController < ApplicationController

    before_action :authenticate_or_resquest

    respond_to :json, :xml

    def show
      respond_with model.find(params[:id])
    end

    def index
      respond_with model.all
    end

    protected

      # curl -H "Authorization: Token token=usertokengoeshere" http://...
      def authenticate_or_resquest
        authenticate_or_request_with_http_token do |token, opt|
          User.find_by(auth_token: token).present?
        end
      end

  end
end
