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
  let(:hook) { described_class.new(options: options) }
  let(:port) { 9_394 }
  let(:timeout) { 1 }
  let(:server) { Gruf::Server.new(port: port, timeout: timeout) }
  let(:prom_server) { hook.send(:prometheus_server) }

  describe '.before_server_start' do
    subject { hook.before_server_start(server: server) }

    it 'should start the collectors and the server' do
      expect(logger).to_not receive(:error)
      expect(::PrometheusExporter::Instrumentation::Process).to receive(:start).once
      expect(::Gruf::Prometheus::Collector).to receive(:start).once
      expect(prom_server).to receive(:start).once
      subject
    end

    context 'if the server fails to start' do
      let(:exception) { StandardError.new('fail') }

      it 'should log and error and proceed gracefully' do
        expect(logger).to receive(:error)
        expect(::PrometheusExporter::Instrumentation::Process).to_not receive(:start)
        expect(::Gruf::Prometheus::Collector).to_not receive(:start)
        expect(prom_server).to receive(:start).once.and_raise(exception)
        subject
      end
    end
  end

  describe '.after_server_stop' do
    subject { hook.after_server_stop(server: server) }

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
