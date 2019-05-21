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
    #
    class Server
      include Gruf::Loggable

      ##
      # @param [Integer] port
      # @param [Integer] timeout
      # @param [String] prefix
      # @param [Boolean] verbose
      # @param [Class] server_class
      #
      def initialize(
        port:,
        timeout:,
        prefix: nil,
        verbose: false,
        server_class: nil
      )
        @port = (port || ::PrometheusExporter::DEFAULT_PORT).to_i
        @timeout = (timeout || ::PrometheusExporter::DEFAULT_TIMEOUT).to_i
        @prefix = (prefix || ::PrometheusExporter::DEFAULT_PREFIX).to_s
        @verbose = verbose
        @server_class = server_class || ::PrometheusExporter::Server::WebServer
        @running = false
        @process_name = ::Gruf::Prometheus.process_name
      end

      def start
        setup_signal_handlers

        logger.info "[gruf-prometheus][#{@process_name}] Starting prometheus exporter on port #{@port}"
        server.start
        logger.info "[gruf-prometheus][#{@process_name}] Prometheus exporter started on port #{@port}"

        @running = true
        server
      rescue StandardError => e
        logger.error "[gruf-prometheus][#{@process_name}] Failed to start exporter: #{e.message}"
      end

      ##
      # Stop the server
      #
      def stop
        logger.info "[gruf-prometheus][#{@process_name}] Shutting down prometheus exporter"
        server.stop
        logger.info "[gruf-prometheus][#{@process_name}] Prometheus exporter cleanly shut down"
      rescue StandardError => e
        logger.error "[gruf-prometheus][#{@process_name}] Failed to stop exporter: #{e.message}"
      end

      ##
      # Whether or not the server is running
      #
      # @return [Boolean]
      #
      def running?
        @running
      end

      ##
      # Add a type collector to this server
      #
      # @param [Class] collector A type collector for the prometheus server
      #
      def add_type_collector(collector)
        runner.type_collectors = runner.type_collectors.push(collector)
      end

      private

      ##
      # @return [::PrometheusExporter::Server::Runner]
      #
      def runner
        unless @runner
          @runner = ::PrometheusExporter::Server::Runner.new(
            timeout: @timeout,
            port: @port,
            prefix: @prefix,
            verbose: @verbose,
            server_class: @server_class
          )
          PrometheusExporter::Metric::Base.default_prefix = @runner.prefix
        end
        @runner
      end

      ##
      # Register signal handlers
      #
      # :nocov:
      def setup_signal_handlers
        ::Signal.trap('INT') { server.stop }
        ::Signal.trap('TERM') { server.stop }
      end
      # :nocov:

      ##
      # @return [PrometheusExporter::Server::WebServer]
      #
      def server
        @server ||= begin
          runner.send(:register_type_collectors)
          runner.server_class.new(
            port: runner.port,
            collector: runner.collector,
            timeout: runner.timeout,
            verbose: runner.verbose
          )
        end
      end
    end
  end
end
