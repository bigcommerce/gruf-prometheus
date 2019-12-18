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

describe Gruf::Prometheus::TypeCollector do
  let(:type_collector) { described_class.new }

  describe '.type' do
    subject { type_collector.type }

    it 'should return grpc' do
      expect(subject).to eq 'grpc'
    end
  end

  describe '.build_metrics' do
    subject { type_collector.send(:build_metrics) }

    it 'should return all metrics as an array' do
      expect(subject).to be_a(Hash)
      expect(subject[:pool_jobs_waiting_total].name).to eq 'grpc_pool_jobs_waiting_total'
      expect(subject[:pool_ready_workers_total].name).to eq 'grpc_pool_ready_workers_total'
      expect(subject[:pool_workers_total].name).to eq 'grpc_pool_workers_total'
      expect(subject[:pool_initial_size].name).to eq 'grpc_pool_initial_size'
      expect(subject[:poll_period].name).to eq 'grpc_poll_period'
      expect(subject[:thread_pool_exhausted].name).to eq 'grpc_thread_pool_exhausted'
    end
  end

  describe '.collect_metrics' do
    let(:obj) do
      {
        'environment' => 'development',
        'custom_labels' => { 'foo' => 'bar' },
        'pool_jobs_waiting_total' => 0,
        'pool_ready_workers_total' => 30,
        'pool_workers_total' => 30,
        'pool_initial_size' => 30,
        'poll_period' => 15,
        'thread_pool_exhausted' => 2,
      }
    end

    subject { type_collector.send(:collect_metrics, data: obj) }

    it 'should aggregate the values into the metrics' do
      subject

      metrics = type_collector.metrics
      expect(metrics[0].data.values.first).to eq 0 # 'grpc_pool_jobs_waiting_total'
      expect(metrics[1].data.values.first).to eq 30 # 'grpc_pool_ready_workers_total'
      expect(metrics[2].data.values.first).to eq 30 # 'grpc_pool_workers_total'
      expect(metrics[3].data.values.first).to eq 30 # 'grpc_pool_initial_size'
      expect(metrics[4].data.values.first).to eq 15 # 'grpc_poll_period'
      expect(metrics[5].data.values.first).to eq 2 # 'grpc_thread_pool_exhausted'
    end
  end
end
