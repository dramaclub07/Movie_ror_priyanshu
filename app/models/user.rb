# app/models/user.rb
class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  # Enums
  enum role: { user: 'user', supervisor: 'supervisor' }

  # Associations
  has_many :subscriptions, dependent: :destroy
  has_many :movies, through: :subscriptions

  has_many :watchlists, dependent: :destroy
  has_many :watchlist_movies, through: :watchlists, source: :movie

  # Validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :phone_number, presence: true, uniqueness: true,
            format: { with: /\A\+?\d{10,14}\z/, message: 'must be a valid phone number' }

  # Callbacks
  after_initialize :set_default_role, if: :new_record?

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name || 'Unknown'
      user.phone_number = '0000000000' # Default value, can be updated later
      user.role = 'user'
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id name email phone_number role created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[subscriptions movies]
  end
  
  def generate_otp
    otp = SecureRandom.random_number(100_000..999_999)
    update(otp: otp, otp_expires_at: 10.minutes.from_now)
    otp
  end

  def verify_otp(otp)
    self.otp == otp && otp_expires_at > Time.now
  end

  def send_email(subject, body)
    Rails.logger.info "Sending email to #{email}: #{subject} - #{body}"
  end

  def admin?
    role == 'admin'
  end

  def supervisor?
    role == 'supervisor'
  end

  private

  def set_default_role
    self.role ||= 'user'
  end

  def social_login?
    google_id.present? || github_id.present?
  end
end