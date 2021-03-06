module Sparrow
  ##
  # Wrapper class for either a ::ActiveDispatch::Request or ::Rack::Request
  # instance for the given rack environment.
  # The wrapped class is determined based on the presence of the Rails constant.
  # @abstract RequestHttpMessage and ResponseHttpMessage should be used in
  #   practice
  class HttpMessage
    # The rack environment hash key that determines if it is a form hash request
    FORM_HASH_KEY  = 'rack.request.form_hash'
    # The rack environment hash key to access the input/output
    RACK_INPUT_KEY = 'rack.input'

    ##
    # @return [Hash] the Rack environment
    # @see #initialize
    attr_reader :env

    ##
    # Initializes the HttpMessage
    # @param [Hash] env The Rack environment
    def initialize(env)
      @env = env
    end

    ##
    # Depending on the environment this attribute may either be a
    # [::ActionDispatch::Request], when running in a Rails environment,
    # or a [::Rack::Request] otherwise
    # Encapsulates the Rack env.
    # @see #env
    # @return [Object]
    def request
      @request ||= request_class.new(env)
    end

    # @return [Boolean] true any values is insides the FORM_HASH_KEY of the
    #   rack environment
    # @see ::FORM_HASH_KEY
    # @see #env
    def form_hash?
      env[FORM_HASH_KEY].present?
    end

    # Requested path within this HTTP message
    # @return [String] the path
    def path
      http_header(:path_info)
    end

    ##
    # The HTTP Accept Header field
    # @return String the HTTP Accept Header value
    def accept
      http_header(:accept)
    end

    ##
    # The HTTP Content Type Field
    # @return String the HTTP Content-Type Header value
    def content_type
      http_header(:content_type)
    end

    ##
    # Delegates all unknown method calls to the wrapped request
    # @see #request
    def method_missing(method_name, *args)
      request.public_send(method_name, *args)
    end

    private

    def request_class
      if defined?(Rails)
        ::ActionDispatch::Request
      else
        ::Rack::Request
      end
    end

    ##
    # Make sure to use any appropriate format of common HTTP Header key syntax
    # for the given key
    def http_header(key)
      key        = key.to_s
      header_key = [
          key,
          key.upcase,
          key.upcase.dasherize,
          key.humanize,
          key.dasherize,
          key.parameterize,
          key.underscore.split('_').map(&:humanize).join('-')
      ].detect do |transformed_key|
        headers_hash[transformed_key]
      end

      return nil unless header_key
      headers_hash[header_key].to_s.split(';').first
    end
  end
end
