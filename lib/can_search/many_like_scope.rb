module CanSearch
  # Generates a named scope for searching by has_many associations.  You have specify
  # to specify :on. It works with has_many and has_many :trough.
  #
  #   class User
  #     has_many :memberships
  #     has_many :organizations, :through => :memberships
  #     can_search do
  #       scoped_by :name, :scope => :many_like, :on => :organizations
  #     end
  #   end
  #
  #   Topic.search(name => "ruby user group")
  #
  class ManyLikeScope < BaseScope
    attr_reader :on, :table_name, :format
    # Pass in :on and :attribute to select which table and whcih attribute to 
    # filther through. By default the name is used instead of :on and the attribute
    # is set to :id. You can use the same :format as in like scopes
    #
    def initialize(model, name, options = {})
      super
      @on = options[:on].to_sym
      @table_name= @model.reflect_on_association(@on).table_name.to_sym
      @attribute = options[:attribute] || name
      @named_scope   = options[:named_scope] || "many_#{@on}_#{name}_like".to_sym
      @format      = options[:format]      || "%%%s%%"    
      @model.named_scope @named_scope, lambda { |records| 
        {:joins => @on,:conditions => ["#{@table_name}.#{@attribute} LIKE ?", @format % records], :select => "DISTINCT #{@model.table_name}.*"} 
      }
    end
    
    def scope_for(finder, options = {})
      value = options.delete(@name)
      value.blank? ? finder : finder.send(@named_scope, value)
    end
    def ==(other)
      super && other.on == @on && other.table_name == @table_name && other.format == @format
    end
  end
  
  SearchScopes.scope_types[:many_like] = ManyLikeScope
end  