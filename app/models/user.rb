class User < ApplicationRecord
  extend FriendlyId
  attr_accessor :remember_token, :card_activation_token, :reset_token
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable,
    :confirmable, :lockable
  devise :omniauthable, omniauth_providers: %i(facebook google_oauth2 twitter)

  enum role: {admin: 0, librarian: 1, user: 2}

  acts_as_paranoid

  has_one :card, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :notifications, dependent: :destroy

  scope :all_user, ->{select :id, :name, :email}

  paginates_per Settings.OBJECT_PER_PAGE

  validates :terms_of_service, acceptance: {accept: true}

  delegate :id, to: :card, prefix: true, allow_nil: true
  delegate :issued_date, to: :card, prefix: true, allow_nil: true
  delegate :expired_date, to: :card, prefix: true, allow_nil: true

  friendly_id :name, use: :slugged

  class << self
    def from_omniauth auth
      where(provider: auth.provider,
        uid: auth.uid).first_or_create do |user|
        user.email = auth.info.email
        user.password = Devise.friendly_token[0, 20]
        user.name = auth.info.name
        user.skip_confirmation!
      end
    end

    def new_with_session params, session
      super.tap do |user|
        if data = session["devise.facebook_data"] &&
          session["devise.facebook_data"]["extra"]["raw_info"]
          user.email = data["email"] if user.email.blank?
        end
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

  def unread_notifications_count
    notifications.unread.count
  end
end
