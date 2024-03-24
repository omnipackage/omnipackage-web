# frozen_string_literal: true

require 'rollbar_nano/notifier'

class ErrorSubscriber
  def initialize(
    enabled:                ::Rails.env.production? || ENV['OMNIPACKAGE_ROLLBAR_API_KEY'].present?,
    skip_exception_classes: ['Sidekiq::JobRetry::Skip']
  )
    if enabled
      @notifier = ::RollbarNano::Notifier.new(::RollbarNano::Config.new(
        key:          ::Rails.application.credentials.rollbar_api_key || ENV['OMNIPACKAGE_ROLLBAR_API_KEY'],
        logger:       ::Rails.logger,
        environment:  ::Rails.env,
        root:         ::Rails.root,
        framework:    'Rails',
        code_version: (`git rev-parse --short HEAD`.chomp rescue '0')
      ))
    end
    @skip_exception_classes = skip_exception_classes
  end

  def report(error, handled:, severity:, context:, source: nil)
    return if @skip_exception_classes.include?(error.class.name)

    ::Rails.logger.error("#{self.class.name} #{error} (#{error.class}), handled: #{handled}, severity: #{severity}, context: #{context}, source: #{source}")

    context = defer_procs(context)

    req = context.delete(:request)
    user = context.delete(:user)

    @notifier&.log(
      severity,
      error,
      person:   person(user),
      request:  request(req),
      client:   client(req),
      extra:    { context: context, source: source, handled: handled }
    )
  end

  private

  def person(user)
    return unless user

    {
      id:       user.id,
      username: user.displayed_name,
      email:    user.email
    }
  end

  def request(req)
    return unless req

    {
      headers:    filter_parameters(req.headers.to_h),
      url:        req.original_url,
      request_id: req.request_id,
      method:     req.request_method_symbol.to_s.upcase,
      params:     filter_parameters(req.params),
      user_ip:    req.ip.to_s
    }
  end

  def client(req)
    return unless req

    {
      javascript: {
        browser: req.user_agent
      }
    }
  end

  def filter_parameters(h)
    h.map do |k, v|
      if ::Rails.application.config.filter_parameters.any? { |i| k.to_s.include?(i.to_s) }
        [k, '****']
      else
        [k, v]
      end
    end.to_h
  end

  def defer_procs(context)
    context.map do |k, v|
      if v.is_a?(::Proc)
        [k, v.call]
      else
        [k, v]
      end
    end.to_h
  end
end

::Rails.error.subscribe(ErrorSubscriber.new)
