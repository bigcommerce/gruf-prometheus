# gruf-prometheus - Prometheus support for gruf

[![CircleCI](https://circleci.com/gh/bigcommerce/gruf-prometheus/tree/master.svg?style=svg)](https://circleci.com/gh/bigcommerce/gruf-prometheus/tree/master)  [![Gem Version](https://badge.fury.io/rb/gruf-prometheus.svg)](https://badge.fury.io/rb/gruf-prometheus) [![Documentation](https://inch-ci.org/github/bigcommerce/gruf-prometheus.svg?branch=master)](https://inch-ci.org/github/bigcommerce/gruf-prometheus?branch=master)

Adds Prometheus support for [gruf](https://github.com/bigcommerce/gruf) 2.7.0+.

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

## Configuration

You can further configure with:

| Option | Description | Default |
| ------ | ----------- | ------- |
| client_custom_labels | A hash of custom labels to send with each client request | `{}` |
| client_max_queue_size | The max amount of metrics to send before flushing | 10000 |
| client_thread_sleep | How often to sleep the worker thread that manages the client buffer (seconds) | 0.5 |
| process_label | The label to use for metric prefixing | grpc |
| process_name | Label to use for process name in logging | grpc |
| collection_frequency | How often to poll collection metrics (seconds) | 15 |
| server_host | The host to run the collector on | '0.0.0.0' |
| server_port | The port to run the collector on | 9394 |
| server_prefix | The prefix for all collected metrics | ruby_ |
| server_timeout | Timeout when exporting metrics (seconds) | 2 | 	
        
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
