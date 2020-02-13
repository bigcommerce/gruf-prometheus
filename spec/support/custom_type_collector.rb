# Copyright (c) 2020-present, BigCommerce Pty. Ltd. All rights reserved
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
class CustomTypeCollector < ::Bigcommerce::Prometheus::TypeCollectors::Base
  include ::Gruf::Loggable

  def build_metrics
    {
      polled_total: PrometheusExporter::Metric::Gauge.new('polled_total', 'Number of metric that is polled '),
      on_demand_total: PrometheusExporter::Metric::Gauge.new('on_demand_total', 'Number of metric that is on-demand')
    }
  end

  ##
  # The type collector here processes both polled and on-demand data, so we have to ensure key existence first
  #
  def collect_metrics(data:, labels: {})
    logger.info "[gruf-prometheus] Received data and processing: #{data.inspect}"

    metric(:polled_total)&.observe(data['polled_total'], labels) if data.key?('polled_total')
    metric(:on_demand_total)&.observe(data['on_demand_total'], labels) if data.key?('on_demand_total')
  end
end
