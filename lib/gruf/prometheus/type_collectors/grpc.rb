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
    module TypeCollectors
      ##
      # Type Collector for prometheus and grpc instrumentation
      #
      class Grpc < PrometheusExporter::Server::TypeCollector
        ##
        # Initialize the collector
        #
        def initialize
          @pool_jobs_waiting_total = PrometheusExporter::Metric::Gauge.new('grpc_pool_jobs_waiting_total', 'Number jobs in the gRPC thread pool that are actively waiting')
          @pool_ready_workers_total = PrometheusExporter::Metric::Gauge.new('grpc_pool_ready_workers_total', 'The amount of non-busy workers in the thread pool')
          @pool_workers_total = PrometheusExporter::Metric::Gauge.new('grpc_pool_workers_total', 'Number of workers in the gRPC thread pool')
          @pool_initial_size = PrometheusExporter::Metric::Gauge.new('grpc_pool_initial_size', 'Initial size of the gRPC thread pool')
          @poll_period = PrometheusExporter::Metric::Gauge.new('grpc_poll_period', 'Polling period for the gRPC thread pool')
          @thread_pool_exhausted = PrometheusExporter::Metric::Counter.new('grpc_thread_pool_exhausted', 'Times the gRPC thread pool has been exhausted')
        end

        ##
        # @return [String]
        #
        def type
          'grpc'
        end

        ##
        # @return [Array]
        #
        def metrics
          return [] unless @pool_jobs_waiting_total

          [
            @pool_jobs_waiting_total,
            @pool_ready_workers_total,
            @pool_workers_total,
            @pool_initial_size,
            @poll_period,
            @thread_pool_exhausted
          ]
        end

        ##
        # Collect the object into the buffer
        #
        def collect(obj)
          default_labels = {}
          default_labels['environment'] = obj['environment'] if obj['environment']

          custom_labels = obj['custom_labels'] || {}
          labels = custom_labels.nil? ? default_labels : default_labels.merge(custom_labels)

          @pool_jobs_waiting_total.observe(obj['pool_jobs_waiting_total'], labels)
          @pool_ready_workers_total.observe(obj['pool_ready_workers_total'], labels)
          @pool_workers_total.observe(obj['pool_workers_total'], labels)
          @pool_initial_size.observe(obj['pool_initial_size'], labels)
          @poll_period.observe(obj['poll_period'], labels)
          @thread_pool_exhausted.observe(obj['thread_pool_exhausted'] || 0, labels)
        end
      end
    end
  end
end
