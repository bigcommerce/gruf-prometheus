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
    # General configuration for gruf prometheus integration
    #
    module Configuration
      VALID_CONFIG_KEYS = {
        process_label: 'grpc',
        process_name: 'grpc',
        collection_frequency: 30,
        type_collectors: [],
        collectors: []
      }.freeze

      attr_accessor *VALID_CONFIG_KEYS.keys

      ##
      # Whenever this is extended into a class, setup the defaults
      #
      def self.extended(base)
        base.reset
      end

      ##
      # Yield self for ruby-style initialization
      #
      # @yields [Bigcommerce::Prometheus::Configuration]
      # @return [Bigcommerce::Prometheus::Configuration]
      #
      def configure
        reset unless @configured
        yield self
        @configured = true
      end

      ##
      # Return the current configuration options as a Hash
      #
      # @return [Hash]
      #
      def options
        opts = {}
        VALID_CONFIG_KEYS.each_key do |k|
          opts.merge!(k => send(k))
        end
        opts
      end

      ##
      # Set the default configuration onto the extended class
      #
      def reset
        VALID_CONFIG_KEYS.each do |k, v|
          send("#{k}=".to_sym, v)
        end
        self.process_label = ENV.fetch('PROMETHEUS_PROCESS_LABEL', 'grpc').to_s
        self.process_name = ENV.fetch('PROMETHEUS_PROCESS_NAME', 'grpc').to_s
        self.collection_frequency = ENV.fetch('PROMETHEUS_COLLECTION_FREQUENCY', 30).to_i
      end

      ##
      # Automatically determine environment
      #
      # @return [String] The current Ruby environment
      #
      def environment
        if defined?(Rails)
          Rails.env.to_s
        else
          (ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development').to_s
        end
      end
    end
  end
end
