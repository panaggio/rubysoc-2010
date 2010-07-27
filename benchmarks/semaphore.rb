# Code adapted from http://gist.github.com/480359

require "benchmark"
require "thread"

implementations = [Semaphore, Thread::Semaphore]

n, sem_size = 1_000_000, 5

Benchmark.bmbm(14) do |x|
  sems = implementations.each_with_object({}){ |klass, h| h[klass] = klass.new(sem_size) }
  sems2 = implementations.each_with_object({}){ |klass, h| h[klass] = klass.new(n) }
  implementations.each do |klass|
    x.report("#{klass.name}(overall)") do
      n.times do
        (sem_size-1).times {sems[klass].wait}
        (sem_size-1).times {sems[klass].signal}
      end
    end
    x.report("#{klass.name}#wait") do
      (n-1).times {sems2[klass].wait}
    end
    x.report("#{klass.name}#signal") do
      (n-1).times {sems2[klass].signal}
    end
  end
end
