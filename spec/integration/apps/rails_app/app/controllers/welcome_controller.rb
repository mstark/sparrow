class WelcomeController < ApplicationController
  def index
    render json: {}
  end

  def show
    render json: {keys: extract_keys, fakeKey: true, fake_key: false}
  end

  def ignore
    render json: {keys: extract_keys, camelCase: false, snake_case: true}
  end

  def posts
    render json: {keys: extract_keys}
  end

  private
  def extract_keys
    not_acceptable_keys = %w(controller format default action welcome)
    params.reduce([]) do |result, (key, value)|
      unless key.in?(not_acceptable_keys)
        result << key
        if value.is_a?(Hash)
          result << value.keys
        end
      end
      result
    end.flatten
  end
end