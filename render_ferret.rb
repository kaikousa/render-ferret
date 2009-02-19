require "rubygems"
require "daemons"
require "activerecord"
require "yaml"
require "task"
class RenderFerret
  
  attr_reader(:batch_interval)
  
  def initialize
    settings = YAML.load_file("settings.yml")
    #Set up the database connections
    ActiveRecord::Base.establish_connection(settings["database"])
    
    @batch_interval = settings["batch_interval"]
    @task_interval = settings["task_interval"]
    
    #Bootstrap Video Editing Engine
    $: << settings["vee_lib_path"]
    require "builders/json_builder"
    require "vee"
  end
  
  def process_tasks
    tasks = Task.find(:all, :conditions => "status = 1")
    if tasks.size > 0
      puts "Found " + tasks.size.to_s + " tasks!"
    elsif
      puts "No tasks found."
    end
    
    tasks.each{|task|
      puts "Processing task " + task.name + " (id:" + task.id.to_s + ")"
      if task.data != nil
        json_builder = JSONBuilder.new
        movie = json_builder.build_movie_from_str(task.data)
        vee = Vee.new
        vee.process_movie(movie)
      end
      
      task.status = false
      task.save
      sleep(@task_interval)
    }
  end
end

ferret = RenderFerret.new
Daemons.run_proc("render_ferret.rb") do
  loop do
    ferret.process_tasks
    sleep(ferret.batch_interval)
  end
end
