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

describe Gruf::Prometheus::Client::TypeCollector do
  let(:type_collector) { described_class.new }
  let(:measure_latency) { false }

  before do
    allow(Gruf::Prometheus).to receive(:client_measure_latency).and_return(measure_latency)
  end

  describe '#type' do
    subject { type_collector.type }

    it 'returns grpc_client' do
      expect(subject).to eq 'grpc_client'
    end
  end

  describe '.build_metrics' do
    subject { type_collector.send(:build_metrics) }

    it 'returns the grpc_client_started_total metric' do
      expect(subject).to be_a(Hash)
      expect(subject[:grpc_client_started_total].name).to eq 'grpc_client_started_total'
      expect(subject[:grpc_client_started_total].type).to eq 'counter'
      expect(subject[:grpc_client_started_total].class).to eq PrometheusExporter::Metric::Counter
    end

    it 'returns the grpc_client_completed metric' do
      expect(subject).to be_a(Hash)
      expect(subject[:grpc_client_completed].name).to eq 'grpc_client_completed'
      expect(subject[:grpc_client_completed].type).to eq 'counter'
      expect(subject[:grpc_client_completed].class).to eq PrometheusExporter::Metric::Counter
    end

    context 'when measuring latency is on' do
      let(:measure_latency) { true }

      it 'adds the latency histogram' do
        expect(subject).to be_a(Hash)
        expect(subject[:grpc_client_completed_latency_seconds].name).to eq 'grpc_client_completed_latency_seconds'
        expect(subject[:grpc_client_completed_latency_seconds].type).to eq 'histogram'
        expect(subject[:grpc_client_completed_latency_seconds].class).to eq PrometheusExporter::Metric::Histogram
      end
    end

    context 'when measuring latency is off' do
      it 'does not add the latency histogram' do
        expect(subject).to be_a(Hash)
        expect(subject).to_not have_key(:grpc_client_completed_latency_seconds)
      end
    end
  end

  describe '.collect_metrics' do
    let(:obj) do
      {
        'environment' => 'development',
        'custom_labels' => { 'foo' => 'bar' },
        'grpc_client_started_total' => 1,
        'grpc_client_completed' => 1,
      }
    end

    subject { type_collector.send(:collect_metrics, data: obj) }

    it 'aggregates the values into metrics' do
      subject
      metrics = type_collector.metrics
      expect(metrics[0].data.values.first).to eq 1 # 'grpc_client_started_total'
      expect(metrics[1].data.values.first).to eq 1 # 'grpc_client_completed'
    end

    context 'when measuring latency is on' do
      let(:measure_latency) { true }
      let(:obj) { super().merge('grpc_client_completed_latency_seconds' => 20.2) }

      it 'adds the latency histogram' do
        subject
        metrics = type_collector.metrics
        expect(metrics[0].data.values.first).to eq 1 # 'grpc_client_started_total'
        expect(metrics[1].data.values.first).to eq 1 # 'grpc_client_completed'
        expect(metrics[2].to_h.first.last).to eq('count' => 1, 'sum' => 20.2) # 'grpc_client_completed_latency_seconds'
      end
    end
  end
end
