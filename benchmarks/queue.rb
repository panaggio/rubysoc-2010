# Code adapted from http://gist.github.com/480359

require "benchmark"
require "thread"
require "extthread"

methods = {
  push: -> q { N.times { |i| q.push i } },
  pop: -> q { N.times { |i| q.pop } },
  empty?: -> q {
    (N/2).times { |i| q.empty? }
    q.push :tmp
    (N/2).times { |i| q.empty? }
  },
  clear: -> q {
    (N/2).times { q.clear }
    (N/2).times { q << :tmp; q.clear }
  },
  size: -> q { N.times { q.size } },
  num_waiting: -> q { N.times { q.num_waiting } }
}
implementations = [Queue, Thread::Queue]

N = 1_000_000
Benchmark.bmbm(14) do |x|
  queues = implementations.each_with_object({}) { |klass, h| h[klass] = klass.new }
  methods.each_pair { |meth, bench|
    implementations.each { |klass|
      x.report("#{klass.name[0]}##{meth}") {
        bench[queues[klass]]
      }
    }
  }
end
