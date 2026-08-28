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

describe Gruf::Prometheus::Client do
  describe '.type_collector' do
    subject(:type_collector) { described_class.type_collector }

    it 'returns a Gruf::Prometheus::Client::TypeCollector' do
      expect(type_collector).to be_a(Gruf::Prometheus::Client::TypeCollector)
    end

    it 'returns a new instance on every call' do
      expect(described_class.type_collector).to_not equal(described_class.type_collector)
    end

    context 'when client_measure_latency is enabled before the type collector is built' do
      before do
        allow(Gruf::Prometheus).to receive(:client_measure_latency).and_return(true)
      end

      it 'includes the latency histogram metric' do
        expect(type_collector.metrics.map(&:name)).to include('grpc_client_completed_latency_seconds')
      end
    end

    context 'when client_measure_latency is enabled after the type collector is built' do
      it 'does not include the latency histogram metric' do
        built = type_collector
        allow(Gruf::Prometheus).to receive(:client_measure_latency).and_return(true)

        expect(built.metrics.map(&:name)).to_not include('grpc_client_completed_latency_seconds')
      end
    end
  end
end
