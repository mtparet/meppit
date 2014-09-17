class PicturesController < ApplicationController
  before_action :require_login, only: [:upload, :update, :destroy]
  before_action :find_object
  before_action :find_picture,  only: [:show, :update, :destroy]

  def upload
    @picture = Picture.new picture_params

    if @picture.valid? && @picture.save
      render json: success_json
    else
      render json: {errors: @picture.errors.messages}, status: :unprocessable_entity
    end
  end

  def show
    render layout: nil if request.xhr?
  end

  def update
    @picture.description = params[:picture][:description] unless params[:picture][:description].blank?
    @picture.save
    render json: success_json
  end

  def destroy
    @picture.destroy
    render json: {id: @picture.id, flash: flash_xhr(t 'flash.deleted')}
  end

  private

    def success_json
      {
        id: @picture.id,
        description: @picture.description,
        image_url: @picture.image.url,
        show_url: url_for([@object, @picture]),
        flash: flash_xhr(t "flash.#{ params[:action] == 'upload' ? 'file_uploaded' : 'saved' }")
      }
    end

    def picture_params
      { image: params[:picture], author: current_user, object: @object }
    end

    def find_object
      @object = find_polymorphic_object
    end

    def find_picture
      @picture = Picture.find params[:id]
    end
end
