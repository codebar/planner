# frozen_string_literal: true

# A MemoryStore that records reads, misses and writes, so a spec can assert a
# render was served from the fragment cache instead of inferring it from timing
# or from the store's internals.
class CountingCacheStore < ActiveSupport::Cache::MemoryStore
  attr_reader :hits, :misses, :writes

  def initialize(*)
    super
    @counts_lock = Mutex.new
    reset_counts!
  end

  def read(name, *args, **options)
    value = super
    @counts_lock.synchronize { value.nil? ? @misses += 1 : @hits += 1 }
    value
  end

  def write(name, value, *args, **options)
    @counts_lock.synchronize { @writes += 1 }
    super
  end

  def reset_counts!
    @counts_lock.synchronize do
      @hits = 0
      @misses = 0
      @writes = 0
    end
  end
end
