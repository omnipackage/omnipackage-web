class Session
  class RouteConstraint
    attr_reader :meth

    def initialize(meth)
      @meth = meth
    end

    def matches?(request)
      cookies = ::ActionDispatch::Cookies::CookieJar.build(request, request.cookies)
      user = ::Session.authenticate(cookies)&.user
      return false unless user

      user.public_send(meth)
    end
  end
end
