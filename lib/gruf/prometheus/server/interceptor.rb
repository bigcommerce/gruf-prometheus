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
      # Server interceptor for measuring counter/timers for gRPC inbound requests
      #
      class Interceptor < ::Gruf::Interceptors::ServerInterceptor
        ##
        # Intercept the call and send metrics
        #
        def call(&block)
          result = ::Gruf::Interceptors::Timer.time(&block)

          send_metrics(result)

          raise result.message unless result.successful?

          result.message
        end

        private

        ##
        # @param [Gruf::Interceptors::Timer::Result] result
        #
        def send_metrics(result)
          prometheus_collector.started_total(request: request)
          prometheus_collector.failed_total(request: request, result: result) if !result.successful?
          prometheus_collector.handled_total(request: request, result: result)
          prometheus_collector.handled_latency_seconds(request: request, result: result) if measure_latency?
        rescue StandardError => e
          # we don't want this to affect actual RPC execution, so just log an error and move on
          Gruf.logger.error "Failed registering metric to prometheus type collector: #{e.message} - #{e.class.name}"
        end

        ##
        # @return [::Gruf::Prometheus::Server::Collector]
        #
        def prometheus_collector
          @prometheus_collector ||= ::Gruf::Prometheus::Server::Collector.new(type: 'grpc_server')
        end

        ##
        # @return [Boolean]
        #
        def measure_latency?
          unless @measure_latency
            v = @options.fetch(:measure_latency, ::Gruf::Prometheus.server_measure_latency)
            @measure_latency = v.nil? ? false : v
          end
          @measure_latency
        end
      end
    end
  end
end
