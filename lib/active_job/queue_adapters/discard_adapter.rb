module ActiveJob
  module QueueAdapters
    class DiscardAdapter
      def enqueue job
        # Discard
      end

      def enqueue_at *
        raise NotImplementedError, "Use a queueing backend to enqueue jobs in the future. Read more at http://guides.rubyonrails.org/active_job_basics.html"
      end
    end
  end
end
