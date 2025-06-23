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

describe Gruf::Prometheus::Hook do
  let(:options) { {} }
  let(:hook) { described_class.new(options:) }
  let(:port) { 9_394 }
  let(:timeout) { 1 }
  let(:server) { Gruf::Server.new(port:, timeout:) }
  let(:prom_server) { instance_double(::Bigcommerce::Prometheus::Server, start: nil, add_type_collector: nil) }

  before do
    allow(hook).to receive(:prometheus_server).and_return(prom_server)
  end

  describe '.before_server_start' do
    subject { hook.before_server_start(server:) }

    it 'starts the collectors and the server' do
      expect(logger).to_not receive(:error)
      expect(::PrometheusExporter::Instrumentation::Process).to receive(:start).once
      expect(::PrometheusExporter::Instrumentation::ActiveRecord).not_to receive(:start)
      expect(::Gruf::Prometheus::Collector).to receive(:start).once
      expect(prom_server).to receive(:start).once
      subject
    end

    context 'if the server fails to start' do
      let(:exception) { StandardError.new('fail') }

      it 'logs an error and proceeds gracefully' do
        expect(logger).to receive(:error)
        expect(::PrometheusExporter::Instrumentation::Process).not_to receive(:start)
        expect(::PrometheusExporter::Instrumentation::ActiveRecord).not_to receive(:start)
        expect(::Gruf::Prometheus::Collector).to_not receive(:start)
        expect(prom_server).to receive(:start).once.and_raise(exception)
        subject
      end
    end

    context 'when active record is loaded' do
      before do
        allow(hook).to receive(:active_record_enabled?).and_return(true)
      end

      it 'starts the active record collector' do
        expect(::PrometheusExporter::Instrumentation::Process).to receive(:start)
        expect(::PrometheusExporter::Instrumentation::ActiveRecord).to receive(:start)
        expect(::Gruf::Prometheus::Collector).to receive(:start)
        expect(prom_server).to receive(:start).once
        subject
      end
    end

    context 'if custom collectors are passed' do
      let(:options) { { collectors: } }
      let(:collectors) do
        {
          CustomCollector => { type: 'custom' }
        }
      end

      it 'calls start on all of them' do
        expect(logger).to_not receive(:error)
        expect(CustomCollector).to receive(:start).once
        expect(prom_server).to receive(:start).once
        subject
      end
    end

    context 'if custom type collectors are passed' do
      let(:options) { { type_collectors: } }
      let(:custom_collector) { CustomTypeCollector.new }
      let(:type_collectors) { [custom_collector] }

      it 'should add each of them - including the defaults - to the server' do
        expect(logger).to_not receive(:error)
        expect(prom_server).to receive(:add_type_collector).with(instance_of(::Gruf::Prometheus::TypeCollector)).ordered
        expect(prom_server).to receive(:add_type_collector).with(instance_of(::Gruf::Prometheus::Server::TypeCollector)).ordered
        expect(prom_server).to receive(:add_type_collector).with(instance_of(::Gruf::Prometheus::Client::TypeCollector)).ordered
        expect(prom_server).to receive(:add_type_collector).with(instance_of(::PrometheusExporter::Server::ActiveRecordCollector)).ordered
        expect(prom_server).to receive(:add_type_collector).with(custom_collector).ordered
        expect(prom_server).to receive(:start).once
        subject
      end
    end
  end

  describe '.after_server_stop' do
    subject { hook.after_server_stop(server:) }

    it 'should stop the server' do
      expect(prom_server).to receive(:stop).once
      subject
    end

    context 'if the server fails to stop' do
      let(:exception) { StandardError.new('fail') }

      it 'should log and error and proceed gracefully' do
        expect(logger).to receive(:error)
        expect(prom_server).to receive(:stop).once.and_raise(exception)
        subject
      end
    end
  end
end
