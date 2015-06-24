require 'thread'

def parallelize(tasks, num_threads=10)
  queue = Queue.new
  tasks.each{ |task| queue.push(task) }

  workers = (0...num_threads).map do
    Thread.new do
      begin
        while task = queue.pop(true)
          task.call
        end
      rescue ThreadError
      end
    end
  end

  workers.map(&:join)
end
