module CanSearch
  # Generates a named scope for searching by has_many associations.  You can specify
  # the name of the association. It works with has_many and has_many :trough.
  #
  #   class User
  #     has_many :memberships
  #     has_many :organizations, :through => :memberships
  #     can_search do
  #       scoped_by :organizations, :scope => :many
  #     end
  #   end
  #
  #   Topic.search(:organizations => 2)
  #
  class ManyScope < BaseScope

    def initialize(model, name, options = {})
      super
      generate_attributes(options)
      @model.named_scope @named_scope, lambda { |records| 
        {:joins => @join_association,:conditions => {"#{@join_table}.#{@attribute}" => records}, :select => "DISTINCT #{@model.table_name}.*"} 
      }
    end
    
    def scope_for(finder, options = {})
      query = options.delete(@name)
      query.blank? ? finder : finder.send(@named_scope, query)
    end
    
    protected
    def generate_attributes(options)
      @on = options[:on] || @name
      @reflection = @model.reflect_on_association(@on)
      @through_reflection= @reflection.through_reflection
      @join_association = @reflection.name     
      @join_table = @reflection.table_name.to_sym     
      key = @reflection.klass.primary_key.to_sym    
      #@attribute     = options[:attribute]   || key       
      if @through_reflection and (options[:attribute] == @reflection.association_foreign_key.to_sym \
            or !options[:attribute])
        @join_association = @through_reflection.name  
        @join_table = @through_reflection.table_name.to_sym
        key = @reflection.association_foreign_key.to_sym         
      end
      @attribute     = options[:attribute]   || key     
      @named_scope   = options[:named_scope] || "many_#{@name}".to_sym
   
    end
  end
  
  SearchScopes.scope_types[:many] = ManyScope
end  



      
