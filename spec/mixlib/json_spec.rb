require File.expand_path(File.join(File.dirname(__FILE__), "..", '/spec_helper'))

describe "Mixlib::JSON" do
  describe "detect_loaded_library" do
    it "should return true if a library is pre-loaded" do
      Mixlib::JSON::YAJL.should_receive(:is_loaded?).and_return(true)
      Mixlib::JSON.detect_loaded_library.should == true
    end

    it "should set the json_obj to an instance of the pre-loaded libraries serializer" do
      Mixlib::JSON::YAJL.should_receive(:is_loaded?).and_return(true)
      Mixlib::JSON.detect_loaded_library
      Mixlib::JSON.json_obj.should be_a_kind_of(Mixlib::JSON::YAJL)
    end

    it "should return false if no library is loaded" do
      Mixlib::JSON.json_load_order = []
      Mixlib::JSON.detect_loaded_library.should == false
    end
  end

  describe "select_json_library" do
    it "Should use the detected library" do
      Mixlib::JSON.should_receive(:detect_loaded_library).and_return(true)
      Mixlib::JSON.should_not_receive(:json_load_order)
      Mixlib::JSON.select_json_library
    end
  end

  describe "generate" do
    it "should proxy to the real json_obj" do
      Mixlib::JSON::YAJL.load
      Mixlib::JSON.generate({ "one" => "two" }).should == '{"one":"two"}'
    end
  end

  describe "pretty" do
    it "should proxy to the real json_obj" do
      Mixlib::JSON::YAJL.load
      Mixlib::JSON.pretty({ "one" => "two" }).should == "{\n  \"one\": \"two\"\n}"
    end
  end

  describe "parse" do
    it "should proxy to the real json_obj" do
      Mixlib::JSON::YAJL.load
      Mixlib::JSON.parse('{"one":"two"}').should == { "one" => "two" }
    end

    class Woobly
      attr_accessor :one

      def self.from_json(o)
        woobly = Woobly.new
        woobly.one = o["one"]
        woobly
      end
    end

    it "should honor JSON gem style object creation" do 
      Mixlib::JSON.create_objects = true
      o = Mixlib::JSON.parse('{"one":"two","json_class":"Woobly"}')
      o.should be_a_kind_of(Woobly)
      o.one.should == "two"
    end
  end
end 
