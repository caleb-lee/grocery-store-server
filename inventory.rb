require './product.rb'
require './request_status'

class Inventory
  def initialize
    @products = Array.new
  end
  
  def fullInventory
    return @products
  end
  
  # get product hash
  def fullInventoryHash
    inventory = Hash.new
    
    for product in fullInventory
      inventory[product.name] = product.quantity
    end
    
    return inventory
  end
  
  # returns nil if there isn't a product with that name
  def productWithName(name)
    for product in @products
      if (product.name == name)
        return product
      end
    end
    
    return nil
  end
  
  # finds the single product and makes a hash of it
  # returns nil if the product isn't found
  def productWithNameHash(name)
    product = productWithName(name)
    if product == nil
	  return nil
	end
    
    return product.hash
  end
  
  # finds multiple products and makes them into a hash
  # returns nil if any product isn't found
  def productsWithNamesHash(namesArray)
    hash = Hash.new
    
    for name in namesArray
      product = productWithName(name)
      
      if product == nil
      	return nil
      else
        hash[product.name] = product.quantity
      end
    end
  
    return hash
  end
  
  def addProduct(product)
    @products.push(product)
  end
end