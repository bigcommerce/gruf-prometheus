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
      class Grpc < Bigcommerce::Prometheus::TypeCollectors::Base

        private

        ##
        # Initialize the collector
        #
        def build_metrics
          {
            pool_jobs_waiting_total: PrometheusExporter::Metric::Gauge.new('grpc_pool_jobs_waiting_total', 'Number jobs in the gRPC thread pool that are actively waiting'),
            pool_ready_workers_total: PrometheusExporter::Metric::Gauge.new('grpc_pool_ready_workers_total', 'The amount of non-busy workers in the thread pool'),
            pool_workers_total: PrometheusExporter::Metric::Gauge.new('grpc_pool_workers_total', 'Number of workers in the gRPC thread pool'),
            pool_initial_size: PrometheusExporter::Metric::Gauge.new('grpc_pool_initial_size', 'Initial size of the gRPC thread pool'),
            poll_period: PrometheusExporter::Metric::Gauge.new('grpc_poll_period', 'Polling period for the gRPC thread pool'),
            thread_pool_exhausted: PrometheusExporter::Metric::Counter.new('grpc_thread_pool_exhausted', 'Times the gRPC thread pool has been exhausted')
          }
        end

        ##
        # Collect the object into the buffer
        #
        def collect_metrics(data: {}, labels: {})
          metric(:pool_jobs_waiting_total)&.observe(data['pool_jobs_waiting_total'].to_i, labels)
          metric(:pool_ready_workers_total)&.observe(data['pool_ready_workers_total'].to_i, labels)
          metric(:pool_workers_total)&.observe(data['pool_workers_total'].to_i, labels)
          metric(:pool_initial_size)&.observe(data['pool_initial_size'].to_i, labels)
          metric(:poll_period)&.observe(data['poll_period'].to_i, labels)
          metric(:thread_pool_exhausted)&.observe(data['thread_pool_exhausted'].to_i, labels)
        end
      end
    end
  end
end
