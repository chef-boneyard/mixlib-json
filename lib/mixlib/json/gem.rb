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

module Mixlib
  class JSON
    class Gem
      class << self
        def is_loaded? 
          Object.const_defined?("JSON")
        end

        def load
          begin
            require 'json'
            self.new
          rescue LoadError
            false
          end
        end
      end

      def generate(obj)
        ::JSON.generate(obj)
      end

      def pretty(obj)
        ::JSON.pretty_generate(obj)
      end

      def parse(obj)
        ::JSON.parse(obj)
      end
    end
  end
end
  
