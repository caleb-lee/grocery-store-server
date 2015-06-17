require 'sinatra'
require 'JSON'

require './product'
require './inventory'

# set up an inventory to do work on
products = Inventory.new
products.addProduct(Product.new("apples", 123))
products.addProduct(Product.new("oranges", 62))
products.addProduct(Product.new("milk", 54))
products.addProduct(Product.new("eggs", 22))

get '/api/inventory' do
  status 200
  products.fullFormattedInventory
end

get '/api/inventory/:name' do
  result = products.formattedStringForProductWithName(params['name'])
  
  if result == nil
    status 404
    ""
  else
    status 200
    result
  end
end

post '/api/inventory/:name' do
  # find product with a certain name
  product = products.productWithName(params['name'])
  
  # show error if no product of that name exists
  if product == nil
    status 404
    return ""
  end
  
  # check for body
  if request.body.read == "" # no body
    product.incrementQuantity
    
    # set correct success status code
    if product.quantity == 1
      status 201
    else
      status 200
    end
  else
    request.body.rewind # required since we read it once already
    data = JSON.parse request.body.read
    newQuantity = data['quantity']
    
    if newQuantity < 1 # if it isn't positive
      status 400
      return "{\n  \"error\": \"Quantity must be positive.\"\n}"
    else
      # set correct status code
      if product.quantity == 0
        status 201
      else
        status 200
      end
      
      product.setQuantity newQuantity
    end
  end
  
  return products.formattedStringForProductWithName(product.name)
end