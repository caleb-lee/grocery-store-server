require './inventory'
require './request_status'

class InventoryController
  def initialize(inventory)
    @inventory = inventory
  end
  
  # updates the inventory for the product with a particular name
  # returns a RequestStatus object showing success or lack of success
  # if no quantity is passed in, the product quantity gets incremented
  def updateInventoryForProductWithName(name, quantity = nil)
    # find product with a certain name
    product = @inventory.productWithName(name)
    
    # if the product doesn't exist, end here
    if product == nil
      status = RequestStatus.new(false, "No product with the name #{name} exists", 404)
      return status
    end
    
    # set the new quantity if needed
    if quantity == nil
      quantity = product.quantity + 1
    end
    
    # invalid inventory update if quantity is less than 1
    if quantity < 1
      status = RequestStatus.new(false, "Quantity must be positive.", 400)
      return status
    end
    
    return updateInventoryForProduct(product, quantity)
  end
  
  def zeroStockForProductWithName(name)
  	# find product with a certain name
      product = @inventory.productWithName(name)
    
    # if the product doesn't exist, end here
    if product == nil
      status = RequestStatus.new(false, nil, 404)
      return status
    end
    
    # if the product already doesn't have stock, end
    if product.quantity == 0
      status = RequestStatus.new(false, nil, 404)
      return status
    end
    
    return updateInventoryForProduct(product, 0)
  end
  
  # performs a purchase of a quantity of the product with a particular name
  # returns a RequestStatus object showing success or lack of
  def purchaseProductWithName(name, quantity)
    if quantity < 1
      status = RequestStatus.new(false, "Cannot purchase less than one of something.", 400)
      return status
    end
    
    # get the product
    product = @inventory.productWithName(name)
    
    # if no such product exists
    if product == nil
      status = RequestStatus.new(false, "No product with the name #{name} exists.", 404)
      return status
    end
    
    if product.quantity == 0
      status = RequestStatus.new(false, "Product #{name} is not available.", 404)
      return status
    end
    
    if product.quantity - quantity < 0
      status = RequestStatus.new(false, "Not enough stock to make purchase.", 400)
      return status
    end
    
    performPurchase(product, quantity)
    status = RequestStatus.new(true, nil, 200)
    return status
  end
  
  private
  
  def performPurchase(product, quantity)
    product.setQuantity(product.quantity - quantity)
  end
  
  # this method has no error checking; you can hand it any product and quantity
  def updateInventoryForProduct(product, quantity)
    # before updating the quantity, set the status code
    statusCode = product.quantity == 0 ? 201 : 200
    
    # update quantity
    product.setQuantity(quantity)
    status = RequestStatus.new(true, nil, statusCode)
    
    return status
  end
end