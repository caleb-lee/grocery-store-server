class Product
  # name -> string
  # quantity -> int
  def initialize(name, quantity)
  	@name = name
  	@quantity = quantity
  end
  
  def name
    return @name
  end
  
  def quantity
    return @quantity
  end
  
  def setQuantity(quantity)
    @quantity = quantity
  end
  
  def incrementQuantity
    @quantity += 1
  end
  
  # creates a hash from this product
  #  key is the product's name, value is the quantity
  def hash
    newHash = { @name => @quantity }
    return newHash
  end
end