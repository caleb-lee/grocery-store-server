require 'minitest/autorun'
require './product'
require './request_status'

class TestProduct < MiniTest::Test
  def setup
    @product = Product.new("apples", 3)
  end

  def test_initialize_and_getters
    product = Product.new("oranges", 70)
    assert_equal("oranges", product.name, "Initialize name doesn't work")
    assert_equal(70, product.quantity, "Initialize quantity doesn't work")
  end
  
  def test_setQuantity
    @product.setQuantity 5
    assert_equal(5, @product.quantity, "setQuantity doesn't work")
  end
  
  def test_incrementQuantity
    oldQuantity = @product.quantity
    
    @product.incrementQuantity
    
    assert_equal(oldQuantity + 1, @product.quantity, "incrementQuantity doesn't work")
  end
  
  def test_decrementQuantity
    oldQuantity = @product.quantity
    
    @product.decrementQuantity
    
    assert_equal(oldQuantity - 1, @product.quantity, "decrementQuantity doesn't work")
  end
end

class TestRequestStatus < Minitest::Test
  def setup
    @success = RequestStatus.new(true, "error", 200)
    @failure = RequestStatus.new(false, "error", 400)
    @failureWithNoErrorMessage = RequestStatus.new(false, nil, 404)
  end

  def test_initialize_and_getters
    status = RequestStatus.new(false, "error", 404)
    
    assert_equal(false, status.success, "Initializer didn't set success boolean correctly")
    assert_equal("error", status.error, "Initializer didn't set error correctly")
    assert_equal(404, status.statusCode, "Initializer didn't set statusCode correctly")
  end
  
  def test_error_always_nil_when_successful
    assert_equal(nil, @success.error, "Error property should be set to nil when successful")
  end
  
  def test_error_exists_when_fail_if_set
    assert_equal("error", @failure.error, "Error property can be something other than nil when failed")
  end
  
  def test_error_nil_if_not_set
    assert_equal(nil, @failureWithNoErrorMessage.error, "Error property successfully set to nil")
  end
  
  def test_errorJSON
    assert_equal("{\n  \"error\": \"error\"\n}", @failure.errorJSON, "JSON generated incorrectly")
  end
end