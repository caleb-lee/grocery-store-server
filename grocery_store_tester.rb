require 'minitest/autorun'
require './product'
require './request_status'
require './inventory'

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

class TestInventory < Minitest::Test
  def setup
    # set up an Inventory to do work on
    @inventory = Inventory.new
    @inventory.addProduct(Product.new("apples", 123))
    @inventory.addProduct(Product.new("oranges", 62))
    @inventory.addProduct(Product.new("milk", 54))
    @inventory.addProduct(Product.new("eggs", 22))
  end
  
  def test_fullInventory
    full = @inventory.fullInventory
    
    assert(full != nil, "fullInventory returns nil value")
    assert(full.count == 4, "fullInventory doesn't contain the correct number of values")
    assert(full[0].name == "apples", "fullInventory doesn't contain the correct product")
  end
  
  def test_fullFormattedInventory
    formattedInventory = @inventory.fullFormattedInventory
    
    expectedFormattedInventory = "{\n  \"apples\": 123,\n  \"oranges\": 62,\n  \"milk\": 54,\n  \"eggs\": 22\n}"
    
    assert_equal(expectedFormattedInventory, formattedInventory, "Inventory not being formatted correctly")
  end
  
  def test_productWithNameWhenProductExists
    product = @inventory.productWithName("eggs")
    
    assert(product != nil, "product should not be nil")
    assert_equal("eggs", product.name, "product name is incorrect (pulled wrong)")
  end
  
  def test_productWithNameWhenProductDoesntExist
    product = @inventory.productWithName("egggs")
    
    assert(product == nil, "product should be nil")
  end
  
  def test_formattedStringForProductWithNameProductExists
    expectedString = "{\n  \"oranges\": 62\n}"
    actualString = @inventory.formattedStringForProductWithName("oranges")
    
    assert_equal(expectedString, actualString, "Formatted JSON string for product differs from expected.")
  end
end