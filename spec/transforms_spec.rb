require 'rspec'
require_relative '../src/aspects.rb'
require_relative 'test_classes'


describe 'Origin Transforms' do

  context 'Inject Parameters Transform' do

    let(:mi_class_instance) { MyClass.new }

    let(:transform_methods) { Aspects.on mi_class_instance do
                                transform(where has_parameters(1,/p2/)) do
                                  inject(p2: 'bar')
                                end
                              end }

    it 'should print foo-bar (bar is already injected)' do
      transform_methods
      expect(mi_class_instance.do_something("foo")).to eq("foo-bar")
    end

    it 'should print foo-bar' do
      transform_methods
      expect(mi_class_instance.do_something("foo", "foo")).to eq("foo-bar")
    end

    it 'should print bar:foo' do
      transform_methods
      expect(mi_class_instance.do_another_something("foo", "foo")).to eq("bar:foo")
    end

    it 'should BOOM raising NoParameterException' do
      expect {
        Aspects.on MyClass do
          transform( where has_parameters(1, /p2/)) do
            inject(asdasd: proc { |receptor, mensaje, arg_anterior| "bar(#{mensaje}->#{arg_anterior})" })
          end
        end
      }.to raise_exception(NoParameterException)
    end

    it 'should print foo-bar and the proc (selector->old_parameter)' do
      Aspects.on MyClass do
        transform( where has_parameters(1, /p2/)) do
          inject(p2: proc { |receptor, mensaje, arg_anterior| "bar(#{mensaje}->#{arg_anterior})" })
        end
      end

      expect(mi_class_instance.do_something("foo", "foo")).to eq("foo-bar(do_something->foo)")
    end

  end

  context 'Redirect Transform' do

    it 'should redirect Hi World to Bye Bye World' do
      Aspects.on A do
        transform( where name(/say_hi/)) do
          redirect_to(B.new)
        end
      end

      expect(A.new.say_hi("World")).to eq("Bye Bye, World")
    end

  end

  context 'Inject Code Transform' do

    let(:sarlompa) {SarlompaClass.new}

    it 'should do the before block before the method' do
      Aspects.on SarlompaClass do
        transform(where name(/m1/)) do
          before do |instance, cont, *args|
            @x = 10
            new_args = args.map { |arg| arg*10 }
            cont.call(self ,nil , *new_args)
          end
        end
      end

      expect(sarlompa.m1(1, 2)).to be(30)
      expect(sarlompa.x).to be(10)
    end

    it 'should do the after block after the method' do
      Aspects.on SarlompaClass do
        transform(where name(/m2/)) do
          after do |instance, *args|
            if @x > 100
              2*@x
            else
              @x
            end
          end
        end
      end

      expect(sarlompa.m2(10)).to be(10)
      expect(sarlompa.m2(200)).to be(400)
    end

    it 'should get 123 instead of the result of m3' do
      Aspects.on SarlompaClass do
        transform(where name ( /m3/ )) do
          instead_of do |instance , *args|
            @x=123 + args.at(0)
            instance.x
          end
        end
      end

      expect(sarlompa.m3(10)).to be(133)
      expect(sarlompa.x).to be(133)
    end

  end

  context 'Combined Transforms' do

    it 'should' do
      Aspects.on B do
        transform(where name(/say_hi/)) do
          inject(x: "Tarola")
          instead_of do |instance, *args|
            args[0]+="!"
            "Bye Bye, #{args[0]}"
          end
        end
      end

      expect(B.new.say_hi("World")).to eq("Bye Bye, Tarola!")
    end

    it 'asdasd' do
      Aspects.on B2 do
        transform(where has_parameters(1, /p2/)) do
          inject(p2: '!')
          redirect_to(A2.new)
        end
      end

       expect(B2.new.saludar('pepe')).to eq('hola!')
    end

  end

  context 'Methods with blocks Transforms' do

    it 'should redirect not just the arguments but the block' do
      Aspects.on A3 do
        transform(where name(/hacer_algo/)) do
          redirect_to(B3.new)
        end
      end

      expect(A3.new.hacer_algo{|text|text+"!"}).to eq("Estoy en B!")
    end

    it 'should apply the before and return without calling cont' do
      Aspects.on B3 do
        transform(where has_parameters(1, /block/)) do
          before do |instance, cont, *args|
            "hello"
          end
        end
      end

      expect(B3.new.hacer_algo{ |text| text + "!" }).to eq("hello")
    end

    it 'should apply the before and return without calling cont' do
      Aspects.on B3 do
        transform(where has_parameters(1, /block/)) do
          after do |instance, *args|
            "bye"
          end
        end
      end

      expect(B3.new.hacer_algo{ |text| text + "!" }).to eq("bye")
    end

  end

  context 'Aspects with regexes' do

    it 'should apply the inject and the after for both saludar and despedir' do
      Aspects.on A4, /.*4/ do
        transform(where has_parameters(1, /p_saludar/)) do
          inject(p_saludar: "Roberto")
          after do |instance, *args|
            "Dios dice: hola " + args[0] + "!"
          end
        end

        transform(where has_parameters(1, /p_despedir/)) do
          inject(p_despedir: "Roberto")
          after do |instance, *args|
            "Dios dice: chau " + args[0] + "!"
          end
        end
      end

      expect(A4.new.despedir "Jose").to eq("Dios dice: chau Roberto!")
      expect(B4.new.saludar "Jose").to eq("Dios dice: hola Roberto!")
    end

  end


end