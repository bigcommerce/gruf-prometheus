# frozen_string_literal: true

# Copyright (c) 2019-present, BigCommerce Pty. Ltd. All rights reserved
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
# Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
# WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("ThingService.proto", :syntax => :proto3) do
    add_message "gruf.demo.Thing" do
      optional :id, :uint32, 1
      optional :name, :string, 2
    end
    add_message "gruf.demo.GetThingRequest" do
      optional :id, :uint32, 1
      optional :sleep, :uint32, 2
    end
    add_message "gruf.demo.GetThingResponse" do
      optional :thing, :message, 1, "gruf.demo.Thing"
    end
    add_message "gruf.demo.GetThingsRequest" do
      optional :search, :string, 1
      optional :limit, :uint32, 2
    end
    add_message "gruf.demo.CreateThingsResponse" do
      repeated :things, :message, 1, "gruf.demo.Thing"
    end
  end
end

module Gruf
  module Demo
    Thing = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("gruf.demo.Thing").msgclass
    GetThingRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("gruf.demo.GetThingRequest").msgclass
    GetThingResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("gruf.demo.GetThingResponse").msgclass
    GetThingsRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("gruf.demo.GetThingsRequest").msgclass
    CreateThingsResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("gruf.demo.CreateThingsResponse").msgclass
  end
end
