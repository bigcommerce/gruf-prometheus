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

describe Gruf::Prometheus::Server do
  let(:port) { 9000 }
  let(:timeout) { 1 }
  let(:prefix) { 'grpc' }
  let(:verbose) { false }
  
  let(:server) { described_class.new(port: port, timeout: timeout, prefix: prefix, verbose: verbose, server_class: TestServerClass) }
  
  describe '.start' do
    subject { server.start }

    it 'should start the server' do
      expect(server.send(:server)).to receive(:start).once
      subject
      expect(server).to be_running
    end

    context 'if it fails to start' do
      let(:exception) { StandardError.new('fail') }

      it 'should log an error' do
        expect(server).to_not be_running
        expect(logger).to receive(:error).once
        expect(server.send(:server)).to receive(:start).once.and_raise(exception)
        subject
        expect(server).to_not be_running
      end
    end
  end
end
