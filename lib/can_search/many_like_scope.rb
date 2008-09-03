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
      reflection = @model.reflect_on_association(@name)
      through_reflection= reflection.through_reflection
      join_table = reflection.name       
      join_table = through_reflection.name if through_reflection 
      key = reflection.association_foreign_key
      @named_scope = options[:named_scope] || "many_#{name}".to_sym
      @model.named_scope @named_scope, lambda { |records|
        {:joins => join_table,:conditions => {"#{join_table}.#{key}" => records}, :select => "DISTINCT #{@model.table_name}.*"}
      }
    end

    def scope_for(finder, options = {})
      query = options.delete(@name)
      query.blank? ? finder : finder.send(@named_scope, query)
    end
  end

  
  SearchScopes.scope_types[:many] = ManyScope
end  