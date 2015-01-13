require 'bcrypt'

class User

  include DataMapper::Resource

  property :id, Serial
  property :email, String

  # this will store both the password and the salt
  # It's Text and not String because String holds
  # 50 chars by default - not enough for hash + salt
  property :password_digest, Text

  # when assigned the password, we don't store it directly
  # instead, we generate a digest "!@£$16514234qlkaSDdd%.fdq3412qr.@£%!"
  # and save it in the database. This digest, provided by bcrypt,
  # has both the password hash and the salt. 

  def password=(password)
    self.password_digest = BCrypt::Password.create(password)
  end

end