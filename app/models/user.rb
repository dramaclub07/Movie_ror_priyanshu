class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  # Enums
  enum role: { user: 'user', supervisor: 'supervisor' }

  # Associations
  has_many :subscriptions, dependent: :destroy
  has_many :watchlists, dependent: :destroy
  has_many :watchlist_movies, through: :watchlists, source: :movie

  # Validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :phone_number, presence: true, uniqueness: true,
                           format: { with: /\A[6789]\d{9}\z/, message: 'must be a valid 10-digit Indian phone number starting with 6, 7, 8, or 9' }
  validates :stripe_customer_id, uniqueness: true, allow_nil: true

  # Callbacks
  after_initialize :set_default_role, if: :new_record?

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name || 'Unknown'
      user.phone_number = '6789012345' # Valid Indian number
      user.role = 'user'
    end
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[id name email phone_number role created_at updated_at stripe_customer_id]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[subscriptions watchlists watchlist_movies]
  end

  def generate_otp
    otp = SecureRandom.random_number(100_000..999_999)
    update(otp: otp, otp_expires_at: 10.minutes.from_now)
    otp
  end

  def verify_otp(otp)
    self.otp == otp && otp_expires_at > Time.now
  end

  def log_email(subject, body)
    Rails.logger.info "Logging email to #{email}: #{subject} - #{body}"
  end

  def supervisor?
    role == 'supervisor'
  end

  # Fix for inspection error
  def inspect
    "#<#{self.class} id: #{id}, email: #{email.inspect}, name: #{name.inspect}, role: #{role.inspect}, stripe_customer_id: #{stripe_customer_id.inspect}>"
  end

  private

  def set_default_role
    self.role ||= 'user'
  end
end