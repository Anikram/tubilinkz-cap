# Link model with unique name generator and all neccessary fields
#
# (c) goodprogrammer.ru
#
class Link < ApplicationRecord
  # TBD: extract dynamically from current routes.rb paths
  # https://github.com/rails/rails/blob/e20dd73df42d63b206d221e2258cc6dc7b1e6068/railties/lib/rails/tasks/routes.rake#L2
  STOPWORDS = %w(links users user link)

  # https://github.com/ruby/ruby/blob/trunk/lib/uri/rfc2396_parser.rb#L21-L56
  DOMAIN_REGEXP = /\A#{URI::RFC2396_REGEXP::PATTERN::HOSTNAME}\Z/

  belongs_to :user

  validates :name, uniqueness: {scope: [:domain]}
  validates :name, length: {maximum: 90}
  validates :name, format: {with: /\A\w+\Z/i}
  validates :name, :url, presence: true
  validate :name_allowed

  validates :url, length: {maximum: 1023}
  validate :url_allowed

  validates :domain, presence: true, allow_nil: true, allow_blank: false
  validates :domain, format: {with: DOMAIN_REGEXP}, allow_nil: true

  before_validation :set_unique_name, on: :create
  before_validation :downcase_domain

  private

  def set_unique_name
    self.name = unique_url(domain) unless name.present?
  end

  def downcase_domain
    self.domain = domain.downcase if domain
  end

  def name_allowed
    errors.add(:name, :stopwords) if STOPWORDS.include?(name.try(:downcase))
  end

  def unique_url(domain)
    token = ''
    links_count = Link.where(domain: domain).count # todo: cache counters in Domain model

    key_length = case links_count
                 when 0..500
                   2
                 when 501..20000
                   3
                 when 20001..400_000
                   4
                 when 400_001..10_000_000
                   5
                 else
                   6
                 end

    # try to do our best skip no more than 5 conflicts
    5.times do
      token = Link.random_token(key_length)
      return token unless Link.where(name: token, domain: domain).exists?
    end
    # our model is invalid at this point, escalate to user
    errors.add(:name, :not_generated)
    nil
  end

  # idea from http://stackoverflow.com/a/7167988
  # Just a prototype, need to be improved in many ways.
  def url_allowed
    unless Link.valid_url?(url)
      http_url = "http://#{url}"

      if Link.valid_url?(http_url)
        self.url = http_url
      else
        errors.add(:url, :invalid)
      end
    end
  end

  def self.valid_url?(url)
    uri = URI.parse(url)
    !uri.host.nil?
  rescue URI::InvalidURIError
    false
  end

  def self.random_token(key_length)
    SecureRandom.urlsafe_base64(key_length).tr('lIO0-', 'sxyz_')
  end
end