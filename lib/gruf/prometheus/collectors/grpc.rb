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
    module Collectors
      ##
      # Collector for prometheus and grpc instrumentation
      #
      class Grpc < PrometheusExporter::Server::TypeCollector
        GRPC_GAUGES = {
          pool_jobs_waiting_total: 'Number jobs in the gRPC thread pool that are actively waiting',
          pool_ready_workers_total: 'The amount of non-busy workers in the thread pool',
          pool_workers_total: 'Number of workers in the gRPC thread pool',
          pool_initial_size: 'Initial size of the gRPC thread pool',
          poll_period: 'Polling period for the gRPC thread pool'
        }.freeze

        GRPC_COUNTS = {
          thread_pool_exhausted: 'Times the gRPC thread pool has been exhausted'
        }.freeze

        ##
        # Initialize the collector
        #
        def initialize
          @grpc_metrics = []
        end

        ##
        # @return [String]
        #
        def type
          'grpc'
        end

        ##
        # Collect the object into the buffer
        #
        def collect(obj)
          @grpc_metrics << obj
        end

        ##
        # @return [Array]
        #
        def metrics
          return [] if @grpc_metrics.none?

          metrics = {}

          @grpc_metrics.map do |m|
            labels = {}
            labels.merge!(m['custom_labels']) if m['custom_labels']

            GRPC_GAUGES.map do |k, help|
              k = k.to_s
              v = m[k]
              if v
                g = metrics[k] ||= PrometheusExporter::Metric::Gauge.new("grpc_#{k}", help)
                g.observe(v, labels)
              end
            end

            GRPC_COUNTS.map do |k, help|
              k = k.to_s
              v = m[k]
              if v
                g = metrics[k] ||= PrometheusExporter::Metric::Counter.new("grpc_#{k}", help)
                g.observe(v, labels)
              end
            end
          end

          metrics.values
        end
      end
    end
  end
end
