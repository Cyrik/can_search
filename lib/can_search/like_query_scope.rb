module CanSearch
  # Generates a named scope for searching with a "LIKE ?" query. A format option can be specified 
  # to change the string used for matching. The default matching string is "%?%".
  #
  #   class Topic
  #     can_search do
  #       scoped_by :name, :scope => :like
  #     end
  #   end
  #
  #   Topic.search(:name => "john")
  #
  class LikeQueryScope < BaseScope
    attr_reader :format
    def initialize(model, name, options = {})
      super
      @named_scope = options[:named_scope] || "like_#{name}".to_sym
      @format      = options[:format]      || "%%%s%%"
      @attribute   = options[:attribute]   || @name
      @model.named_scope @named_scope, lambda { |q| {:conditions => 
            ["#{@model.table_name}.#{@attribute} LIKE ?", @format % q]} }
    end

    def scope_for(finder, options = {})
      query = options.delete(@name)
      query.blank? ? finder : finder.send(@named_scope, query)
    end
    def ==(other)
      super && other.format == @format
    end    
  end
  
  SearchScopes.scope_types[:like] = LikeQueryScope
end