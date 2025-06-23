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
    module Server
      ##
      # Prometheus instrumentor for gRPC servers
      #
      class Collector < Bigcommerce::Prometheus::Collectors::Base
        RESPONSE_CODE_OK = 'OK'
        FAILURE_CLASSES = %w[
          GRPC::Unknown
          GRPC::Internal
          GRPC::DataLoss
          GRPC::FailedPrecondition
          GRPC::Unavailable
          GRPC::DeadlineExceeded
          GRPC::Cancelled
        ].freeze

        ##
        # @param [Gruf::Controller::Request] request
        #
        def started_total(request:)
          push(
            grpc_server_started_total: 1,
            custom_labels: custom_labels(request:)
          )
        end

        ##
        # @param [Gruf::Controller::Request] request
        # @param [Gruf::Interceptors::Timer::Result] result
        #
        def failed_total(request:, result:)
          return unless failure?(result)

          push(
            grpc_server_failed_total: 1,
            custom_labels: custom_labels(request:)
          )
        end

        ##
        # @param [Gruf::Controller::Request] request
        # @param [Gruf::Interceptors::Timer::Result] result:party
        #
        def handled_total(request:, result:)
          push(
            grpc_server_handled_total: 1,
            custom_labels: custom_labels(request:, result:)
          )
        end

        ##
        # @param [Gruf::Controller::Request] request
        # @param [Gruf::Interceptors::Timer::Result] result
        #
        def handled_latency_seconds(request:, result:)
          push(
            grpc_server_handled_latency_seconds: result.elapsed.to_f,
            custom_labels: custom_labels(request:, result:)
          )
        end

        private

        ##
        # @param [Gruf::Controller::Request] request
        # @param [Gruf::Interceptors::Timer::Result|NilClass] result
        # @return [Hash]
        #
        def custom_labels(request:, result: nil)
          labels = {
            grpc_service: format_grpc_service_name(request.service.name.to_s),
            grpc_method: format_grpc_method_name(request.method_key.to_s),
            grpc_type: determine_type(request)
          }
          if result
            labels[:grpc_code] = result.successful? ? RESPONSE_CODE_OK : result.message_class_name.split('::').last
          end
          labels
        end

        ##
        # Format the service name as `path.to.Service` (from Path::To::Service)
        #
        # @param [String] name
        # @return [String]
        #
        def format_grpc_service_name(name)
          parts = name.split('::')
          return '' unless parts.any?

          svc = parts.pop.to_s
          parts.map!(&:downcase)
          parts << svc
          parts.join('.')
        end

        ##
        # Format the method name as `MethodName` (from method_name)
        #
        # @param [String] name
        # @return [String]
        #
        def format_grpc_method_name(name)
          name.split('_').map(&:capitalize).join
        end

        ##
        # @param [Gruf::Controller::Request] request
        # @return [String]
        #
        def determine_type(request)
          if request.client_streamer?
            Gruf::Prometheus::RequestTypes::CLIENT_STREAM
          elsif request.server_streamer?
            Gruf::Prometheus::RequestTypes::SERVER_STREAM
          elsif request.bidi_streamer?
            Gruf::Prometheus::RequestTypes::BIDI_STREAM
          else
            Gruf::Prometheus::RequestTypes::UNARY
          end
        end

        ##
        # @param [Gruf::Interceptors::Timer::Result] result
        # @return [Boolean]
        #
        def failure?(result)
          FAILURE_CLASSES.include?(result.message_class_name)
        end
      end
    end
  end
end
