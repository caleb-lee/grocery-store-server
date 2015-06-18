require 'sinatra'
require 'JSON'

require './product'
require './inventory'
require './inventory_controller'
require './request_status'

# set up an Inventory to do work on
products = Inventory.new
products.addProduct(Product.new("apples", 123))
products.addProduct(Product.new("oranges", 62))
products.addProduct(Product.new("milk", 54))
products.addProduct(Product.new("eggs", 22))

# set up an InventoryController with the products Inventory
productsController = InventoryController.new(products)

get '/api/inventory' do
  status 200
  products.fullFormattedInventory
end

get '/api/inventory/:name' do
  result = products.formattedStringForProductWithName(params['name'])
  
  if result == nil
    status 404
  else
    status 200
    result
  end
end

post '/api/inventory/:name' do
  # find product with a certain name
  productName = params['name']
  
  requestStatus = nil
  
  # get JSON body's data (if it exists)
  jsonData = getJSONData
  
  if jsonData == nil
    requestStatus = productsController.updateInventoryForProductWithName(productName, nil)
  else
    quantity = jsonData['quantity']
    
    if quantity == nil
      requestStatus = getInvalidJSONRequestStatus
    else
      requestStatus = productsController.updateInventoryForProductWithName(productName, quantity)
    end
  end
  
  status requestStatus.statusCode
  if requestStatus.success
  	return products.formattedStringForProductWithName(productName)
  else
  	return requestStatus.errorJSON
  end
end

delete '/api/inventory/:name' do
  requestStatus = productsController.zeroStockForProductWithName(params['name'])
  status requestStatus.statusCode
end

post '/api/purchase/:product' do
  productName = params['product']
  jsonData = getJSONData
  requestStatus = nil
  
  if jsonData == nil # no body
    requestStatus = productsController.purchaseProductWithName(productName, 1)
  else
    quantityToPurchase = jsonData['quantity']
    
    if quantityToPurchase == nil
      requestStatus = getInvalidJSONRequestStatus
    else  
      requestStatus = productsController.purchaseProductWithName(productName, quantityToPurchase)
    end
  end
  
  status requestStatus.statusCode
  if requestStatus.success
  	return products.formattedStringForProductWithName(productName)
  else
  	return requestStatus.errorJSON
  end
end

post '/api/purchase' do
  order = getJSONData
  
  if order == nil
  	reqStatus = getInvalidJSONRequestStatus
  	status reqStatus.statusCode
  	return reqStatus.errorJSON
  end
  
  reqStatus = productsController.purchaseProductsFromHash(order)
  status reqStatus.statusCode
  
  if reqStatus.success
    return products.formattedStringForProductsWithNames(order.keys)
  else
    return reqStatus.errorJSON
  end
end

# returns a hash with the JSON data or nil
def getJSONData
  data = nil

  if request.body.read != ""
    request.body.rewind # required since we read it once already
    data = JSON.parse request.body.read
  end
  
  return data
end

def getInvalidJSONRequestStatus
  reqStatus = RequestStatus.new(false, "Invalid JSON.", 400)
  return reqStatus
end