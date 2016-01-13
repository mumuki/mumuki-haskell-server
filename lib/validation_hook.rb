class ValidationHook < Mumukit::Hook
  def validate!(request)
    raise Mumukit::RequestValidationError, 'you can not use unsafe io' if unsafe?(request)
  end

  def unsafe?(request)
    [request.content, request.test, request.extra].any? { |it| it.include? 'System.IO.Unsafe' }
  end
end