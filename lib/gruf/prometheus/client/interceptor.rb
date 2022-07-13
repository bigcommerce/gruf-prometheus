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
      # Server interceptor for measuring counter/timers for gRPC inbound requests
      #
      class Interceptor < ::Gruf::Interceptors::ClientInterceptor
        ##
        # Intercept the call and send metrics
        #
        def call(request_context:, &block)
          result = ::Gruf::Interceptors::Timer.time(&block)

          send_metrics(request_context: request_context, result: result)

          raise result.message unless result.successful?

          result.message
        end

        private

        ##
        # @param [Gruf::Outbound::RequestContext] request_context
        # @param [Gruf::Interceptors::Timer::Result] result
        #
        def send_metrics(request_context:, result:)
          prometheus_collector.started_total(request_context: request_context)
          prometheus_collector.failed_total(request_context: request_context, result: result) unless result.successful?
          prometheus_collector.completed(request_context: request_context, result: result)
          prometheus_collector.completed_latency_seconds(request_context: request_context, result: result) if measure_latency?
        rescue StandardError => e
          # we don't want this to affect actual RPC execution, so just log an error and move on
          Gruf.logger.error "Failed registering metric to prometheus type collector: #{e.message} - #{e.class.name}"
        end

        ##
        # @return [::Gruf::Prometheus::Client::Collector]
        #
        def prometheus_collector
          @prometheus_collector ||= ::Gruf::Prometheus::Client::Collector.new(type: 'grpc_client')
        end

        ##
        # @return [Boolean]
        #
        def measure_latency?
          @measure_latency ||= @options.fetch(:measure_latency, ::Gruf::Prometheus.client_measure_latency)
        end
      end
    end
  end
end
