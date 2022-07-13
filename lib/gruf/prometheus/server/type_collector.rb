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
      # Type Collector for grpc server metrics
      #
      class TypeCollector < Bigcommerce::Prometheus::TypeCollectors::Base
        def type
          'grpc_server'
        end

        private

        ##
        # Initialize the collector
        #
        def build_metrics
          metrics = {
            grpc_server_started_total: PrometheusExporter::Metric::Counter.new('grpc_server_started_total', 'Total number of RPCs started on the server'),
            grpc_server_failed_total: PrometheusExporter::Metric::Counter.new('grpc_server_failed_total', 'Total number of RPCs failed on the server'),
            grpc_server_handled_total: PrometheusExporter::Metric::Counter.new('grpc_server_handled_total', 'Total number of RPCs completed on the server, regardless of success or failure')
          }
          metrics[:grpc_server_handled_latency_seconds] = PrometheusExporter::Metric::Histogram.new('grpc_server_handled_latency_seconds', 'Histogram of response latency of RPCs handled by the server, in seconds') if measure_latency?
          metrics
        end

        ##
        # Collect the object into the buffer
        #
        def collect_metrics(data: {}, labels: {})
          metric(:grpc_server_started_total)&.observe(data['grpc_server_started_total'].to_i, labels)
          metric(:grpc_server_failed_total)&.observe(data['grpc_server_failed_total'].to_i, labels)
          metric(:grpc_server_handled_total)&.observe(data['grpc_server_handled_total'].to_i, labels)
          metric(:grpc_server_handled_latency_seconds)&.observe(data['grpc_server_handled_latency_seconds'].to_f, labels) if measure_latency?
        end

        ##
        # @return [Boolean]
        #
        def measure_latency?
          @measure_latency ||= ::Gruf::Prometheus.server_measure_latency
        end
      end
    end
  end
end
