require './inventory'
require './request_status'

class InventoryController
  def initialize(inventory)
    @inventory = inventory
  end
  
  # returns a RequestStatus with the full inventory contained in a hash
  #  and HTTP status code
  def fullInventoryRequest
    userInfo = @inventory.fullInventoryHash
    
    status = RequestStatus.new(true, userInfo, nil, 200)
    return status
  end
  
  # finds the single product and makes a request containing its hash and an HTTP status code
  # if not found, request containing a 404
  def productWithNameRequest(name)
    productHash = @inventory.productWithNameHash(name)
    
    if (productHash == nil)
      return RequestStatus.new(false, nil, nil, 404)
    end
    
    return RequestStatus.new(true, productHash, nil, 200)
  end
  
  # finds multiple products and makes a request containing their hash and HTTP status code
  def productsWithNamesRequest(namesArray)
    hash = @inventory.productsWithNamesHash(namesArray)
    
    if hash == nil
      return RequestStatus.new(false, nil, nil, 404)
    end
    
    return RequestStatus.new(true, hash, nil, 200)
  end
  
  # updates the inventory for the product with a particular name
  # returns a RequestStatus object showing success or lack of success
  # if no quantity is passed in, the product quantity gets incremented
  def updateInventoryForProductWithName(name, quantity = nil)
    # find product with a certain name
    product = @inventory.productWithName(name)
    
    # if the product doesn't exist, end here
    if product == nil
      status = RequestStatus.new(false, nil, "No product with the name #{name} exists", 404)
      return status
    end
    
    # set the new quantity if needed
    if quantity == nil
      quantity = product.quantity + 1
    end
    
    # invalid inventory update if quantity is less than 1
    if quantity < 1
      status = RequestStatus.new(false, nil, "Quantity must be positive.", 400)
      return status
    end
    
    return updateInventoryForProduct(product, quantity)
  end
  
  def zeroStockForProductWithName(name)
  	# find product with a certain name
    product = @inventory.productWithName(name)
    
    # if the product doesn't exist, end here
    if product == nil
      status = RequestStatus.new(false, nil, nil, 404)
      return status
    end
    
    # if the product already doesn't have stock, end
    if product.quantity == 0
      status = RequestStatus.new(false, nil, nil, 404)
      return status
    end
    
    status = updateInventoryForProduct(product, 0)
    # strip userInfo from the RequestStatus object because the server isn't supposed
    #   to return anything
    return RequestStatus.new(status.success, nil, status.error, status.statusCode)
  end
  
  # performs a purchase of a quantity of the product with a particular name
  # returns a RequestStatus object showing success or lack of
  def purchaseProductWithName(name, quantity)
    # get the product
    product = @inventory.productWithName(name)
    
    # see if okay to purchase
    status = purchaseValid(name, quantity)
    
    # perform purchase if no problems with it
    if status == nil
      performPurchase(product, quantity)
      status = RequestStatus.new(true, product.hash, nil, 200)
    end  
      
    return status
  end
  
  def purchaseProductsFromHash(order)
    productNames = order.keys
    products = Array.new
    
    # check for out of stock products
    status = checkForOutOfStockProducts(order)
    if status != nil
      return status
    end
    
    # check for any other things that could make purchases invalid
    #	don't purchase in this loop because if the purchase fails
    #	you have a bunch of products that shouldn't be purchased
    for productName in productNames
      status = purchaseValid(productName, order[productName])
      
      if status != nil
        return status
      end
      
      products.push(@inventory.productWithName(productName))
    end
    
    # all purchases are valid, perform the purchases
    for product in products
      performPurchase(product, order[product.name])
    end
    
    status = RequestStatus.new(true, @inventory.productsWithNamesHash(productNames), nil, 200)
    return status
  end
  
  private
  # returns nil if valid
  # returns a RequestStatus if not
  def purchaseValid(name, quantity)
    if quantity < 1
      status = RequestStatus.new(false, nil, "Cannot purchase less than one of something.", 400)
      return status
    end
    
    # get the product
    product = @inventory.productWithName(name)
    
    # if no such product exists
    if product == nil
      status = RequestStatus.new(false, nil, "No product with the name #{name} exists.", 400)
      return status
    end
    
    if product.quantity == 0
      status = RequestStatus.new(false, nil, "Product #{name} is not available.", 404)
      return status
    end
    
    if product.quantity - quantity < 0
      status = RequestStatus.new(false, nil, "Not enough stock to make purchase.", 400)
      return status
    end
    
    return nil
  end
  
  def buildRequestStatusForOutOfStockProducts(names)
    error = "The following items are not available: #{names[0]}"
    
    index = 1
    while index < names.count do
      error = error + ", #{names[index]}"
      index += 1
    end
    
    status = RequestStatus.new(false, nil, error, 404)
    
    return status
  end
  
  # checks a hash for out of stock products
  # and returns a request status if there are any
  # returns nil if nothing out of stock or if a product doesn't exist
  def checkForOutOfStockProducts(order)
    array = Array.new
    
    for productName in order.keys
      product = @inventory.productWithName(productName)
      
      if product == nil
        return nil
      end
      
      if product.quantity == 0
        array.push(productName)
      end
    end
    
    return array.count > 0 ? buildRequestStatusForOutOfStockProducts(array) : nil
  end
  
  def performPurchase(product, quantity)
    product.setQuantity(product.quantity - quantity)
  end
  
  # this method has no error checking; you can hand it any product and quantity
  def updateInventoryForProduct(product, quantity)
    # before updating the quantity, set the status code
    statusCode = product.quantity == 0 ? 201 : 200
    
    # update quantity
    product.setQuantity(quantity)
    status = RequestStatus.new(true, product.hash, nil, statusCode)
    
    return status
  end
end