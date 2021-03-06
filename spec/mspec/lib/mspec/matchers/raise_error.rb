require 'mspec/utils/deprecate'

class RaiseErrorMatcher
  def initialize(exception, message, &block)
    @exception = exception
    @message = message
    @block = block
  end

  def matches?(proc)
    @result = proc.call
    return false
  rescue Exception => @actual
    if matching_exception?(@actual)
      return true
    else
      raise @actual
    end
  end

  def matching_exception?(exc)
    return false unless @exception === exc
    if @message then
      case @message
      when String
        return false if @message != exc.message
      when Regexp
        return false if @message !~ exc.message
      end
    end

    # The block has its own expectations and will throw an exception if it fails
    @block[exc] if @block

    return true
  end

  def exception_class_and_message(exception_class, message)
    if message
      "#{exception_class} (#{message})"
    else
      "#{exception_class}"
    end
  end

  def format_expected_exception
    exception_class_and_message(@exception, @message)
  end

  def format_exception(exception)
    exception_class_and_message(exception.class, exception.message)
  end

  def failure_message
    message = ["Expected #{format_expected_exception}"]

    if @actual then
      message << "but got #{format_exception(@actual)}"
    else
      message << "but no exception was raised (#{@result.pretty_inspect.chomp} was returned)"
    end

    message
  end

  def negative_failure_message
    message = ["Expected to not get #{format_expected_exception}", ""]
    unless @actual.class == @exception
      message[1] = "but got #{format_exception(@actual)}"
    end
    message
  end
end

module MSpecMatchers
  private def raise_error(exception=Exception, message=nil, &block)
    RaiseErrorMatcher.new(exception, message, &block)
  end
end
