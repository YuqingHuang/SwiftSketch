require './scripts/build_helpers.rb'
require 'fileutils'

# Build
WORKSPACE           = 'SwiftSketch.xcworkspace'
DEFAULT_SCHEME      = 'SwiftSketch'
# QA_SCHEME           = 'SwiftSketch-QA'
# FT_SCHEME           = 'SwiftSketch-cal'
SDK_VERSION         = "8.3"
SIMULATOR_NAME      = ENV["SIMULATOR_NAME"] || "iPhone 6"
SIMULATOR_VERSION   = ENV["SIMULATOR_VERSION"] || "8.3"
CONFIG              = ENV["CONFIG"] || "Debug"

#PLIST
DEFAULT_PLIST       = './SwiftSketch/Info.plist'
# CAL_PLIST           = './SwiftSketch/SwiftSketch/SwiftSketch-cal-Info.plist'
TEST_PLIST          = './SwiftSketchTests/Info.plist'

#DEPLOY
HOCKEY_DEFAULT_KEY  = ''
HOCKEY_QA_KEY       = ''

# Directories
SWIFTSKETCH_DIR = File.expand_path('SwiftSketch')
BUILD_DIR     = File.expand_path('build')
REPORTS_DIR   = BUILD_DIR + "/reports"
SWIFTSKETCH_DIR_NAME = 'SwiftSketch'

# Output
XCBUILD_LOG   = BUILD_DIR + "/xcodebuild.log"

# Libraries
XCPRETTY_AVALIABLE = Gem::Specification::find_all_by_name('xcpretty').any?

@ci_task = false

##############################################################################
# git tasks
##############################################################################

desc "Helper task to commit and remember last commit variables"
task :commit do
  run_cmd("./scripts/git_commands.rb")
end

##############################################################################
# Build tasks
##############################################################################

desc "Cleans and Re-creates the build directory"
task :prepare do
  info("Removing", "Build directories")
  FileUtils.rm_rf "#{BUILD_DIR}"

  info("Creating", "Build directories")
  FileUtils::mkdir_p "#{REPORTS_DIR}"
end

task :build do
  xcbuild("build")
end

task :reset do
  reset_simulator
end

task :default do
  system "rake --tasks"
end

desc "Tests the application"
task :test do
  report_args = "-r html --output '#{REPORTS_DIR}/tests.html' -r junit --output '#{REPORTS_DIR}/junit.xml'"
  xcbuild("clean test", "#{report_args}")
end

namespace :test do

  # desc "Run the functional tests"
  # task :functionals do
  #   init_calabash
  #   xcbuild('build', '', '#{FT_SCHEME}')
  #   app_path = "#{BUILD_DIR}/Build/Products/#{CONFIG}-iphonesimulator/#{FT_SCHEME}.app"

  #   begin
  #     Dir.chdir("#{SWIFTSKETCH_DIR_NAME}") do
  #       run_cmd("export APP=#{app_path} && export APP_BUNDLE_PATH=$APP && \
  #                 DEVICE_TARGET='#{SIMULATOR_NAME} (#{SIMULATOR_VERSION} Simulator)' \
  #                 SCREENSHOT_PATH=#{BUILD_DIR}/ \
  #                 cucumber --tags ~@pending --format html --out #{BUILD_DIR}/functionals.html -f pretty", "Calabash Features")
  #     end
  #   ensure
  #     unless @ci_task
  #       run_cmd("open #{BUILD_DIR}/functionals.html", "Opening Report")
  #     end
  #   end
  # end

  # desc "Run a specific test"
  #   task :functional_test, :name do |t, args|
  #     story = args[:name]
  #   init_calabash
  #   xcbuild('build', '', '#{FT_SCHEME}')
  #   app_path = "#{BUILD_DIR}/Build/Products/#{CONFIG}-iphonesimulator/#{FT_SCHEME}.app"

  #   begin
  #     Dir.chdir("#{SWIFTSKETCH_DIR_NAME}") do
  #       run_cmd("export APP=#{app_path} && export APP_BUNDLE_PATH=$APP && \
  #                   DEVICE_TARGET='#{SIMULATOR_NAME} (#{SIMULATOR_VERSION} Simulator)' \
  #                   SCREENSHOT_PATH=#{BUILD_DIR}/ \
  #                   cucumber features/#{story}.feature --tags ~@pending --format html --out #{BUILD_DIR}/functionals.html -f pretty", "Calabash Features")
  #     end
  #     ensure
  #     unless @ci_task
  #       run_cmd("open #{BUILD_DIR}/functionals.html", "Opening Report")
  #     end
  #   end
  # end
end

task :ci => "ci:test"

namespace :ci do
  desc "CI Task for build"
  task :test do
    @ci_task = true
    calabash_reset_simulator
    Rake::Task['test'].invoke
  end

  desc "CI Task for functional tests"
  task :functionals do
    @ci_task = true
    calabash_reset_simulator
    Rake::Task['prepare'].invoke
    Rake::Task['test:functionals'].invoke
  end
end

desc "Rev the build numbers in a project's plist"
task :rev do  
  info("Updating", "Build Numbers")
  revBuild DEFAULT_PLIST
  # revBuild '#{CAL_PLIST}'
  revBuild '#{TEST_PLIST}'
end

namespace :deploy do
  desc "Deploy Alpha(iTest) to Hockeyapp"
  task :itest, :messageString do |t, args|
    deploy("-s #{DEFAULT_SCHEME} -c Debug", "#{HOCKEY_DEFAULT_KEY}", args[:messageString])
  end

  # desc "Deploy Beta(QA) to Hockeyapp"
  # task :qa, :messageString do |t, args|
  #   deploy("-s #{QA_SCHEME} -c QA", "#{HOCKEY_QA_KEY}", args[:messageString])
  # end
end
