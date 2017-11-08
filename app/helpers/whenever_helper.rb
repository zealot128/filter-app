require 'whenever'

module WheneverHelper
  def filter_jobs_by_task(task)
    jobs = Whenever::JobList.new(file: Rails.root.join("config", "schedule.rb").to_s).instance_variable_get("@jobs")
    jobs.values.flatten.select do |job|
      job.instance_variable_get("@options")[:task] == task
    end
  end
end
