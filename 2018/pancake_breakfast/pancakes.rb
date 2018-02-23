# require '/Users/Daniel/KAODIM/code/codejam/2018/pancake_breakfast/pancakes'
module Pancakes
  SMALL_INPUT_PATH = '/Users/Daniel/Downloads/B-small-practice.in'.freeze
  BIG_INPUT_PATH = '/Users/Daniel/Downloads/B-large-practice.in'.freeze
  SMALL_OUTPUT_PATH = '/Users/Daniel/Downloads/B-small-practice.out'.freeze
  BIG_OUTPUT_PATH = '/Users/Daniel/Downloads/B-large-practice.out'.freeze

  def generate_results(input_path, output_path)
    File.open(output_path, 'w') do |f|
      # byebug
      lines = load_pancakes(input_path)
      lines.each_with_index do |line, idx|
        if (idx+1) % 2 == 0
          pancakes = line.chomp
                         .split
                         .map { |str| str.to_i }
          case_number = (idx + 1) / 2
          output = "Case \##{case_number}: #{solver(pancakes)}\n"
          # output = "Case \##{case_number}: #{line.chomp}\n"
          f << output
        end
      end
    end
    return
  end

  def load_pancakes(file_path)
    lines = File.readlines(file_path)
    lines.shift
    lines
  end

  def solver(pancakes)
    max_plate = find_max(pancakes)
    distribution_time = 0
    while max_plate.should_distribute?
      pancakes = distribute_pancakes(pancakes, max_plate)
      distribution_time+=max_plate.count
      # puts "#{max_plate.max},#{max_plate.new_max},#{max_plate.benefit},#{max_plate.cost},#{max_plate.distributed_cakes},#{max_plate.net_value}"
      max_plate = find_max(pancakes)
    end
    distribution_time + max_plate.max
  end

  def distribute_pancakes(pancakes, plate)
    plate.indexes.each do |idx|
      pancakes[idx] = plate.new_max
    end
    # pancakes << plate.distributed_cakes
    pancakes.insert(-1, *([plate.distributed_cakes] * plate.count))
    pancakes
  end

  MaxPlate = Struct.new(:max, :count, :indexes) do
    def reset_count
      self.count = 1
      self
    end

    def increase_count
      self.count+=1
      self
    end

    def cost
      count
    end

    def benefit
      (max - new_max)
    end

    def net_value
      benefit - cost
    end

    def new_max
      (max/2.0).ceil
    end

    def should_distribute?
      net_value > 0
    end

    def add_index(idx)
      self.indexes << idx
      self
    end

    def clear_indexes
      self.indexes = []
      self
    end

    def distributed_cakes
      max/2
    end
    
    def set_max(value)
      self.max = value
      self
    end
  end

  def find_max(plates)
    max_plate = MaxPlate.new(0, 1, [])
    plates.each_with_index do |c, idx|
      next if max_plate.max > c

      if max_plate.max < c
        max_plate.set_max(c)
                 .reset_count
                 .clear_indexes
      elsif max_plate.max == c
        max_plate.increase_count
      end

      max_plate.add_index(idx)
    end
    max_plate
  end

  # TEST_2 = [42,178,662,145,283,925,644,229,106,145,766,352,880,510,766]
end

