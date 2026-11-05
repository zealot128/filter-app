# Einmaliges Aufräumen der Production-Queue (storage/production_queue.sqlite3, ~7 GB).
# Aufruf: kamal app exec -d hrfilter --reuse --roles web "bin/rails runner one-timers/202611-solid-queue-cleanup.rb"
# DRY_RUN=1 zeigt nur Zahlen.
dry = ENV["DRY_RUN"].present?
db_file = "storage/production_queue.sqlite3"
report = -> {
  puts "Jobs: #{SolidQueue::Job.count}, failed: #{SolidQueue::FailedExecution.count}, scheduled: #{SolidQueue::ScheduledExecution.count}, #{File.size(db_file) / 1_000_000} MB"
}
report.call
exit if dry

# Veraltete Like-Refreshes vom 2026-11-03, nach 2 Tagen wertlos
SolidQueue::ScheduledExecution.joins(:job).where(solid_queue_jobs: { class_name: "NewsItem::RefreshLikesJob" }).discard_all_in_batches
# Alle Failed-Jobs (überwiegend Netzwerkfehler, Newsletter bis 2025) sollen nicht mehr nachgeholt werden
SolidQueue::FailedExecution.discard_all_in_batches
SolidQueue::Job.clear_finished_in_batches(batch_size: 10_000, finished_before: 1.day.ago)
SolidQueue::RecurringExecution.where(run_at: ...3.days.ago).in_batches(of: 10_000).delete_all
report.call

# Gibt den Platz erst frei; sperrt die DB währenddessen (Job-Worker vorher stoppen)
if ENV["VACUUM"].present?
  SolidQueue::Record.connection.execute("VACUUM")
  report.call
end
