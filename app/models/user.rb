class User < ApplicationRecord
  attr_accessor :remember_token, :card_activation_token, :reset_token
  enum role: {admin: 0, librarian: 1, user: 2}

  has_one :card, dependent: :destroy
  has_many :comments
  has_many :notifications

  scope :all_user, ->{select :id, :name, :email}

  paginates_per Settings.OBJECT_PER_PAGE

  before_save{email.downcase!}
  validates :terms_of_service, acceptance: {accept: true}
  validates :name, presence: true,
    length: {maximum: Settings.MAX_NAME_LENGTH}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true,
    length: {maximum: Settings.MAX_EMAIL_LENGTH},
    format: {with: VALID_EMAIL_REGEX},
    uniqueness: {case_sensitive: false}

  has_secure_password
  validates :password, presence: true,
    length: {minimum: Settings.MIN_PASSWORD_LENGTH},
    allow_nil: true

  delegate :id, to: :card, prefix: true, allow_nil: true
  delegate :issued_date, to: :card, prefix: true, allow_nil: true
  delegate :expired_date, to: :card, prefix: true, allow_nil: true

  class << self
    def from_omniauth auth
      where(provider: auth.provider,
        uid: auth.uid).first_or_initialize.tap do |user|
        user.provider = auth.provider
        user.uid = auth.uid
        user.email = auth.info.email
        user.first_name = auth.info.first_name
        user.last_name = auth.info.last_name
        user.password = SecureRandom.hex(8) if user.new_record?
        user.name = auth.info.name
        user.save
        user
      end
    end

    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost: cost
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def current_user? user
    self == user
  end

  def remember
    self.remember_token = User.new_token
    update_attributes remember_digest: User.digest(remember_token)
  end

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attributes remember_digest: nil
  end

  def create_card_token
    self.card_activation_token = User.new_token
    self.card_activation_digest = User.digest(card_activation_token)
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_attributes reset_digest: User.digest(reset_token),
      reset_sent_at: Time.zone.now
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < Settings.EXPIRED_HOUR.hours.ago
  end

  def description
    I18n.t(".terms_of_service")
  end
end
