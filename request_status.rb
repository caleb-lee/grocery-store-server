class RequestStatus
  def initialize(success, userInfo, error, statusCode)
    @success = success
    @userInfo = nil
    if success
      @userInfo = userInfo
    end
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
  
  def userInfo
    return @userInfo
  end
  
  def errorJSON
    if @error == nil
      return nil
    end
    
    return { "error" => @error }.to_json
  end
  
  def userInfoJSON
    if @userInfo == nil
      return nil
    end
    
    return @userInfo.to_json
  end
end