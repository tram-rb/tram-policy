class Article
  attr_accessor :title, :subtitle, :text

  def initialize(attributes = nil)
    assign_attributes(attributes)
  end

  private
    def assign_attributes(new_attributes = nil)
      return unless new_attributes
      new_attributes.each do |k, v|
        if respond_to?("#{k}=")
          send("#{k}=", v)
        else
          raise(UnknownAttributeError, "unknown attribute: #{k}")
        end
      end
    end
end
