# frozen_string_literal: true
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: ThingService.proto

require 'google/protobuf'


descriptor_data = "\n\x12ThingService.proto\x12\tgruf.demo\"!\n\x05Thing\x12\n\n\x02id\x18\x01 \x01(\r\x12\x0c\n\x04name\x18\x02 \x01(\t\",\n\x0fGetThingRequest\x12\n\n\x02id\x18\x01 \x01(\r\x12\r\n\x05sleep\x18\x02 \x01(\r\"3\n\x10GetThingResponse\x12\x1f\n\x05thing\x18\x01 \x01(\x0b\x32\x10.gruf.demo.Thing\"1\n\x10GetThingsRequest\x12\x0e\n\x06search\x18\x01 \x01(\t\x12\r\n\x05limit\x18\x02 \x01(\r\"8\n\x14\x43reateThingsResponse\x12 \n\x06things\x18\x01 \x03(\x0b\x32\x10.gruf.demo.Thing2\x9e\x02\n\x0cThingService\x12\x45\n\x08GetThing\x12\x1a.gruf.demo.GetThingRequest\x1a\x1b.gruf.demo.GetThingResponse\"\x00\x12>\n\tGetThings\x12\x1b.gruf.demo.GetThingsRequest\x1a\x10.gruf.demo.Thing\"\x00\x30\x01\x12\x45\n\x0c\x43reateThings\x12\x10.gruf.demo.Thing\x1a\x1f.gruf.demo.CreateThingsResponse\"\x00(\x01\x12@\n\x14\x43reateThingsInStream\x12\x10.gruf.demo.Thing\x1a\x10.gruf.demo.Thing\"\x00(\x01\x30\x01\x62\x06proto3"

pool = ::Google::Protobuf::DescriptorPool.generated_pool
pool.add_serialized_file(descriptor_data)

module Gruf
  module Demo
    Thing = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("gruf.demo.Thing").msgclass
    GetThingRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("gruf.demo.GetThingRequest").msgclass
    GetThingResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("gruf.demo.GetThingResponse").msgclass
    GetThingsRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("gruf.demo.GetThingsRequest").msgclass
    CreateThingsResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("gruf.demo.CreateThingsResponse").msgclass
  end
end
