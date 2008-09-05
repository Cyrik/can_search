require File.dirname(__FILE__) + '/spec_helper'

module CanSearch
  
  describe "all Many Like Scopes", :shared => true do
    include CanSearchSpecHelper
    it "instantiate many like scope" do
      Record.search_scopes[@scope.name].should == @scope
    end

    it "creates named_scope" do
      Record.scopes[@scope.named_scope].should_not be_nil
    end
    
    it "returns writable objects" do
      Record.search(@scope.name => [1]).each{|r| r.should_not be_readonly}
    end
     
  end
  describe "all Many Like Scopes without a join table", :shared => true do
    it "finds by attribute" do
      compare_records Record.search(@scope.name => "first"), [:default]
    end        
    it "doesnt find anything on none match" do
      compare_records Record.search(@scope.name => "firste"), []
    end  
    it "finds by partial attribute" do
      compare_records Record.search(@scope.name => "irst"), [:default]
    end
    it "paginates records" do
      compare_records Record.search(:page => nil, @scope.name => "th"), [:default,:day, :week_1]
    end if ActiveRecord::Base.respond_to?(:paginate)      
  end
  describe "all Many Like Scopes with a join table", :shared => true do
    it "finds by attribute" do
      compare_records Record.search(@scope.name => "first"), [:day, :week_1]
    end        
    it "doesnt find anything on none match" do
      compare_records Record.search(@scope.name => "firste"), []
    end  
    it "finds by partial attribute" do
      compare_records Record.search(@scope.name => "irst"), [:day, :week_1]
    end
    it "paginates records" do
      compare_records Record.search(:page => nil, @scope.name => "th"), [:default,:day, :biweek_1]
    end if ActiveRecord::Base.respond_to?(:paginate)      
  end
  
  describe ManyLikeScope do
    describe "(without join table)" do
      describe "(with no options)" do
        before do
          Record.can_search do
            scoped_by :name, :scope => :many_like, :on => :record_manys
          end
          @scope = ManyLikeScope.new(Record, :name, :scope => :many_like,
            :attribute => :name, :named_scope => :many_record_manys_name_like, :on => :record_manys)
        end
        it_should_behave_like "all Many Like Scopes"
        it_should_behave_like "all Many Like Scopes without a join table"                
      end
      describe "(with custom attribute)" do
        before do
          Record.can_search do
            scoped_by :name, :scope => :many_like, :on => :record_manys, :attribute => :name
          end
          @scope = ManyLikeScope.new(Record, :name, :scope => :many_like,
            :attribute => :name, :named_scope => :many_record_manys_name_like, :on => :record_manys)
        end
        it_should_behave_like "all Many Like Scopes"
        it_should_behave_like "all Many Like Scopes without a join table"     
      end
      describe "(with custom attribute and finder name)" do
        before do
          Record.can_search do
            scoped_by :master, :scope => :many_like, :on => :record_manys, :attribute => :name,
              :named_scope => :here_i_am
          end
          @scope = ManyLikeScope.new(Record, :master, :scope => :many_like,
            :attribute => :name, :named_scope => :here_i_am, :on => :record_manys)
        end
        it_should_behave_like "all Many Like Scopes"
        it_should_behave_like "all Many Like Scopes without a join table" 
      end
    end
    describe "(with join table)" do
      describe "(with no options)" do
        before do
          Record.can_search do
            scoped_by :name, :scope => :many_like, :on => :record_many_throughs
          end
          @scope = ManyLikeScope.new(Record, :name, :scope => :many_like,
            :attribute => :name, :named_scope => :many_record_many_throughs_name_like, :on => :record_many_throughs)
        end
        it_should_behave_like "all Many Like Scopes"
        it_should_behave_like "all Many Like Scopes with a join table"                
      end
      describe "(with custom attribute)" do
        before do
          Record.can_search do
            scoped_by :name, :scope => :many_like, :on => :record_many_throughs, :attribute => :name
          end
          @scope = ManyLikeScope.new(Record, :name, :scope => :many_like,
            :attribute => :name, :named_scope => :many_record_many_throughs_name_like, :on => :record_many_throughs)
        end
        it_should_behave_like "all Many Like Scopes"
        it_should_behave_like "all Many Like Scopes with a join table"     
      end
      describe "(with custom attribute and finder name)" do
        before do
          Record.can_search do
            scoped_by :name, :scope => :many_like, :on => :record_many_throughs, :attribute => :name,
              :named_scope => :here_i_am
          end
          @scope = ManyLikeScope.new(Record, :name, :scope => :many_like,
            :attribute => :name, :named_scope => :here_i_am, :on => :record_many_throughs)
        end
        it_should_behave_like "all Many Like Scopes"
        it_should_behave_like "all Many Like Scopes with a join table" 
      end      
    end
  end
end