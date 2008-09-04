require File.dirname(__FILE__) + '/spec_helper'

module CanSearch
  
  describe "all Many Scopes", :shared => true do
    include CanSearchSpecHelper
    it "instantiate reference scope" do
      Record.search_scopes[@scope.name].should == @scope
    end

    it "creates named_scope" do
      Record.scopes[@scope.named_scope].should_not be_nil
    end
    
    it "returns writable objects" do
      Record.search(@scope.name => [1]).each{|r| r.should_not be_readonly}
    end
    
  end
  describe "all Many Scopes without join table", :shared => true do
    it "finds multiple" do
      compare_records Record.search(@scope.name => [1,2,5,6]), [:default, :day, :week_1, :biweek_1]
    end    
    it "paginates records" do
      compare_records Record.search(:page => nil, @scope.name => [1,2,5,6]), [:default,:day, :biweek_1]
    end if ActiveRecord::Base.respond_to?(:paginate)    
    it "filters duplicates" do
      compare_records Record.search(@scope.name => [1,3]), [:default]
    end
  end
  describe "all Many Scopes with join table", :shared => true do
    it "finds multiple" do
      compare_records Record.search(@scope.name => [1,2,5,6]), [:default, :day, :week_1, :biweek_1]
    end    
    it "paginates records" do
      compare_records Record.search(:page => nil, @scope.name => [1,2,5,6]), [:default,:day, :week_1]
    end if ActiveRecord::Base.respond_to?(:paginate)    
    it "filters duplicates" do
      compare_records Record.search(@scope.name => [1,2]), [:default, :day, :week_1, :biweek_1]
    end
  end
  describe "all Many Scopes with join table, with diffrent attribute", :shared => true do
    it "finds multiple" do
      compare_records Record.search(@scope.name => ["first","second","fifth","sixth"]), [:default, :day, :week_1, :biweek_1]
    end    
    it "paginates records" do
      compare_records Record.search(:page => nil, @scope.name => ["first","second","fifth","sixth"]), [:default,:day, :week_1]
    end if ActiveRecord::Base.respond_to?(:paginate)    
    it "filters duplicates" do
      compare_records Record.search(@scope.name => ["first","second"]), [:default, :day, :week_1, :biweek_1]
    end
  end  
  describe ManyScope do
    describe "(without a join table)" do
      describe "(with no options)" do
        before do
          Record.can_search do
            scoped_by :record_manys, :scope => :many
          end
          @scope = ManyScope.new(Record, :record_manys, :scope => :many,:attribute => :id, :named_scope => :many_record_manys, :on => :record_manys)
        end
        it_should_behave_like "all Many Scopes"
        it_should_behave_like "all Many Scopes without join table"
      end

      describe "(with custom attribute)" do
        before do
          Record.can_search do
            scoped_by :record_manys, :scope => :many, :attribute => :id
          end
          @scope = ManyScope.new(Record, :record_manys,:scope => :many, :attribute => :id,  :named_scope => :many_record_manys, :on => :record_manys)
        end
        
        it_should_behave_like "all Many Scopes"
        it_should_behave_like "all Many Scopes without join table"
      end

      describe "(with custom attribute and finder name)" do
        before do
          Record.can_search do
            scoped_by :record_manys, :scope => :many, :attribute => :id, :named_scope => :here_i_am
          end
          @scope = ManyScope.new(Record, :record_manys,:scope => :many, :attribute => :id,  :named_scope => :here_i_am, :on => :record_manys)
        end
        it_should_behave_like "all Many Scopes"
        it_should_behave_like "all Many Scopes without join table"
      end
      
      describe "(with custom attribute, finder name and table)" do
        before do
          Record.can_search do
            scoped_by :master, :scope => :many, :attribute => :id, :named_scope => :here_i_am, :on => :record_manys
          end
          @scope = ManyScope.new(Record, :master,:scope => :many, :attribute => :id,  :named_scope => :here_i_am, :on => :record_manys)
        end
        it_should_behave_like "all Many Scopes"
        it_should_behave_like "all Many Scopes without join table"
      end
    end
    describe "(with a join table, where id==attribute)" do
      describe "(with no options)" do
        before do
          Record.can_search do
            scoped_by :record_many_throughs, :scope => :many
          end
          @scope = ManyScope.new(Record, :record_many_throughs, :scope => :many,\
              :attribute => :record_many_through_id, :named_scope => :many_record_many_throughs,\
              :on => :record_many_throughs)
        end

        it_should_behave_like "all Many Scopes"
        it_should_behave_like "all Many Scopes with join table"
      end

      describe "(with custom attribute)" do
        before do
          Record.can_search do
            scoped_by :record_many_throughs, :scope => :many, :attribute => :record_many_through_id
          end
          @scope = ManyScope.new(Record, :record_many_throughs, :scope => :many,\
              :attribute => :record_many_through_id, :named_scope => :many_record_many_throughs,\
              :on => :record_many_throughs)
        end
        
        it_should_behave_like "all Many Scopes"
        it_should_behave_like "all Many Scopes with join table"
      end

      describe "(with custom attribute and finder name)" do
        before do
          Record.can_search do
            scoped_by :record_many_throughs, :scope => :many, :attribute => :record_many_through_id,\
              :named_scope => :here_i_am
          end
          @scope = ManyScope.new(Record, :record_many_throughs, :scope => :many,\
              :attribute => :record_many_through_id, :named_scope => :here_i_am,\
              :on => :record_many_throughs)
        end
        
        it_should_behave_like "all Many Scopes"
        it_should_behave_like "all Many Scopes with join table"
      end
      
      describe "(with custom attribute, finder name and table)" do
        before do
          Record.can_search do
            scoped_by :something, :scope => :many, :attribute => :record_many_through_id,\
              :named_scope => :here_i_am, :on => :record_many_throughs
          end
          @scope = ManyScope.new(Record, :something, :scope => :many,\
              :attribute => :record_many_through_id, :named_scope => :here_i_am,\
              :on => :record_many_throughs)
        end
        
        it_should_behave_like "all Many Scopes"
        it_should_behave_like "all Many Scopes with join table"
      end     
      describe "(with custom attribute, finder name and table)" do
        before do
          Record.can_search do
            scoped_by :something, :scope => :many, :attribute => :record_many_through_id,\
              :named_scope => :here_i_am, :on => :record_many_throughs
          end
          @scope = ManyScope.new(Record, :something, :scope => :many,\
              :attribute => :record_many_through_id, :named_scope => :here_i_am,\
              :on => :record_many_throughs)
        end
        
        it_should_behave_like "all Many Scopes"
        it_should_behave_like "all Many Scopes with join table"
      end       
    end
    describe "(with a join table, where id!=attribute)" do
      describe "(with no other options)" do
        before do
          Record.can_search do
            scoped_by :record_many_throughs, :scope => :many, :attribute => :name
          end
          @scope = ManyScope.new(Record, :record_many_throughs, :scope => :many,\
              :attribute => :name, :named_scope => :many_record_many_throughs,\
              :on => :record_many_throughs)
        end
        
        it_should_behave_like "all Many Scopes"
        it_should_behave_like "all Many Scopes with join table, with diffrent attribute"
      end

      describe "(with custom attribute and finder name)" do
        before do
          Record.can_search do
            scoped_by :record_many_throughs, :scope => :many, :attribute => :name,\
              :named_scope => :here_i_am
          end
          @scope = ManyScope.new(Record, :record_many_throughs, :scope => :many,\
              :attribute => :name, :named_scope => :here_i_am,\
              :on => :record_many_throughs)
        end
        
        it_should_behave_like "all Many Scopes"
        it_should_behave_like "all Many Scopes with join table, with diffrent attribute"
      end
      
      describe "(with custom attribute, finder name and table)" do
        before do
          Record.can_search do
            scoped_by :something, :scope => :many, :attribute => :name,\
              :named_scope => :here_i_am, :on => :record_many_throughs
          end
          @scope = ManyScope.new(Record, :something, :scope => :many,\
              :attribute => :name, :named_scope => :here_i_am,\
              :on => :record_many_throughs)
        end
        
        it_should_behave_like "all Many Scopes"
        it_should_behave_like "all Many Scopes with join table, with diffrent attribute"
      end            
    end        
  end
end