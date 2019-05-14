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
    ##
    # Prometheus server that runs with gruf hooks
    class Server
      include Gruf::Loggable

      def initialize(port:, timeout:, verbose: false)
        @port = (port || ::PrometheusExporter::DEFAULT_PORT).to_i
        @timeout = (timeout || ::PrometheusExporter::DEFAULT_TIMEOUT).to_i
        @verbose = verbose
      end

      def start
        logger.info "[gruf-prometheus] Starting prometheus exporter on port #{@port}"
        PrometheusExporter::Metric::Base.default_prefix = PrometheusExporter::DEFAULT_PREFIX
        server_collector.register_collector(Gruf::Prometheus::Collectors::Grpc.new)
        server.start
      end

      def stop
        logger.info '[gruf-prometheus] Prometheus server shutting down...'
        server.stop
        logger.info '[gruf-prometheus] Prometheus server shut down successfully...'
      end

      private

      def server_collector
        @server_collector ||= PrometheusExporter::Server::Collector.new
      end

      def server
        @server ||= ::PrometheusExporter::Server::WebServer.new(
          port: @port,
          collector: server_collector,
          timeout: @timeout,
          verbose: @verbose
        )
      end
    end
  end
end
