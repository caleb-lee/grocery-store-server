require 'minitest/autorun'
require './product'

class TestProduct < MiniTest::Test
  def setup
    @product = Product.new("apples", 3)
  end

  def test_initialize_and_getters
    product = Product.new("oranges", 70)
    assert_equal("oranges", product.name, "Initialize name doesn't work")
    assert_equal(70, product.quantity, "Initialize quantity doesn't work")
  end
  
  def test_setQuantity
    @product.setQuantity 5
    assert_equal(5, @product.quantity, "setQuantity doesn't work")
  end
  
  def test_incrementQuantity
    oldQuantity = @product.quantity
    
    @product.incrementQuantity
    
    assert_equal(oldQuantity + 1, @product.quantity, "incrementQuantity doesn't work")
  end
  
  def test_decrementQuantity
    oldQuantity = @product.quantity
    
    @product.decrementQuantity
    
    assert_equal(oldQuantity - 1, @product.quantity, "decrementQuantity doesn't work")
  end
end