#!/usr/bin/env ruby

require 'io/console'

  PROMPT_CAPTURE = Proc.new do |prompt, previous_answer|
    input = nil
    previous_answer ||= ""
    until !input.nil? && !input.empty? do
      if !previous_answer.empty?
        puts "#{prompt} : "
        puts "Previous: #{previous_answer}. Keep it ? (Y/N)"
        key = STDIN.getch
        if key.strip.upcase == "Y"
          input = previous_answer
        else
          message = "New #{prompt} "
          if prompt == "Pair"
            message << "ex. John | Bob"
          end
          puts "#{message} :"
          input = STDIN.gets.strip
        end
      else
        puts "#{prompt} :"
        input = STDIN.gets.strip
      end
    end
    input
  end

  COMMIT_PROMPTS = [ "Pair", "Story", "Description"]

  def commit
    message = ""
    current_prompts = {}
    previous_prompts = read_prompts
    COMMIT_PROMPTS.each do |prompt|
      input = PROMPT_CAPTURE.call(prompt, previous_prompts[prompt.to_sym])
      current_prompts[prompt.to_sym]=input
      if prompt == "Pair"
        message << "[#{input}]"
      else
        message << " - #{input}"
      end
    end
    write_prompts current_prompts
    `git commit -m '#{message}'`
    puts $?.exitstatus == 0 ? "\nSuccessfully Committed" : "\nFailed to commit"
  end

  def read_prompts
    if !File.exists?(".commit-prompt")
      prompt_file = File.new(".commit-prompt", "w")
      prompt_file.close
    end
    f = File.open(".commit-prompt", "rb")
    prompts = Marshal.load(f) || {}
    f.close
    prompts
  rescue
    {}
  end

  def write_prompts prompts
    f = File.open(".commit-prompt", "wb")
    Marshal.dump(prompts, f)
    f.close
  end

commit
