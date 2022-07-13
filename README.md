# gruf-prometheus - Prometheus support for gruf

[![CircleCI](https://circleci.com/gh/bigcommerce/gruf-prometheus/tree/main.svg?style=svg)](https://circleci.com/gh/bigcommerce/gruf-prometheus/tree/main)  [![Gem Version](https://badge.fury.io/rb/gruf-prometheus.svg)](https://badge.fury.io/rb/gruf-prometheus) [![Documentation](https://inch-ci.org/github/bigcommerce/gruf-prometheus.svg?branch=main)](https://inch-ci.org/github/bigcommerce/gruf-prometheus?branch=main)

Adds Prometheus support for [gruf](https://github.com/bigcommerce/gruf) 2.7.0+. Supports Ruby 2.7-3.1.

## Installation

```ruby
gem 'gruf-prometheus'
```

In your gruf initializer:

```ruby
require 'gruf/prometheus'

Gruf.configure do |c|
  c.hooks.use(Gruf::Prometheus::Hook)
end
```

Then `bundle exec gruf` and you'll automatically have prometheus metrics for your gruf server.

The gruf server will by default run on port 9394, and can be scraped at `/metrics`.

## Integrations

### System Metrics

The gem comes with general system metrics out of the box that illustrate server health/statistics:

|Name|Type|Description|
|---|---|---|
|ruby_grpc_pool_jobs_waiting_total|gauge|Number of jobs in the gRPC thread pool that are actively waiting|
|ruby_grpc_pool_ready_workers_total|gauge|The amount of non-busy workers in the thread pool|
|ruby_grpc_pool_workers_total|gauge|Number of workers in the gRPC thread pool|
|ruby_grpc_pool_initial_size|gauge|Initial size of the gRPC thread pool|
|ruby_grpc_poll_period|gauge|Polling period for the gRPC thread pool|

### Server Metrics

Furthermore, the server interceptor measures general counts (and optionally, latencies), and can be setup via:

```ruby
::Gruf.interceptors.use(::Gruf::Prometheus::Server::Interceptor)
```

This will output the following metrics:

|Name|Type|Description|
|---|---|---|
|ruby_grpc_server_started_total|counter|Total number of RPCs started on the server|
|ruby_grpc_server_failed_total|counter|Total number of RPCs that throw an unknown, internal, data loss, failed precondition, unavailable, deadline exceeded, or cancelled exception on the server|
|ruby_grpc_server_handled_total|counter|Total number of RPCs completed on the server, regardless of success or failure|
|ruby_grpc_server_handled_latency_seconds|histogram|Histogram of response latency of RPCs handled by the server, in seconds|

Note that the histogram is disabled by default - you'll have to turn it on either through the `server_measure_latency`
configuration yielded in `Gruf::Prometheus.configure`, or through the `PROMETHEUS_SERVER_MEASURE_LATENCY` environment
variable. Also, the `measure_latency: true` option can be passed as a second argument to `Gruf.interceptors.use` to
configure this directly in the interceptor.

The precedence order for this is, from first to last, with last taking precedence:
1) `measure_latency: true` passed into the interceptor
2) `Gruf::Prometheus.configure` explicit setting globally
3) `PROMETHEUS_SERVER_MEASURE_LATENCY` ENV var globally. This is the only value set by default - to `false` - and will
   be the default unless other methods are invoked.

### Client Metrics

gruf-prometheus can also measure gruf client timings, via the interceptor:

```ruby
Gruf::Client.new(
  service: MyService,
  client_options: {
    interceptors: [Gruf::Prometheus::Client::Interceptor.new]
  }
)
```

|Name|Type|Description|
|---|---|---|
|ruby_grpc_client_started_total|counter|Total number of RPCs started by the client|
|ruby_grpc_client_failed_total|counter|Total number of RPCs that throw an unknown, internal, data loss, failed precondition, unavailable, deadline exceeded, or cancelled exception by the client|
|ruby_grpc_client_completed|counter|Total number of RPCs completed by the client, regardless of success or failure|
|ruby_grpc_client_completed_latency_seconds|histogram|Histogram of response latency of RPCs completed by the client, in seconds|

Note that the histogram is disabled by default - you'll have to turn it on either through the `client_measure_latency`
configuration yielded in `Gruf::Prometheus.configure`, or through the `PROMETHEUS_CLIENT_MEASURE_LATENCY` environment
variable. Optionally, you can pass in `measure_latency: true` into the Interceptor directly as an option argument in the
initializer.

The precedence order for this is, from first to last, with last taking precedence:
1) `measure_latency: true` passed into the interceptor
2) `Gruf::Prometheus.configure` explicit setting globally
3) `PROMETHEUS_CLIENT_MEASURE_LATENCY` ENV var globally. This is the only value set by default - to `false` - and will
   be the default unless other methods are invoked.

### Running the Client Interceptor in Non-gRPC Processes

One caveat is that you _must_ have the appropriate Type Collector setup in whatever process you are running in. If
you are already doing this in a gruf gRPC service that is using the hook provided by this gem above, no further
configuration is needed. Otherwise, in whatever bc-prometheus-ruby configuration you have setup, you'll need to ensure
the type collector is loaded:

```ruby
# prometheus_server is whatever `::Bigcommerce::Prometheus::Server` instance you are using in the current process
# Often hooks into these are exposed as configuration options, e.g. `web_collectors`, `resque_collectors`, etc
prometheus_server.add_type_collector(::Gruf::Prometheus::Client::TypeCollector.new)
```

Note that you don't need to do this for the `Gruf::Prometheus::Client::Collector`, as it is an on-demand collector
that does not run in a threaded loop.

See [bc-prometheus-ruby](https://github.com/bigcommerce/bc-prometheus-ruby#custom-server-integrations)'s documentation
on custom server integrations for more information.

## Configuration

You can further configure `Gruf::Prometheus` globally using the block syntax:

```ruby
Gruf::Prometheus.configure do |config|
  # config here
end
```

where the options available are:

| Option | Description | Default | ENV Name |
| ------ | ----------- | ------- | -------- |
| process_label | The label to use for metric prefixing | grpc | PROMETHEUS_PROCESS_LABEL |
| process_name | Label to use for process name in logging | grpc | PROMETHEUS_PROCESS_NAME |
| collection_frequency | The period in seconds in which to collect metrics | 30 | PROMETHEUS_COLLECTION_FREQUENCY |
| collectors | Any collectors you would like to start with the server. Passed as a hash of collector class => options | {} | |
| type_collectors | Any type collectors you would like to start with the server. Passed as an array of collector objects | [] | |
| server_measure_latency| Whether or not to measure latency as a histogram for servers | 0 | PROMETHEUS_SERVER_MEASURE_LATENCY |
| client_measure_latency| Whether or not to measure latency as a histogram for clients | 0 | PROMETHEUS_CLIENT_MEASURE_LATENCY |

## License

Copyright (c) 2019-present, BigCommerce Pty. Ltd. All rights reserved

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
