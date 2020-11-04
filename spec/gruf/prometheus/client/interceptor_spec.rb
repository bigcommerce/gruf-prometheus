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

describe Gruf::Prometheus::Client::Interceptor do
  let(:interceptor) { described_class.new(measure_latency: measure_latency) }
  let(:measure_latency) { false }
  let(:grpc_method_name) { '/gruf.demo.Things/get_thing' }
  let(:grpc_type) { :request_response }
  let(:grpc_requests) { [double(:grpc_message)] }
  let(:grpc_method) { instance_double(Method, to_s: '/gruf.demo.Things/GetThing') }
  let(:grpc_metadata) { {} }
  let(:collector) { interceptor.send(:prometheus_collector) }
  let(:result) { true }

  let(:request_context) do
    Gruf::Outbound::RequestContext.new(
      type: grpc_type,
      requests: grpc_requests,
      call: double(:active_call),
      method: grpc_method,
      metadata: grpc_metadata
    )
  end

  describe '#call' do
    subject { interceptor.call(request_context: request_context) { result } }

    it 'sends the started_total metric to the collector' do
      expect(collector).to receive(:started_total).with(request_context: request_context).once
      subject
    end

    it 'sends the completed metric to the collector with the result' do
      expect(collector).to receive(:completed).with(request_context: request_context, result: instance_of(Gruf::Interceptors::Timer::Result)).once
      subject
    end

    context 'when the latency histogram' do
      context 'is enabled' do
        let(:measure_latency) { true }

        it 'sends the completed_latency_seconds metric to the collector with the result' do
          expect(collector).to receive(:completed_latency_seconds).with(request_context: request_context, result: instance_of(Gruf::Interceptors::Timer::Result)).once
          subject
        end
      end

      context 'is disabled' do
        let(:measure_latency) { false }

        it 'does not sends the completed_latency_seconds metric' do
          expect(collector).not_to receive(:completed_latency_seconds)
          subject
        end
      end
    end

    context 'when the result raises an exception' do
      subject { interceptor.call(request_context: request_context) { raise exception } }

      let(:exception) { GRPC::Internal.new('test') }

      it 'still sends metrics and re-raises the exception' do
        expect(collector).to receive(:started_total).once
        expect(collector).to receive(:completed).once
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
