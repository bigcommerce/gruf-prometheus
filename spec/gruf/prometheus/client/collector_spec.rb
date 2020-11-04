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

describe Gruf::Prometheus::Client::Collector do
  let(:client) { instance_double(Bigcommerce::Prometheus::Client, send_json: true) }
  let(:collector_options) { {} }
  let(:collector) { described_class.new(client: client, options: collector_options, type: 'grpc_client') }

  let(:grpc_type) { :request_response }
  let(:grpc_requests) { [double(:grpc_message)] }
  let(:grpc_method) { instance_double(Method, to_s: '/gruf.demo.Things/GetThing') }
  let(:grpc_metadata) { {} }

  let(:request_context) do
    Gruf::Outbound::RequestContext.new(
      type: grpc_type,
      requests: grpc_requests,
      call: double(:active_call),
      method: grpc_method,
      metadata: grpc_metadata
    )
  end
  let(:timed_result) { Gruf::Interceptors::Timer::Result.new(true, 2.0, true) }

  describe '#started_total' do
    subject { collector.started_total(request_context: request_context) }

    it 'pushes the grpc_client_started_total to the server' do
      expect(collector).to receive(:push).with(
        grpc_client_started_total: 1,
        custom_labels: {
          grpc_method: 'GetThing',
          grpc_service: 'gruf.demo.Things',
          grpc_type: 'UNARY'
        }
      )
      subject
    end
  end

  describe '#handled_total' do
    subject { collector.completed(request_context: request_context, result: timed_result) }

    it 'pushes the grpc_client_completed to the server' do
      expect(collector).to receive(:push).with(
          grpc_client_completed: 1,
          custom_labels: {
            grpc_method: 'GetThing',
            grpc_service: 'gruf.demo.Things',
            grpc_type: 'UNARY',
            grpc_code: 'OK'
          }
      )
      subject
    end

    context 'when the request is unsuccessful' do
      let(:result) { GRPC::Internal.new('fail') }
      let(:timed_result) { Gruf::Interceptors::Timer::Result.new(result, 2.0, false) }

      it 'pushes the grpc_client_completed to the server with an unsuccessful code' do
        expect(collector).to receive(:push).with(
          grpc_client_completed: 1,
          custom_labels: {
            grpc_method: 'GetThing',
            grpc_service: 'gruf.demo.Things',
            grpc_type: 'UNARY',
            grpc_code: 'Internal'
          }
        )
        subject
      end
    end
  end

  describe '#handled_latency_seconds' do
    subject { collector.completed_latency_seconds(request_context: request_context, result: timed_result) }

    it 'pushes the grpc_client_completed_latency_seconds to the server' do
      expect(collector).to receive(:push).with(
        grpc_client_completed_latency_seconds: 2.0,
        custom_labels: {
          grpc_method: 'GetThing',
          grpc_service: 'gruf.demo.Things',
          grpc_type: 'UNARY',
          grpc_code: 'OK'
        }
      )
      subject
    end

    context 'when the request is unsuccessful' do
      let(:result) { GRPC::Internal.new('fail') }
      let(:timed_result) { Gruf::Interceptors::Timer::Result.new(result, 2.0, false) }

      it 'pushes the grpc_client_completed_latency_seconds to the server with an unsuccessful code' do
        expect(collector).to receive(:push).with(
          grpc_client_completed_latency_seconds: 2.0,
          custom_labels: {
            grpc_method: 'GetThing',
            grpc_service: 'gruf.demo.Things',
            grpc_type: 'UNARY',
            grpc_code: 'Internal'
          }
        )
        subject
      end
    end
  end

  describe '.custom_labels' do
    subject { collector.started_total(request_context: request_context) }

    context 'when the service is a top-level service' do
      let(:grpc_method) { '/Things/GetThing' }

      it 'sets the appropriate grpc_service name' do
        expect(collector).to receive(:push).with(
          grpc_client_started_total: 1,
          custom_labels: {
            grpc_method: 'GetThing',
            grpc_service: 'Things',
            grpc_type: 'UNARY'
          }
        )
        subject
      end
    end

    context 'with different request types' do
      context 'when a :request_response type of request' do
        let(:grpc_method) { '/gruf.demo.Things/GetThing' }
        let(:grpc_type) { :request_response }

        it 'sets the grpc_type to UNARY' do
          expect(collector).to receive(:push).with(
            grpc_client_started_total: 1,
            custom_labels: {
              grpc_method: 'GetThing',
              grpc_service: 'gruf.demo.Things',
              grpc_type: 'UNARY'
            }
          )
          subject
        end
      end

      context 'when a :client_streamer type of request' do
        let(:grpc_method) { '/gruf.demo.Things/CreateThings' }
        let(:grpc_type) { :client_streamer }

        it 'sets the grpc_type to CLIENT_STREAM' do
          expect(collector).to receive(:push).with(
            grpc_client_started_total: 1,
            custom_labels: {
              grpc_method: 'CreateThings',
              grpc_service: 'gruf.demo.Things',
              grpc_type: 'CLIENT_STREAM'
            }
          )
          subject
        end
      end

      context 'when a :server_streamer type of request' do
        let(:grpc_method) { '/gruf.demo.Things/GetThings' }
        let(:grpc_type) { :server_streamer }

        it 'sets the grpc_type to SERVER_STREAM' do
          expect(collector).to receive(:push).with(
            grpc_client_started_total: 1,
            custom_labels: {
              grpc_method: 'GetThings',
              grpc_service: 'gruf.demo.Things',
              grpc_type: 'SERVER_STREAM'
            }
          )
          subject
        end
      end

      context 'when a :bidi_streamer type of request' do
        let(:grpc_method) { '/gruf.demo.Things/CreateThingsInStream' }
        let(:grpc_type) { :bidi_streamer }

        it 'sets the grpc_type to BIDI_STREAM' do
          expect(collector).to receive(:push).with(
            grpc_client_started_total: 1,
            custom_labels: {
              grpc_method: 'CreateThingsInStream',
              grpc_service: 'gruf.demo.Things',
              grpc_type: 'BIDI_STREAM'
            }
          )
          subject
        end
      end
    end
  end
end
