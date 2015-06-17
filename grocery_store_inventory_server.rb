require 'sinatra'

require './product'
require './inventory'

# set up an inventory to do work on
products = Inventory.new

apple = Product.new("apples", 123)
products.addProduct(apple)
products.addProduct(Product.new("oranges", 62))
products.addProduct(Product.new("milk", 54))
products.addProduct(Product.new("eggs", 22))