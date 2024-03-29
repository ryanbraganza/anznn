class User < ActiveRecord::Base

  STATUS_UNAPPROVED = 'U'
  STATUS_ACTIVE = 'A'
  STATUS_DEACTIVATED = 'D'
  STATUS_REJECTED = 'R'

  # Include devise modules
  devise :database_authenticatable, :registerable, :lockable, :recoverable, :trackable, :validatable, :timeoutable

  belongs_to :role
  has_many :responses
  belongs_to :hospital

  # Setup accessible attributes (status/approved flags should NEVER be accessible by mass assignment)
  attr_accessible :email, :password, :password_confirmation, :first_name, :last_name

  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :status
  validates_presence_of :hospital_id, unless: Proc.new { |user|  user.role.blank? || user.super_user? }

  validates_length_of :first_name, maximum: 255
  validates_length_of :last_name, maximum: 255
  validates_length_of :email, maximum: 255

  with_options if: :password_required? do |v|
    v.validates :password, password_format: true
  end

  before_validation :initialize_status
  before_validation :clear_super_user_hospital

  scope :pending_approval, where(status: STATUS_UNAPPROVED).order(:email)
  scope :approved, where(status: STATUS_ACTIVE).order(:email)
  scope :deactivated_or_approved, where("status = 'D' or status = 'A' ")
  scope :approved_superusers, joins(:role).merge(User.approved).merge(Role.superuser_roles)

  # Override Devise active for authentication method so that users must be approved before being allowed to log in
  # https://github.com/plataformatec/devise/wiki/How-To:-Require-admin-to-activate-account-before-sign_in
  def active_for_authentication?
    super && approved?
  end

  # Override Devise method so that user is actually notified right after the third failed attempt.
  def attempts_exceeded?
    self.failed_attempts >= self.class.maximum_attempts
  end

  # Overrride Devise method so we can check if account is active before allowing them to get a password reset email
  def send_reset_password_instructions
    if approved?
      generate_reset_password_token!
      ::Devise.mailer.reset_password_instructions(self).deliver
    else
      if pending_approval? or deactivated?
        Notifier.notify_user_that_they_cant_reset_their_password(self).deliver
      end
    end
  end

  # Custom method overriding update_with_password so that we always require a password on the update password action
  # Devise expects the update user and update password to be the same screen so accepts a blank password as indicating that
  # the user doesn't want to change it
  def update_password(params={})
    current_password = params.delete(:current_password)

    result = if valid_password?(current_password)
               update_attributes(params)
             else
               self.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
               self.attributes = params
               false
             end

    clean_up_passwords
    result
  end

  # Override devise method that resets a forgotten password, so we can clear locks on reset
  def reset_password!(new_password, new_password_confirmation)
    self.password = new_password
    self.password_confirmation = new_password_confirmation
    clear_reset_password_token if valid?
    if valid?
      unlock_access! if access_locked?
    end
    save
  end


  def approved?
    self.status == STATUS_ACTIVE
  end

  def pending_approval?
    self.status == STATUS_UNAPPROVED
  end

  def deactivated?
    self.status == STATUS_DEACTIVATED
  end


  def rejected?
    self.status == STATUS_REJECTED
  end

  def deactivate
    self.status = STATUS_DEACTIVATED
    save!(validate: false)
  end

  def activate
    self.status = STATUS_ACTIVE
    save!(validate: false)
  end

  def approve_access_request
    self.status = STATUS_ACTIVE
    save!(validate: false)

    # send an email to the user
    Notifier.notify_user_of_approved_request(self).deliver
  end

  def reject_access_request
    self.status = STATUS_REJECTED
    save!(validate: false)

    # send an email to the user
    Notifier.notify_user_of_rejected_request(self).deliver
  end

  def notify_admin_by_email
    Notifier.notify_superusers_of_access_request(self).deliver
  end

  def check_number_of_superusers(id, current_user_id)
    current_user_id != id.to_i or User.approved_superusers.length >= 2
  end

  def self.get_superuser_emails
    approved_superusers.collect { |u| u.email }
  end

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def super_user?
    return false unless self.role.present?
    self.role.super_user?
  end

  #class method to do the same thing
  def self.super_user? (user)
    return false unless user.role.present?
    user.role.super_user?
  end

  private

  def clear_super_user_hospital
    self.hospital = nil if self.super_user?
  end

  def initialize_status
    self.status = STATUS_UNAPPROVED unless self.status
  end

end
