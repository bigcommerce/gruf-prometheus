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

describe Gruf::Prometheus::Collector do
  let(:pool) { TestGrpcPool.new }
  let(:client) { double(:client, send_json: true) }
  let(:pool) { TestGrpcPool.new }
  let(:server) { TestGrufServer.new(pool: pool) }
  let(:frequency) { 1 }
  let(:collector) { described_class.new(client: client, frequency: frequency, options: { server: server }, type: 'grpc') }

  describe '#start' do
    subject { described_class.start(client: client, frequency: 1, options: { server: server }) }

    it 'should start a new thread in a loop, running the collector' do
      expect_any_instance_of(described_class).to receive(:run).at_least(:once)
      thread = subject
      sleep 0.5
      thread.kill
    end
  end

  describe '.run' do
    let(:metric) { { type: 'grpc' } }

    subject { collector.run }

    context 'if the metrics properly collect' do
      before do
        allow(collector).to receive(:collect).and_return(metric)
      end

      it 'should send through the client' do
        expect(client).to receive(:send_json).with(metric).once
        expect(collector).to receive(:sleep).with(frequency).once
        subject
      end
    end

    context 'if the metrics fail to send' do
      let(:exception) { StandardError.new('fail') }

      before do
        expect(client).to receive(:send_json).and_raise(exception)
      end

      it 'should go back into the loop' do
        expect(collector).to receive(:sleep).with(frequency).once
        subject
      end
    end
  end

  describe '.collect' do
    subject { collector.send(:collect) }

    it 'should return collected metrics' do
      expect(subject).to be_a(Hash)
      expect(subject[:type]).to eq 'grpc'
      expect(subject[:pool_jobs_waiting_total]).to eq pool.jobs_waiting
      expect(subject[:pool_ready_workers_total]).to eq pool.ready_workers.count
      expect(subject[:pool_workers_total]).to eq pool.workers.count
      expect(subject[:pool_initial_size]).to eq pool.pool_size
      expect(subject[:poll_period]).to eq pool.poll_period
    end
  end
end
