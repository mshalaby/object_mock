require "../lib/object_mock"
require "rubygems"
require "shoulda"

class ObjectMockTest < Test::Unit::TestCase

  context "With class X" do
    setup do
      class X
        def m; "m"; end;
        def self.c; "c"; end;
        def l; self.m.upcase; end;
      end
      
      @x = X.new
      @orig_m = @x.m
      @orig_l = @x.l
      @x2 = X.new
      @orig_m2 = @x2.m
      @orig_l2 = @x2.l
      @orig_c = X.c
    end
    
    context "mocking an instance method for an object" do
      
      context "within a block" do
        setup do
  
          @x.mock(:m => lambda { "mocked" }, :l => lambda { self.m.chop.chop }) do
            @mocked_m = @x.m
            @non_mocked = @x2.m
            @mocked_l = @x.l
            @non_mocked2 = @x2.l
          end
          
        end
        
        should("mock the method within the block") do
          assert_equal "mocked", @mocked_m
          assert_equal @orig_m, @x.m
          assert_equal "mock", @mocked_l
          assert_equal @orig_l, @x.l
        end
        should("not affect other instances within the block") do
          assert_equal @orig_m, @non_mocked
          assert_equal @orig_l, @non_mocked2
        end
          
      end

      context "within a block that raises an exception" do
        should "ensure unmocking mocked methods" do
          begin
            @x.mock(:m => lambda { "mocked" }) do
              assert_equal "mocked", @x.m
              @x.not_there
            end
          rescue Exception => e
            assert_equal "m",  @x.m
          end
        end
      end

      context "with mock and unmock methods" do
        setup do
  
          @x.mock(:m => "mocked")
          @mocked_m = @x.m
          @non_mocked = @x2.m
          @x.unmock(:m)
          
        end
        
        should("mock the method") do
          assert_equal "mocked", @mocked_m
          assert_equal @orig_m, @x.m
        end
        should("not affect other instances") { assert_equal @orig_m, @non_mocked }
          
      end

      context "with arguments" do
        setup do
  
          @x.mock(:m => proc {|a, b| "mocked #{a}, #{b}"})
          @mocked_m = @x.m('a', 'b')
          @non_mocked = @x2.m
          @x.unmock(:m)
          
        end
        
        should("mock the method") do
          assert_equal "mocked a, b", @mocked_m
          assert_equal @orig_m, @x.m
        end
        should("not affect other instances") { assert_equal @orig_m, @non_mocked }
          
      end
    
    end

    context "changing the instance method definition while being mocked for an object within a block" do
      setup do

        @x.mock(:m => "mocked") do
          X.class_eval { def m; "changed"; end }
          @mocked_m = @x.m
          @non_mocked = @x2.m
        end
        
      end
      
      should("mock the method within the block") { assert_equal "mocked", @mocked_m }
      should("not affect other instances within the block") { assert_equal "changed", @non_mocked }
      should("respond with the current implementation after the block") { assert "changed", @x.m }
    end

    context "adding an instance method for an object within a block" do
      setup do

        @x.mock(:m2 => "new method") do
          @added = @x.m2
          @non_mocked = @x2.respond_to? :m2
        end
        
      end
      
      should("add the new method within the block scope") do
        assert_equal "new method", @added
        assert !@x.respond_to?(:added)
      end
      should("not affect other instances within the block") { assert !@non_mocked }
    end


    context "mocking a class method within a block" do
      setup do

        X.mock(:c => "mocked") do
          @mocked_c = X.c
        end
        
      end
      
      should("mock the method within the block") do
        assert_equal "mocked", @mocked_c
        assert_equal @orig_c, X.c
      end
    end

    context "mocking with nested blocks" do
      setup do
      
        @x.mock(:m => "mocked") do
          @before_inner = @x.m
          @x.mock(:m => "inner_mock") do
            @inner_mock = @x.m
          end
          @after_inner = @x.m
        end
        
      end
      
      should("mock the method within the outer block") do
        assert_equal "mocked", @before_inner
        assert_equal @orig_m, @x.m
      end
      should("mock the method within the inner block") do
        assert_equal "inner_mock", @inner_mock
        assert_equal @before_inner, @after_inner
      end
    end

    context "mocking an instance method at class level within a block" do
      
      context "within a block" do
        setup do
  
          @x.class_mock(:m => "mocked") do
            @mocked = @x.m
            @mocked2 = @x2.m
          end
          
        end
        
        should("mock the method within the block") do
          assert_equal "mocked", @mocked
          assert_equal "mocked", @mocked2
          assert_equal @orig_m, @x.m
          assert_equal @orig_m2, @x2.m
        end
          
      end

      context "within a block that raises an exception" do
        should "ensure unmocking mocked methods" do
          begin
            @x.class_mock(:m => lambda { "mocked" }) do
              assert_equal "mocked", @x2.m
              @x.not_there
            end
          rescue Exception => e
            assert_equal "m", @x2.m
          end
        end
      end

      context "with mock and unmock methods" do
        setup do
  
          @x.class_mock(:m => "mocked")
          @mocked = @x.m
          @mocked2 = @x2.m
          @x.class_unmock(:m)
          
        end
        
        should("mock the method") do
          assert_equal "mocked", @mocked
          assert_equal "mocked", @mocked2
          assert_equal @orig_m, @x.m
          assert_equal @orig_m2, @x2.m
        end
          
      end
    
    end
    
    
  end
  
end
