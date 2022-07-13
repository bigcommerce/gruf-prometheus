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
require 'spec_helper'

describe Gruf::Prometheus::Server::Interceptor do
  let(:interceptor) { described_class.new(gruf_request, gruf_error, measure_latency: measure_latency) }
  let(:measure_latency) { false }
  let(:grpc_method_name) { '/gruf.demo.Things/get_thing' }
  let(:grpc_type) { :request_response }
  let(:grpc_requests) { [double(:grpc_message)] }
  let(:grpc_method) { instance_double(Method, to_s: '/gruf.demo.Things/GetThing') }
  let(:grpc_metadata) { {} }
  let(:collector) { interceptor.send(:prometheus_collector) }
  let(:result) { grpc_message }
  let(:grpc_service) { double(Class, name: 'Gruf::Demo::Things') }
  let(:gruf_error) { instance_double(Gruf::Error) }
  let(:grpc_message) { Class.new }
  let(:gruf_request) do
    Gruf::Controllers::Request.new(method_key: grpc_method_name, service: grpc_service, rpc_desc: nil, active_call: nil, message: grpc_message)
  end

  describe '#call' do
    subject { interceptor.call { result } }

    it 'sends metrics to the collector' do
      expect(collector).to receive(:started_total).with(request: gruf_request).once
      expect(collector).to receive(:handled_total).with(request: gruf_request, result: instance_of(Gruf::Interceptors::Timer::Result)).once
      subject
    end

    context 'when the latency histogram is enabled' do
      let(:measure_latency) { true }

      it 'sends the handled_latency_seconds metric to the collector with the result' do
        expect(collector).to receive(:started_total).with(request: gruf_request).once
        expect(collector).to receive(:handled_total).with(request: gruf_request, result: instance_of(Gruf::Interceptors::Timer::Result)).once
        expect(collector).to receive(:handled_latency_seconds).with(request: gruf_request, result: instance_of(Gruf::Interceptors::Timer::Result)).once
        subject
      end
    end

    context 'when the result raises an exception' do
      subject { interceptor.call { raise exception } }

      let(:exception) { GRPC::Internal.new('test') }

      it 'still sends metrics and re-raises the exception' do
        expect(collector).to receive(:started_total).once
        expect(collector).to receive(:failed_total).once
        expect(collector).to receive(:handled_total).once
        expect { subject }.to raise_error(exception)
      end
    end

    context 'when the collector raises an exception when sending the metrics' do
      let(:exception) { StandardError.new('fail') }

      it 'logs an error and no-ops' do
        expect(collector).to receive(:started_total).once.and_raise(exception)
        expect(Gruf.logger).to receive(:error).with("Failed registering metric to prometheus type collector: #{exception.message} - #{exception.class.name}")
        expect(subject).to eq result
      end
    end
  end
end
