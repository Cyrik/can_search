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
    attr_reader :on, :reflection, :through_reflection
    # Pass in :on and :attribute to select which table and whcih attribute to 
    # filther through. By default the name is used instead of :on and the attribute
    # is set to :id
    #
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
    def ==(other)
      super && other.on == @on && other.reflection == @reflection && \
        other.through_reflection == @through_reflection
    end    
    protected
    # By default we are using the given name as the search table name. it can be passed in
    # as :on. if its a through association and we are only looking for the key, we
    # only use the :through table, to save a join, otherwise we join on the given
    # association.
    #
    def generate_attributes(options)
      @on = options[:on] || @name
      @reflection = @model.reflect_on_association(@on)
      @through_reflection= @reflection.through_reflection
      @join_association = @reflection.name     
      @join_table = @reflection.table_name.to_sym     
      key = @reflection.klass.primary_key.to_sym          
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



      
