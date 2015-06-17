class Product
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
  
  def setName(name)
    @name = name
  end
  
  def setQuantity(quantity)
    @quantity = quantity
  end
  
  def incrementQuantity
    @quantity = @quantity + 1
  end
end