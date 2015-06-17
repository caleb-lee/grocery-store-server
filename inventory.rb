require './product.rb'

class Inventory
  def initialize
    @products = Array.new
  end
  
  def initialize(numberOfProducts)
    @products = Array.new(numberOfProducts)
  end
  
  def fullInventory
    return @products
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
  
  def addProduct(product)
    @products.push(product)
  end
end