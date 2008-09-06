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
    attr_reader :on, :join_association, :join_table
    # Pass in :on and :attribute to select which table and whcih attribute to 
    # filther through. By default the name is used instead of :on and the attribute
    # is set to :id
    #
    def initialize(model, name, options = {})
      super
      generate_attributes(options)
      @model.named_scope @named_scope, lambda { |records| 
        {:joins => @join_association,:conditions => {"#{@join_table}.#{@attribute}" => records},
          :select => "DISTINCT #{@model.table_name}.*"} 
      }
    end
    
    def scope_for(finder, options = {})
      query = options.delete(@name)
      query.blank? ? finder : finder.send(@named_scope, query)
    end
    def ==(other)
      super && other.on == @on && other.join_association == @join_association && \
        other.join_table == @join_table
    end    
    protected
    # By default we are using the given name as the search table name. it can be passed in
    # as :on. if its a through association and we are only looking for the key, we
    # only use the :through table, to save a join, otherwise we join on the given
    # association.
    #
    def generate_attributes(options)
      @on            = options[:on] || @name
      @named_scope   = options[:named_scope] || "many_#{@name}".to_sym
      @foreign_key   = options[:foreign_key]      
      reflection = @model.reflect_on_association(@on)
      through_reflection= reflection.through_reflection
      primary_key = reflection.klass.primary_key.to_sym          
      if through_reflection and (id_search?(options[:attribute],primary_key))
        @attribute = options[:foreign_key] || reflection.association_foreign_key.to_sym 
        reflection = through_reflection        
      else
        @attribute = options[:attribute] || primary_key         
      end     
      @join_association = reflection.name.to_sym
      @join_table = reflection.table_name.to_sym      
    end
    
    def id_search?(attribute,key)
      return true if !attribute or attribute == key
      return false
    end
  end
  
  SearchScopes.scope_types[:many] = ManyScope
end  



      
