module MainHelper
  
  def product_label(product)
    return "#{product.name}<br/><span id=\"product_#{product.id}_price\">#{product.price_str}</span>"
  end
  
end
