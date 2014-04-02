module Sidekiq
  class SortedEntry
    def retry_failure
      Sidekiq.redis do |conn|
        results = conn.zrangebyscore(Sidekiq::Failures::LIST_KEY, score, score)
        conn.zremrangebyscore(Sidekiq::Failures::LIST_KEY, score, score)
        results.map do |message|
          msg = Sidekiq.load_json(message)
          Sidekiq::Client.push(msg)
        end
      end
    end
  end
end
