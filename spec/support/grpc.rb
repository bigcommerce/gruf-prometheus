
class TestGrpcPool
  attr_reader :jobs_waiting, :ready_workers, :workers, :pool_size, :poll_period

  def initialize(jobs_waiting: 0, ready_workers: [], workers: [], pool_size: 10, poll_period: 30)
    @jobs_waiting = jobs_waiting
    @ready_workers = ready_workers
    @workers = workers
    @pool_size = pool_size
    @poll_period = poll_period
  end

  def jobs_waiting
    @jobs_waiting
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
  def initialize(server: nil, pool: nil, options: {})
    pool = pool || TestGrpcPool.new
    server = server || TestRpcServer.new(pool: pool)

    super(options)
    @server_mu.synchronize do
      @server = server
    end
  end

  def setup
    nil
  end
end
