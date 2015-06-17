require 'sinatra'

require './product'
require './inventory'

# set up an inventory to do work on
products = Inventory.new
products.addProduct(Product.new("apples", 123))
products.addProduct(Product.new("oranges", 62))
products.addProduct(Product.new("milk", 54))
products.addProduct(Product.new("eggs", 22))

get '/api/inventory' do
  products.fullFormattedInventory
end