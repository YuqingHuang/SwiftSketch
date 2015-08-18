##############################################################################
# Build Methods
##############################################################################

def xcbuild(build_type = '', xcpretty_args = '', scheme=nil)

  # Default scheme
  scheme ||= DEFAULT_SCHEME

  xcodebuild = "xcodebuild \
                      -workspace #{WORKSPACE} \
                      -scheme #{scheme} \
                      -sdk iphonesimulator#{SDK_VERSION} \
                      -destination platform='iOS Simulator',OS=#{SIMULATOR_VERSION},name='#{SIMULATOR_NAME}' \
                      -configuration #{CONFIG} \
                      -derivedDataPath '#{BUILD_DIR}' \
                      #{build_type} 2>&1 | tee '#{XCBUILD_LOG}' "

  if XCPRETTY_AVALIABLE
    run_cmd(xcodebuild +
            "2>&1 | xcpretty -tc #{xcpretty_args}; \
            exit ${PIPESTATUS[0]}",
            "xcodebuild " + build_type)
  else
    run_cmd(xcodebuild, "xcodebuild " + build_type)
  end
end

def reset_simulator
  begin
    run_cmd("osascript ./scripts/reset_simulator.applescript", "Resetting Simulator")
    sleep(30)
  rescue
    nil
  end
end

def calabash_reset_simulator
  begin
    run_cmd("calabash-ios sim reset", "Resetting Simulator")
  rescue
    nil
  end
end

def init_calabash
  Dir.chdir("Southwest") do
    unless File.exists?(File.expand_path("calabash.framework"))
      run_cmd("./init_calabash.sh", "Initializing Calabash")
    end
  end
end

def update_mock_data
  mock_server_dir = ENV['MOCK_SERVER_PATH']
  Dir.chdir(mock_server_dir) do
    run_cmd("git pull", "updating mock server data")
  end
end

def generate_resources
  info("Generating", "Storyboards")
  generate_file(".storyboard", "-Storyboard.swift")

  print "\n"

  info("Generating", "Image Assets")
  generate_file(".xcassets", "-Catalog.swift")
end

def generate_file(extension, output_extension)
  Dir.glob("#{SwiftSketch_DIR}/**/*#{extension}") do |file|
    baseName      = File.basename("#{file}", "#{extension}")
    swiftFileName = file.gsub(/#{extension}/, "#{output_extension}")
    print "\t"
    run_cmd("./scripts/swiftrsrc generate --platform ios '#{file}' '#{swiftFileName}'", "#{baseName}.storyboard")
  end
end

def revBuild(plistFile)  
  puts "Attempting to update #{plistFile} build version..."
  oldVersion = `/usr/libexec/PlistBuddy -c "Print CFBundleVersion" #{plistFile}`
  puts "The old version: #{oldVersion}"

  versionParts = oldVersion.split(".")
  previousPatch = versionParts[2]
  newPatch = previousPatch.to_i + 1
  versionParts[2] = newPatch.to_s

  versionParts.each do |part|
    part.chomp!
  end

  newVersion = versionParts.join(".")

  `/usr/libexec/PlistBuddy -c "Set :CFBundleVersion #{newVersion}" \
                            -c "Set :CFBundleShortVersionString #{newVersion}" \
                            #{plistFile}`

  puts "The new version: #{newVersion}"
end

def deploy(ipa_args, api_token, message)
  info("Running", "ipa build and deploy")
  response = `cd Southwest && ipa build #{ipa_args} && ipa distribute:hockeyapp -a #{api_token} -m  \"#{message}\"`

  # ipa gem fails silently fails when uploading to hockey app
  if response !~ /Build successfully uploaded to HockeyApp/
    error("#{response}")
  else
    info("Finished", "Upload to Hockey app")
  end
end

##############################################################################
# Private Methods
##############################################################################

private

def run_cmd( cmd, desc = nil)
  desc ||= cmd
  info("Running", desc)
  Dir.mkdir(BUILD_DIR) unless File.exists?(BUILD_DIR)
  unless system("#{cmd}")
    error(desc)
  end
end

def info(action, description)
  puts "▸".yellow + " #{action}".bold + " #{description}"
end

def error(description)
  puts "[!] FAILED #{description}".red
  exit 1
end

class String
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def bold
    "\e[1m#{self}\e[22m"
  end
end
