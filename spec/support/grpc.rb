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
require_relative '../pb/ThingService_services_pb'

class TestGrpcPool
  attr_reader :jobs_waiting,
              :ready_workers,
              :workers,
              :pool_size,
              :poll_period

  def initialize(jobs_waiting: nil, ready_workers: nil, workers: nil, pool_size: nil, poll_period: nil)
    @jobs_waiting = jobs_waiting || 0
    @ready_workers = ready_workers || []
    @workers = workers || []
    @pool_size = pool_size || 10
    @poll_period = poll_period || 30
  end
end

class TestRpcServer
  def initialize(pool: nil)
    @pool = pool || TestGrpcPool.new
    @pool_size = pool.pool_size
    @poll_period = pool.poll_period
    @run_mutex = Mutex.new
  end
end

class TestGrufServer < ::Gruf::Server
  attr_reader :server

  def initialize(server: nil, pool: nil, options: {})
    pool ||= TestGrpcPool.new
    options ||= {}
    super(options)
    @server = server || TestRpcServer.new(pool: pool)
  end

  def setup
    nil
  end
end
