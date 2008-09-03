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

    def initialize(model, name, options = {})
      super
      @named_scope   = options[:named_scope] || "many_#{options[:on]}_#{name}_like".to_sym
      @format      = options[:format]      || "%%%s%%"    
      @model.named_scope @named_scope, lambda { |records| 
        {:joins => options[:on],:conditions => ["#{options[:on]}.#{name} LIKE ?", @format % records], :select => "DISTINCT #{@model.table_name}.*"} 
      }
    end
    
    def scope_for(finder, options = {})
      value = options.delete(@name)
      value.blank? ? finder : finder.send(@named_scope, value)
    end
  end
  
  SearchScopes.scope_types[:many_like] = ManyLikeScope
end  