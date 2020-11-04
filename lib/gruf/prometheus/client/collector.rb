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
module Gruf
  module Prometheus
    module Client
      ##
      # Prometheus instrumentor for gRPC clients
      #
      class Collector < Bigcommerce::Prometheus::Collectors::Base
        RESPONSE_CODE_OK = 'OK'

        ##
        # @param [Gruf::Outbound::RequestContext] request_context
        #
        def started_total(request_context:)
          push(
            grpc_client_started_total: 1,
            custom_labels: custom_labels(request_context: request_context)
          )
        end

        ##
        # @param [Gruf::Controller::RequestContext] request_context
        # @param [Gruf::Interceptors::Timer::Result] result
        #
        def completed(request_context:, result:)
          push(
            grpc_client_completed: 1,
            custom_labels: custom_labels(request_context: request_context, result: result)
          )
        end

        ##
        # @param [Gruf::Outbound::RequestContext] request_context
        # @param [Gruf::Interceptors::Timer::Result] result
        #
        def completed_latency_seconds(request_context:, result:)
          push(
            grpc_client_completed_latency_seconds: result.elapsed.to_f,
            custom_labels: custom_labels(request_context: request_context, result: result)
          )
        end

        private

        ##
        # @param [Gruf::Outbound::RequestContext] request_context
        # @param [Gruf::Interceptors::Timer::Result|NilClass] result
        # @return [Hash]
        #
        def custom_labels(request_context:, result: nil)
          labels = {
            grpc_service: format_service_name(request_context.method.to_s),
            grpc_method: request_context.method_name,
            grpc_type: determine_type(request_context)
          }
          if result
            labels[:grpc_code] = result.successful? ? RESPONSE_CODE_OK : result.message_class_name.split('::').last
          end
          labels
        end

        ##
        # Format the service name as `path.to.Service` (from `/path.to.Service/MethodName`)
        #
        # @param [String] name
        # @return [String]
        #
        def format_service_name(name)
          name.split('/').reject(&:empty?).first
        end

        ##
        # @param [Gruf::Outbound::RequestContext] request_context
        # @return [String]
        #
        def determine_type(request_context)
          case request_context.type.to_sym
          when :client_streamer
            Gruf::Prometheus::RequestTypes::CLIENT_STREAM
          when :server_streamer
            Gruf::Prometheus::RequestTypes::SERVER_STREAM
          when :bidi_streamer
            Gruf::Prometheus::RequestTypes::BIDI_STREAM
          else
            Gruf::Prometheus::RequestTypes::UNARY
          end
        end
      end
    end
  end
end
