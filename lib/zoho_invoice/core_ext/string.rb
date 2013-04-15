module ZohoInvoiceStringExt
  def camelcase
    return self if self !~ /_/ && self =~ /[A-Z]+.*/
    split('_').map{|e| e.capitalize}.join
  end

  def to_underscore!
    g = gsub!(/(.)([A-Z])/,'\1_\2'); d = downcase!
    g || d
  end

  def to_underscore
    dup.tap { |s| s.to_underscore! }
  end
end
class String
  include ZohoInvoiceStringExt
end
