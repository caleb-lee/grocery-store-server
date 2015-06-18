class RequestStatus
  def initialize(success, error, statusCode)
    @success = success
    @error = nil
    if !success
      @error = error
    end
    @statusCode = statusCode
  end
  
  def success
    return @success
  end
  
  def error
    return @error
  end
  
  def statusCode
    return @statusCode
  end
  
  def errorJSON
    if @error == nil
      return nil
    else
      return "{\n  \"error\": \"#{@error}\"\n}"
    end
  end
end