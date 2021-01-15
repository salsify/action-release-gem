def log_warning(message)
  puts "::warning::#{message}"
end

def exit_with_error(message)
  puts "::error::#{message}"
  exit(1)
end

def output(outputs)
  outputs.each do |name, value|
    puts "::set-output name=#{name}::#{value}"
  end
end
