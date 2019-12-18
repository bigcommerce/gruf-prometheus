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
      # Prometheus instrumentor for gRPC servers
      #
      class Grpc < Bigcommerce::Prometheus::Collectors::Base
        def collect(metrics)
          rpc_server = grpc_server
          return metrics unless rpc_server

          rpc_server.instance_variable_get(:@run_mutex).synchronize do
            collect_server_metrics(rpc_server, metrics)
          end
          metrics
        end

        ##
        # @param [GRPC::RpcServer] rpc_server
        # @param [Hash] metrics
        #
        def collect_server_metrics(rpc_server, metrics)
          pool = rpc_server.instance_variable_get(:@pool)
          metrics[:pool_jobs_waiting_total] = pool.jobs_waiting.to_i
          metrics[:pool_ready_workers_total] = pool.instance_variable_get(:@ready_workers).size
          metrics[:pool_workers_total] = pool.instance_variable_get(:@workers)&.size
          metrics[:pool_initial_size] = rpc_server.instance_variable_get(:@pool_size).to_i
          metrics[:poll_period] = rpc_server.instance_variable_get(:@poll_period).to_i
        end

        ##
        # @return [GRPC::RpcServer]
        #
        def grpc_server
          @options.fetch(:server, nil)&.server
        end
      end
    end
  end
end
