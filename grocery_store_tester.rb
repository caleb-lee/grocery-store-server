require 'minitest/autorun'
require 'rack/test'

require './product'
require './request_status'
require './inventory'
require './inventory_controller'
require './grocery_store_inventory_server'

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
  
  def test_hash
    product = Product.new("tofu", 5)
    assert_equal({"tofu" => 5}, product.hash)
  end
end

class TestRequestStatus < Minitest::Test
  def setup
    @success = RequestStatus.new(true, { "apples" => 30 }, "error", 200)
    @failure = RequestStatus.new(false, { "apples" => 30 }, "error", 400)
    @failureWithNoErrorMessage = RequestStatus.new(false, nil, nil, 404)
  end

  def test_initialize_and_getters
    status = RequestStatus.new(false, nil, "error", 404)
    
    assert_equal(false, status.success, "Initializer didn't set success boolean correctly")
    assert_equal("error", status.error, "Initializer didn't set error correctly")
    assert_equal(nil, status.userInfo, "Initializer didn't set userInfo correctly")
    assert_equal(404, status.statusCode, "Initializer didn't set statusCode correctly")
  end
  
  def test_error_always_nil_when_successful
    assert_equal(nil, @success.error, "Error property should be set to nil when successful")
  end
  
  def test_userInfo_always_nil_when_error
    assert_equal(nil, @failure.userInfo, "UserInfo property should be set to nil when successful")
  end
  
  def test_userInfo_correct
    assert_equal({ "apples" => 30}, @success.userInfo)
  end
  
  def test_error_exists_when_fail_if_set
    assert_equal("error", @failure.error, "Error property can be something other than nil when failed")
  end
  
  def test_error_nil_if_not_set
    assert_equal(nil, @failureWithNoErrorMessage.error, "Error property successfully set to nil")
  end
  
  def test_errorJSON
    assert_equal("{\"error\":\"error\"}", @failure.errorJSON, "JSON generated incorrectly")
  end
  
  def test_userInfoJSON
    assert_equal("{\"apples\":30}", @success.userInfoJSON, "JSON generated incorrectly")
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
  
  def test_productWithNameWhenProductExists
    product = @inventory.productWithName("eggs")
    
    assert(product != nil, "product should not be nil")
    assert_equal("eggs", product.name, "product name is incorrect (pulled wrong)")
  end
  
  def test_productWithNameWhenProductDoesntExist
    product = @inventory.productWithName("egggs")
    
    assert(product == nil, "product should be nil")
  end
  
  def test_full_product_hash
    hash = @inventory.fullInventoryHash
    
    assert_equal({"apples" => 123, "oranges" => 62, "milk" => 54, "eggs" => 22}, hash)
  end
  
  def test_hash_product_with_name_success
    hash = @inventory.productWithNameHash("apples")
    
    assert_equal({"apples" => 123}, hash)
  end
  
  def test_hash_product_with_name_failure
    hash = @inventory.productWithNameHash("applfes")
    
    assert_equal(nil, hash)
  end
  
  def test_hash_products_with_names_success
    hash = @inventory.productsWithNamesHash(["apples", "oranges"])
    
    assert_equal({"apples" => 123, "oranges" => 62}, hash)
  end
  
  def test_hash_products_with_names_failure
    hash = @inventory.productsWithNamesHash(["apples", "ordanges"])
    
    assert_equal(nil, hash)
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
    assert_equal(124, status.userInfo[product.name])
    assert(status.statusCode == 200)
    assert(status.success)
  end
  
  def test_updateInventoryForProductWithNameSpecifiedQuantity
    status = @ic.updateInventoryForProductWithName("oranges", 573)
    
    product = @inventory.productWithName("oranges")
    
    assert_equal(573, product.quantity)
    assert_equal(573, status.userInfo[product.name])
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
    assert(status.userInfo == nil)
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
    
    assert_equal(400, status.statusCode)
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
  
  def test_full_inventory_request
    status = @ic.fullInventoryRequest
    
    assert_equal(200, status.statusCode)
    assert(status.success)
    assert_equal({ "apples" => 123, "oranges" => 62, "milk" => 54, "eggs" => 22, "tofu" => 50 }, status.userInfo)
  end
  
  def test_one_name_inventory_request_success
    status = @ic.productWithNameRequest("apples")
    
    assert_equal(200, status.statusCode)
    assert(status.success)
    assert_equal({ "apples" => 123 }, status.userInfo)
  end
  
  def test_one_name_inventory_request_wrong_name
    status = @ic.productWithNameRequest("appless")
    
    assert_equal(404, status.statusCode)
    assert(!status.success)
  end
  
  def test_multi_name_inventory_request_success
    status = @ic.productsWithNamesRequest(["apples", "oranges"])
    
    assert_equal(200, status.statusCode)
    assert(status.success)
    assert_equal({ "apples" => 123, "oranges" => 62 }, status.userInfo)
  end
  
  def test_multi_name_inventory_request_failure
    status = @ic.productsWithNamesRequest(["appless", "oranges"])
    
    assert_equal(404, status.statusCode)
    assert(!status.success)
    assert_equal(nil, status.userInfo)
  end
end

class TestGroceryStoreServer < Minitest::Test
  include Rack::Test::Methods
  
  def app
    Sinatra::Application
  end
  
  def test_api_get_inventory
    get '/api/inventory'
	
	assert_equal("{\"apples\":123,\"oranges\":62,\"milk\":54,\"eggs\":22}", last_response.body)
	assert_equal(200, last_response.status)
  end
 
  def test_api_get_inventory_with_name_success
    get '/api/inventory/apples'
    
	assert_equal("{\"apples\":123}", last_response.body)
	assert_equal(200, last_response.status)
  end
   
  def test_api_get_inventory_with_name_wrong_name
    get '/api/inventory/appless'
	assert_equal("", last_response.body)
	assert_equal(404, last_response.status)
  end

  def test_api_post_inventory_increment_success
    post '/api/inventory/apples'
	
	assert_equal("{\"apples\":124}", last_response.body)
	assert_equal(200, last_response.status)
	
	# set number back to normal
	post '/api/inventory/apples', "{\n  \"quantity\": 123\n}"
  end
 
  def test_api_post_inventory_change_success
    post '/api/inventory/apples', "{\n  \"quantity\": 500\n}"
	assert(last_response.ok?)
	assert_equal("{\"apples\":500}", last_response.body)
	assert_equal(200, last_response.status)
	
	# set number back to original
	post '/api/inventory/apples', "{\n  \"quantity\": 123\n}"
  end
  
  def test_api_post_inventory_change_from_zero
    # setup
    delete '/api/inventory/apples'
    
    post '/api/inventory/apples', "{\n  \"quantity\": 500\n}"
	assert_equal("{\"apples\":500}", last_response.body)
	assert_equal(201, last_response.status)
	
	# set number back to original
	post '/api/inventory/apples', "{\n  \"quantity\": 123\n}"
  end
  
  def test_api_post_inventory_increment_wrong_name
    post '/api/inventory/appples'
	assert_equal("{\"error\":\"No product with the name appples exists\"}", last_response.body)
	assert_equal(404, last_response.status)
  end
  
  def test_api_post_inventory_negative_value
    post '/api/inventory/apples', "{\n  \"quantity\": -500\n}"
	assert_equal("{\"error\":\"Quantity must be positive.\"}", last_response.body)
	assert_equal(400, last_response.status)
  end
  
  def test_api_post_inventory_empty_json
    post '/api/inventory/oranges', "{}"
    
    assert_equal("{\"error\":\"Invalid JSON.\"}", last_response.body)
    assert_equal(400, last_response.status)
  end
   
  def test_api_delete_inventory
    delete '/api/inventory/milk'
    assert_equal(200, last_response.status)
    assert_equal("", last_response.body)
    
    delete '/api/inventory/milk'
    assert_equal(404, last_response.status)
    
    # set number back to original
	post '/api/inventory/milk', "{\n  \"quantity\": 54\n}"
  end
 
  def test_api_purchase_success_purchase_one
    post '/api/purchase/oranges'
    
	assert_equal("{\"oranges\":61}", last_response.body)
	assert_equal(200, last_response.status)
	
	# increment oranges to restore
	post '/api/inventory/oranges'
  end
  
  def test_api_purchase_success_purchase_multiple
    post '/api/purchase/oranges',  "{\n  \"quantity\": 54\n}"
    
	assert_equal("{\"oranges\":8}", last_response.body)
	assert_equal(200, last_response.status)
	
	# set number back to original
	post '/api/inventory/oranges',  "{\n  \"quantity\": 62\n}"
  end
  
  def test_api_purchase_failure_negative_quantity
    post '/api/purchase/oranges',  "{\n  \"quantity\": -54\n}"
    
	assert_equal("{\"error\":\"Cannot purchase less than one of something.\"}", last_response.body)
	assert_equal(400, last_response.status)
  end
 
  def test_api_purchase_failure_no_stock
    delete '/api/inventory/oranges'
  
    post '/api/purchase/oranges'
    
	assert_equal("{\"error\":\"Product oranges is not available.\"}", last_response.body)
	assert_equal(404, last_response.status)
	
	# set number back to original
	post '/api/inventory/oranges',  "{\n  \"quantity\": 62\n}"
  end
  
  def test_api_purchase_failure_too_little_stock
    post '/api/purchase/oranges', "{\n  \"quantity\": 100\n}"
    
	assert_equal("{\"error\":\"Not enough stock to make purchase.\"}", last_response.body)
	assert_equal(400, last_response.status)
  end
  
  def test_api_purchase_failure_name_wrong
    post '/api/purchase/orangges', "{\n  \"quantity\": 100\n}"
    
	assert_equal("{\"error\":\"No product with the name orangges exists.\"}", last_response.body)
	assert_equal(400, last_response.status)
  end
  
  def test_api_purchase_empty_json
    post '/api/purchase/oranges', "{}"
    
    assert_equal("{\"error\":\"Invalid JSON.\"}", last_response.body)
    assert_equal(400, last_response.status)
  end

  def test_api_purchase_multiple_success
    post '/api/purchase', "{\n  \"apples\": 3,\n  \"milk\": 1\n}"
    
    assert_equal("{\"apples\":120,\"milk\":53}", last_response.body)
    assert_equal(200, last_response.status)
    
    # reset
    post '/api/inventory/apples',  "{\n  \"quantity\": 123\n}"
    post '/api/inventory/milk',  "{\n  \"quantity\": 54\n}"
  end
  
  def test_api_purchase_multiple_failure_no_body
    post '/api/purchase'
    
    assert_equal(400, last_response.status)
    assert_equal("{\"error\":\"Invalid JSON.\"}", last_response.body)
  end
  
  def test_api_purchase_multiple_failure_not_enough_stock
    post '/api/purchase', "{\n  \"apples\": 500,\n  \"milk\": 1\n}"
    
    assert_equal(400, last_response.status)
    assert_equal("{\"error\":\"Not enough stock to make purchase.\"}", last_response.body)
  end
 
  def test_api_purchase_multiple_failure_invalid_name
    post '/api/purchase', "{\n  \"appples\": 3,\n  \"milk\": 1\n}"
    
    assert_equal(400, last_response.status)
    assert_equal("{\"error\":\"No product with the name appples exists.\"}", last_response.body)
  end
   
  def test_api_purchase_multiple_failure_negative_quantity
    post '/api/purchase', "{\n  \"apples\": -3,\n  \"milk\": 1\n}"
    
    assert_equal(400, last_response.status)
    assert_equal("{\"error\":\"Cannot purchase less than one of something.\"}", last_response.body)
  end

  def test_api_purchase_multiple_failure_item_out_of_stock
    delete '/api/inventory/apples'
  
    post '/api/purchase', "{\n  \"apples\": 34,\n  \"milk\": 1\n}"
    
    assert_equal(404, last_response.status)
    assert_equal("{\"error\":\"The following items are not available: apples\"}", last_response.body)
    
    # reset
    post '/api/inventory/apples',  "{\n  \"quantity\": 123\n}"
  end
  
  def test_api_purchase_multiple_failure_items_out_of_stock
    delete '/api/inventory/apples'
    delete '/api/inventory/milk'
  
    post '/api/purchase', "{\n  \"apples\": 34,\n  \"milk\": 1\n}"
    
    assert_equal(404, last_response.status)
    assert_equal("{\"error\":\"The following items are not available: apples, milk\"}", last_response.body)
    
    # reset
    post '/api/inventory/apples',  "{\n  \"quantity\": 123\n}"
    post '/api/inventory/milk',  "{\n  \"quantity\": 54\n}"
  end
end

