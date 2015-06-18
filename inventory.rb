require './product.rb'

class Inventory
  def initialize
    @products = Array.new
  end
  
  def fullInventory
    return @products
  end
  
  # formats the inventory into a json string for a server response
  def fullFormattedInventory
    formattedProductStringFromArray(@products)
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
  
  # finds the single product and formats it into a JSON string
  # returns nil if the product isn't found
  def formattedStringForProductWithName(name)
    product = productWithName(name)
    if product == nil
	  return nil
	end
    
    arrayWithProduct = [product]
    
    return formattedProductStringFromArray(arrayWithProduct)
  end
  
  # finds multiple products and formats them into a JSON string
  # returns nil if any product isn't found
  def formattedStringForProductsWithNames(namesArray)
    arrayWithProducts = Array.new
    
    for name in namesArray
      product = productWithName(name)
      
      if product == nil
      	return nil
      else
        arrayWithProducts.push(product)
      end
    end
  
    return formattedProductStringFromArray(arrayWithProducts)
  end
  
  def addProduct(product)
    @products[@products.count] = product
  end
  
  private 
  
  # helper method to keep all the string formatting code in one place
  def formattedProductStringFromArray(arrayOfProducts)
    result = "{\n"
	
	index = 0
	for product in arrayOfProducts
	  result = result + "  \"#{product.name}\": #{product.quantity}"
	  
	  # don't add the comma on the last line
	  index += 1
	  if arrayOfProducts.count == index
	    result = result + "\n"
	  else
	    result = result + ",\n"
	  end
	end
	
	result = result + "}"
	
    return result
  end
end