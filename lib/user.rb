require 'bcrypt'
require 'mailgun'
require 'rest_client'

class User

  include DataMapper::Resource

  property :id,              Serial
  property :email,           String, :unique => true, :message => "This email is already taken"
  property :password_digest, Text
  property :password_token,  Text
  property :password_token_timestamp, Time

  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create(password)
  end

  attr_reader   :password
  attr_accessor :password_confirmation

  validates_confirmation_of :password
  validates_uniqueness_of :email

  def self.authenticate(email, password)
    user = first(:email => email)
    if user && BCrypt::Password.new(user.password_digest) == password
      user
    else
      nil
    end
  end

  def create_token
    (1..64).map{('A'..'Z').to_a.sample}.join
  end

  def send_email(email)
    RestClient.post "https://api:key-c89ad51914e4b9e1831f0a0b5deb070e"\
    "@api.mailgun.net/v2/sandbox08bbde70289b495194ccf3c072fa8621.mailgun.org/messages",
    :from => "Mailgun Sandbox <postmaster@sandbox08bbde70289b495194ccf3c072fa8621.mailgun.org>",
    :to => "emily.bronwen.sas@gmail.com",
    :subject => "Forgotten Password",
    :text => "Please follow the link: \"/users/reset_password/#{@password_token}\" to change your password. This link will expire at #{Time.now+(60*60)}"
  end
end