class LinkClickedJob < ApplicationJob
  queue_as :default

  def perform(link)
    Link.increment_counter(:clicks, link.id)
  end
end
