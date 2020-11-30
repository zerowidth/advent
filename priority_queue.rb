# From https://www.brianstorti.com/implementing-a-priority-queue-in-ruby/
# with modifications for debugging

class PriorityQueue
  attr_reader :elements

  def initialize
    @elements = [nil]
  end

  def <<(element)
    @elements << element
    bubble_up(@elements.size - 1)
  end

  def pop
    exchange(1, @elements.size - 1)
    max = @elements.pop
    bubble_down(1)
    max
  end

  def empty?
    @elements == [nil]
  end

  private

  def bubble_up(index)
    parent_index = (index / 2)

    return if index <= 1
    return if @elements[parent_index] >= @elements[index]

    exchange(index, parent_index)
    bubble_up(parent_index)
  end

  def bubble_down(index)
    child_index = (index * 2)

    return if child_index > @elements.size - 1

    not_the_last_element = child_index < @elements.size - 1
    left_element = @elements[child_index]
    right_element = @elements[child_index + 1]
    child_index += 1 if not_the_last_element && right_element > left_element

    return if @elements[index] >= @elements[child_index]

    exchange(index, child_index)
    bubble_down(child_index)
  end

  def exchange(source, target)
    @elements[source], @elements[target] = @elements[target], @elements[source]
  end
end

if $0 == __FILE__
  require 'minitest/autorun'
  require_relative 'priority_queue'

  class PriorityQueueTest < Minitest::Test
    def setup
      @priority_queue = PriorityQueue.new
    end

    def test_adds_element_in_correct_order
      @priority_queue << 2
      @priority_queue << 1
      @priority_queue << 3

      assert_equal [nil, 3, 1, 2], @priority_queue.elements
    end

    def test_removes_top_element
      @priority_queue << 2
      @priority_queue << 1
      @priority_queue << 3

      assert_equal 3, @priority_queue.pop
      assert_equal [nil, 2, 1], @priority_queue.elements
    end
  end
end
