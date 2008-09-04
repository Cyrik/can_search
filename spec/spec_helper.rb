require 'rubygems'

dir = File.dirname(__FILE__)
rails_app_spec = "#{dir}/../../../../config/environment.rb"
vendor_rspec   = "#{dir}/../../rspec/lib"
$:.unshift "#{dir}/../lib"

if File.exist?(vendor_rspec)
  $:.unshift vendor_rspec
else
  gem 'rspec'
end

if File.exist?(rails_app_spec)
  require rails_app_spec
else
  gem 'activesupport', '>=2.1'
  gem 'activerecord', '>=2.1'
  require 'active_support'
  require 'active_record'
  require 'will_paginate'
  WillPaginate.enable_activerecord
  ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => ":memory:"
  require 'can_search'
  require "#{dir}/../init"
end

Time.zone = "UTC"

require 'ruby-debug'
require 'spec'
require 'can_search'
require 'can_search/search_scopes'

module CanSearch
  class Record < ActiveRecord::Base
    set_table_name 'can_search_records'
    has_many :record_manys
    has_many :record_many_throughs, :through => :record_manys
    def self.per_page() 3 end

    def self.create_table
      connection.create_table table_name, :force => true do |t|
        t.string   :name
        t.integer  :parent_id
        t.datetime :created_at
      end
      connection.add_index :can_search_records, :name
    end
    
    def self.drop_table
      connection.drop_table table_name
    end
    
    def self.seed_data(now = Time.now.utc)
      transaction do
        create :name => 'default',  :parent_id => 1, :created_at => now - 5.minutes
        create :name => 'day',      :parent_id => 2, :created_at => now - 8.minutes
        create :name => 'week_1',   :parent_id => 1, :created_at => now - 3.days
        create :name => 'week_2',   :parent_id => 2, :created_at => now - (4.days + 20.hours)
        create :name => 'biweek_1', :parent_id => 2, :created_at => now - 8.days
        create :name => 'biweek_2', :parent_id => 1, :created_at => now - (14.days + 20.hours)
        create :name => 'month_1',  :parent_id => 2, :created_at => now - 20.days
        create :name => 'month_2',  :parent_id => 1, :created_at => now - (28.days + 20.hours)
        create :name => 'archive',  :parent_id => 1, :created_at => now - 35.days
      end
    end
  end
  class RecordMany < ActiveRecord::Base
    set_table_name 'can_search_manys'
    belongs_to :record
    belongs_to :record_many_through
    def self.per_page() 3 end

    def self.create_table
      connection.create_table table_name, :force => true do |t|
        t.string   :name
        t.integer  :record_id
        t.integer  :record_many_through_id
        t.datetime :created_at
      end
      connection.add_index :can_search_manys, :name
      connection.add_index :can_search_manys, :record_id
      connection.add_index :can_search_manys, :record_many_through_id
    end
    
    def self.drop_table
      connection.drop_table table_name
    end
    
    def self.seed_data(now = Time.now.utc)
      transaction do
        create :name => 'first',   :record_id => 1, :record_many_through_id => 2, :created_at => now - 5.minutes
        create :name => 'second',  :record_id => 2, :record_many_through_id => 1, :created_at => now - 8.minutes
        create :name => 'third',   :record_id => 1, :record_many_through_id => 3, :created_at => now - 3.days
        create :name => 'fourth',  :record_id => 2, :record_many_through_id => 4, :created_at => now - (4.days + 20.hours)
        create :name => 'fifth',   :record_id => 5, :record_many_through_id => 3, :created_at => now - 8.days
        create :name => 'sixth',   :record_id => 3, :record_many_through_id => 1, :created_at => now - (14.days + 20.hours)
        create :name => 'seventh', :record_id => 1, :record_many_through_id => 2, :created_at => now - 20.days
        create :name => 'eigth',   :record_id => 2, :record_many_through_id => 1, :created_at => now - (28.days + 20.hours)
        create :name => 'nineth',  :record_id => 5, :record_many_through_id => 2, :created_at => now - 35.days
      end
    end    
  end
  class RecordManyThrough < ActiveRecord::Base
    set_table_name 'can_search_many_throughs'
    def self.per_page() 3 end

    def self.create_table
      connection.create_table table_name, :force => true do |t|
        t.string   :name
        t.datetime :created_at
      end
      connection.add_index :can_search_many_throughs, :name
    end
    
    def self.drop_table
      connection.drop_table table_name
    end
    
    def self.seed_data(now = Time.now.utc)
      transaction do
        create :name => 'first',   :created_at => now - 5.minutes
        create :name => 'second',  :created_at => now - 8.minutes
        create :name => 'third',   :created_at => now - 3.days
        create :name => 'fourth',  :created_at => now - (4.days + 20.hours)
        create :name => 'fifth',   :created_at => now - 8.days
        create :name => 'sixth',   :created_at => now - (14.days + 20.hours)
        create :name => 'seventh', :created_at => now - 20.days
        create :name => 'eigth',   :created_at => now - (28.days + 20.hours)
        create :name => 'nineth',  :created_at => now - 35.days
      end
    end    
  end  
  module CanSearchSpecHelper
    def self.included(base)
      base.before :all do
        @now = Time.utc 2007, 6, 30, 6
        Record.create_table
        Record.seed_data @now
        RecordMany.create_table
        RecordMany.seed_data @now
        RecordManyThrough.create_table
        RecordManyThrough.seed_data @now
        @expected_index = Record.find(:all).inject({}) { |h, r| h.update r.name.to_sym => r }
      end

      base.before do
        Time.stub!(:now).and_return(@now)
      end
      
      base.after :all do
        Record.drop_table
      end
    end

    def records(key)
      @expected_index[key]
    end
    
    def compare_records(actual, expected)
      actual = actual.sort { |x, y| y.created_at <=> x.created_at }
      expected.each do |e| 
        a_index = actual.index(records(e))
        e_index = expected.index(e)
        if a_index.nil?
          fail "Record record(#{e.inspect}) was not in the array, but should have been."
        else
          fail "Record record(#{e.inspect}) is in wrong position: #{a_index.inspect} instead of #{e_index.inspect}" unless a_index == e_index
        end
      end
      
      actual.size.should == expected.size
    end
  end
end

Debugger.start