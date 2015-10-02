$setup=proc do
  #Conditions
  class Sarasa
    def foo ( p1 , p2 , p3 , p4 = 'a' , p5 = 'b' , p6 = 'c' )
    end
    private
    def bar ( p1 , p2 = 'a' , p3 = 'b' , p4 = 'c' )
    end
  end

  class TestClass
    def foo
    end
    private
    def bar
    end
  end


  module Marasa
    def foo ( param1 , param2 )
    end
    def bar ( param1 )
    end
  end

  module TestModule
    def foo1(p1)
    end
    def foo2(p1, p2)
    end
    def foo3(p1, p2, p3)
    end
  end

  #Transforms
  #Inject parameters transforms
  class MyClass
    def do_something(p1, p2)
      p1 + '-' + p2
    end
    def do_another_something(p2, ppp)
      p2 + ':' + ppp
    end
  end

  #Redirect Transform, combined & block
  class A
    def say_hi(p1)
      "A says: Hi, " + p1
    end
    def say_bye
      "A says: Goodbye!"
    end
    def do_something(&block)
      block.call("I'm A")
    end
  end

  class B
    def say_hi(p1)
      "B says: Hi, " + p1
    end
     def do_something(&block)
      block.call("I'm B")
    end
  end

  #Inject Transform
  class ClassWithAttrX
    attr_accessor :x
    def x_plus_y(x, y)
      x+y
    end
    def set_x_1(x)
      @x = x
    end
    def x_plus_param(x)
      @x += x
    end
  end

  module AImpostor
    private
    def say_bye
    end
  end

end