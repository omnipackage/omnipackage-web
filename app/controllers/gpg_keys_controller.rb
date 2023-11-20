# frozen_string_literal: true

class GpgKeysController < ::ApplicationController
  def index
    @key_source = key_source
    @key = key_source.gpg_key

    respond_to do |format|
      format.html do # rubocop: disable Lint/EmptyBlock
      end

      format.gzip do
        set_nocache
      end
    end
  end

  def create
  end

  def update
  end

  def destroy
  end

  private

  def key_source
    if params[:repository_id]
      current_user.repositories.find(params[:repository_id])
    else
      current_user
    end
  end
end
