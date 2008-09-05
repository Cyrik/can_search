require File.dirname(__FILE__) + '/spec_helper'

module CanSearch
  describe "Composed Scopes" do
    include CanSearchSpecHelper
    describe "(with no options)" do
      before do
        Record.can_search do
          scoped_by :name, :scope => :like
          scoped_by :parents
          scoped_by :many_name, :scope => :many, :on => :record_many_throughs, :attribute => :name
          scoped_by :many_like_name, :scope => :many_like, :on => :record_many_throughs,
            :attribute => :name
        end        
      end
      it "should instantiate scopes" do
        Record.search_scopes[:name].should_not be_nil
        Record.search_scopes[:parents].should_not be_nil
        Record.search_scopes[:many_name].should_not be_nil
        Record.search_scopes[:many_like_name].should_not be_nil
      end  
      it "should create named scopes" do
        Record.scopes[:like_name].should_not be_nil
        Record.scopes[:by_parents].should_not be_nil
        Record.scopes[:many_many_name].should_not be_nil
        Record.scopes[:many_record_many_throughs_many_like_name_like].should_not be_nil        
      end  
      it "should filter records by all scopes" do
        compare_records Record.search(:name => "default",:parent => 1,:many_name => "third",\
          :many_like_name => "third"), [:default] 
      end      
    end
  end
end