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
class CustomCollector < ::Bigcommerce::Prometheus::Collectors::Base
  ##
  # A demo metric on-demand
  #
  def bar_it_up(total:)
    metric = {}
    metric[:type] = 'custom'
    metric[:custom_labels] = {}
    metric[:on_demand_total] = total.to_i
    @logger.debug("[gruf-prometheus] Pushing custom metric on_demand_total to type collector #{Bigcommerce::Prometheus.server_host}:#{Bigcommerce::Prometheus.server_port}: #{metric.inspect}")
    @client.send_json(metric)
  rescue StandardError => e
    @logger.error("[gruf-prometheus] Prometheus failed to send on_demand_total stats: #{e.message}")
  end

  ##
  # Metrics to be collected on a polling basis
  #
  def collect(metrics)
    metrics[:polled_total] = rand(100)
    metrics
  end
end
