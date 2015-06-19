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
  
  def decrementQuantity
    @quantity -= 1
  end
  
  def hash
  	{@name => @quantity}
  end
end