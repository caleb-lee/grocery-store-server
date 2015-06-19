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
  result = productsController.fullInventoryRequest
  
  serve(result)
end

get '/api/inventory/:name' do
  result = productsController.productWithNameRequest(params['name'])
  
  serve(result)
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
  
  serve(requestStatus)
end

delete '/api/inventory/:name' do
  requestStatus = productsController.zeroStockForProductWithName(params['name'])
  serve(requestStatus)
end

post '/api/purchase/:product' do
  productName = params['product']
  jsonData = getJSONData
  requestStatus = nil
  
  if jsonData.nil? # no body
    requestStatus = productsController.purchaseProductWithName(productName, 1)
  else
    quantityToPurchase = jsonData['quantity']
    
    if quantityToPurchase == nil
      requestStatus = getInvalidJSONRequestStatus
    else  
      requestStatus = productsController.purchaseProductWithName(productName, quantityToPurchase)
    end
  end
  
  serve(requestStatus)
end

post '/api/purchase' do
  order = getJSONData
  
  if order == nil
  	reqStatus = getInvalidJSONRequestStatus
  	return serve(reqStatus)
  end
  
  reqStatus = productsController.purchaseProductsFromHash(order)
  return serve(reqStatus)
end

# takes a request status object and turns it into the correct server output
def serve(requestStatus)
  content_type :json
  status requestStatus.statusCode
  
  if !requestStatus.success
    return requestStatus.errorJSON
  end
  
  return requestStatus.userInfoJSON
end

# returns a hash with the JSON data or nil
def getJSONData
  data = nil

  begin
    data = JSON.parse request.body.read
  rescue JSON::ParserError => e 
    return nil
  end 
  
  return data
end

def getInvalidJSONRequestStatus
  reqStatus = RequestStatus.new(false, nil, "Invalid JSON.", 400)
  return reqStatus
end