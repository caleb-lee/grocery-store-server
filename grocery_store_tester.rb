require 'minitest/autorun'
require './product'
require './request_status'
require './inventory'
require './inventory_controller'

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

class TestInventoryController < Minitest::Test
  def setup
    # set up an Inventory to do work on
    @inventory = Inventory.new
    @inventory.addProduct(Product.new("apples", 123))
    @inventory.addProduct(Product.new("oranges", 62))
    @inventory.addProduct(Product.new("milk", 54))
    @inventory.addProduct(Product.new("eggs", 22))
    @inventory.addProduct(Product.new("tofu", 50))
    
    # set up inventory controller with the inventory
    @ic = InventoryController.new(@inventory)
  end
  
  def test_updateInventoryForProductWithNameIncrement
    status = @ic.updateInventoryForProductWithName("apples")
    
    product = @inventory.productWithName("apples")
    
    assert_equal(124, product.quantity)
    assert(status.statusCode == 200)
    assert(status.success)
  end
  
  def test_updateInventoryForProductWithNameSpecifiedQuantity
    status = @ic.updateInventoryForProductWithName("oranges", 573)
    
    product = @inventory.productWithName("oranges")
    
    assert_equal(573, product.quantity)
    assert_equal(200, status.statusCode)
    assert(status.success)
  end
  
  def test_updateInventoryForProductWithNameThatDoesntExist
    status = @ic.updateInventoryForProductWithName("orangeas", 573)
    
    assert_equal(404, status.statusCode)
    assert(!status.success)
    assert(status.error == "No product with the name orangeas exists")
  end
  
  def test_updateInventoryForProductWithNegativeQuantity
    status = @ic.updateInventoryForProductWithName("oranges", -573)
    
    assert_equal(400, status.statusCode)
    assert(!status.success)
    assert(status.error == "Quantity must be positive.")
  end
  
  def test_updateInventoryForProductWithNoStock
    # setup
    @ic.zeroStockForProductWithName("eggs")
  	
    status = @ic.updateInventoryForProductWithName("eggs", 20)
    product = @inventory.productWithName("eggs")
    
    assert_equal(201, status.statusCode)
    assert(status.success)
    assert(product.quantity == 20)
  end
  
  def test_zeroStockForProductWithName
    status = @ic.zeroStockForProductWithName("tofu")
    product = @inventory.productWithName("tofu")
    
    assert_equal(200, status.statusCode)
    assert(status.success)
    assert(product.quantity == 0)
    
    status = @ic.zeroStockForProductWithName("tofu")
    assert_equal(404, status.statusCode)
    assert(!status.success)
    assert(product.quantity == 0)
  end
  
  def test_purchaseProductWithNameWhenBuyWillBeSuccessful
    status = @ic.purchaseProductWithName("milk", 2)
    product = @inventory.productWithName("milk")
    
    assert_equal(200, status.statusCode)
    assert(status.success)
    assert_equal(52, product.quantity)
  end
  
  def test_purchaseProductWithNameWhenQuantityIsTooLarge
    product = @inventory.productWithName("milk")
    originalStock = product.quantity
    status = @ic.purchaseProductWithName("milk", 100)
    
    assert_equal(400, status.statusCode)
    assert(!status.success)
    assert_equal(originalStock, product.quantity)
    assert_equal("Not enough stock to make purchase.", status.error)
  end
  
  def test_purchaseProductWithNameWhenQuantityNegative
    product = @inventory.productWithName("milk")
    originalStock = product.quantity
    status = @ic.purchaseProductWithName("milk", -20)
    
    assert_equal(400, status.statusCode)
    assert(!status.success)
    assert_equal(originalStock, product.quantity)
    assert_equal("Cannot purchase less than one of something.", status.error)
  end
  
  def test_purchaseProductWithNameWrongName
    status = @ic.purchaseProductWithName("milkk", 30)
    
    assert_equal(404, status.statusCode)
    assert(!status.success)
    assert_equal("No product with the name milkk exists.", status.error)
  end
  
  def test_purchaseProductWithNameWhenNoStock
    #setup
    @ic.zeroStockForProductWithName("milk")
  
    product = @inventory.productWithName("milk")
    status = @ic.purchaseProductWithName("milk", 1)
    
    assert_equal(404, status.statusCode)
    assert(!status.success)
    assert_equal(0, product.quantity)
    assert_equal("Product milk is not available.", status.error)
  end
end