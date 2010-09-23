#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2010 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'mixlib/json/yajl'
require 'mixlib/json/gem'
require 'mixlib/json/activesupport'

module Mixlib
  class JSON
    class << self
      attr_reader :json_obj

      # If you want to force JSON gem style automatic object creation, set this to true. 
      #
      # This means if your JSON has a json_class key with
      # a valid class, and that class responds to
      # from_json, it will have that method called with
      # the JSON object as it's argument.  
      #
      # @param [Boolean] Whether to create objects
      def create_objects=(boolean)
        @create_objects = boolean
      end

      def create_objects
        @create_objects ||= false
      end

      # Set the order in which you prefer your serializers
      # to be used, if none is already loaded.  Should be
      # class names that are children of Mixlib::JSON.
      #
      # Defaults to YAJL, JSON Gem, and ActiveSupport.
      #
      # @param [Array] An array of classes to use.
      def json_load_order=(load_order)
        @json_load_order = load_order
      end

      def json_load_order
        @json_load_order ||= [ 
          Mixlib::JSON::YAJL,
          Mixlib::JSON::Gem,
          Mixlib::JSON::ActiveSupport
        ]
      end

      # Checks to see if a JSON library is already loaded
      # - if it is, we'll use it for serialization.
      #
      # @return [Boolean] true if we loaded a library, false otherwise.
      def detect_loaded_library
        json_library_class = json_load_order.detect { |lib| lib.is_loaded? }
        if json_library_class
          @json_obj = json_library_class.new
          true
        else
          false
        end
      end

      # First detects if a JSON library is already loaded, and if it is, uses it.
      #
      # If it isn't, uses the json_load_order to select
      # the best available library.
      #
      # @return [Mixlib::JSON::*] An appropriate JSON serialization object.
      # @raises [ArgumentError] If a library cannot be loaded.
      def select_json_library
        unless detect_loaded_library
          json_load_order.each do |lib|
            @json_obj = lib.load
            break if @json_obj
          end
        end
        raise ArgumentError, "Cannot load a json library!" unless @json_obj
        @json_obj
      end

      # Generates JSON.
      #
      # @param [Object] Generates JSON for this object.
      # @return [JSON] Returns a JSON string. 
      def generate(obj)
        select_json_library unless @json_obj
        @json_obj.generate(obj)
      end

      # Pretty generates JSON.
      #
      # @param [Object] Generates pretty JSON for this object.
      # @return [JSON] Returns a JSON string. 
      def pretty(obj)
        select_json_library unless @json_obj
        @json_obj.pretty(obj)
      end
     
      # Creates a Ruby object from a JSON string. If
      # create_objects is true, might return a
      # fully-inflated object of the class specified in
      # json_class.
      #
      # @param [String] A JSON string.
      # @return [Object] A ruby object.
      def parse(data)
        select_json_library unless @json_obj
        o = @json_obj.parse(data)
        if @create_objects && o.kind_of?(Hash) 
          if o.has_key?("json_class")
            class_name = o["json_class"].split('::').inject(Kernel) do |scope, const_name| 
              scope.const_get(const_name)
            end
            if class_name.respond_to?(:from_json)
              return class_name.from_json(o)
            else
              return o
            end
          end
        else
          return o
        end
      end
    end
  end
end
