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
    module Instrumentors
      ##
      # Prometheus instrumentor for gRPC servers
      #
      class Grpc
        include Gruf::Loggable

        ##
        # @param [Gruf::Server] server
        # @param [Gruf::Prometheus::Client] client
        # @param [Integer] frequency
        #
        def initialize(server:, client:, frequency: nil)
          @server = server
          @client = client
          @frequency = frequency || 15
        end

        ##
        # Start the instrumentor
        #
        def self.start(server:, client: nil, frequency: nil)
          collector = new(server: server, client: client, frequency: frequency)
          Thread.new do
            loop do
              collector.run
            end
          end
        end

        def run
          metric = collect
          logger.debug "[gruf-prometheus] Pushing metrics to collector: #{metric.inspect}"
          @client.send_json metric
        rescue StandardError => e
          logger.error "[gruf-prometheus] Failed to collect gruf-prometheus stats: #{e.message}"
        ensure
          sleep @frequency
        end

        private

        def collect
          metric = {}
          metric[:type] = 'grpc'
          rpc_server = @server.server
          rpc_server.instance_variable_get(:@run_mutex).synchronize do
            collect_server_metrics(rpc_server, metric)
          end
          metric
        end

        ##
        # @param [GRPC::RpcServer] rpc_server
        #
        def collect_server_metrics(rpc_server, metric)
          pool = rpc_server.instance_variable_get(:@pool)
          metric[:pool_jobs_waiting_total] = pool.jobs_waiting.to_i
          metric[:pool_ready_workers_total] = pool.instance_variable_get(:@ready_workers).size
          metric[:pool_workers_total] = pool.instance_variable_get(:@workers)&.size
          metric[:pool_initial_size] = rpc_server.instance_variable_get(:@pool_size).to_i
          metric[:poll_period] = rpc_server.instance_variable_get(:@poll_period).to_i
        end

        ##
        # @return [GRPC::RpcServer]
        #
        def grpc_server
          @server.server
        end
      end
    end
  end
end
