# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  email           :string           not null
#  password_digest :string           not null
#  session_token   :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null


# require 'bcrypt'

class User < ApplicationRecord

    before_validation :ensure_session_token
    validates :email, :session_token, presence: true, uniqueness: true
    validates :password_digest, presence: true
    validates :password, length: { minimum: 4 }, allow_nil: true

    attr_reader :password

    def self.find_by_credentials(email, password)
        # look up by username (can index this)
        # password is used to confirm that the person who is signing in
        # owns the account, will probably call #is_password? here
        user = User.find_by(email: email)

        # if user EXISTS and the password matches the input password
        # return user, otherwise return nil
        if user && user.is_password?(password)
            user
        else
            nil
        end
    end

    def password=(password)
        self.password_digest = BCrypt::Password.create(@password)
        @password = password
    end

    def is_password?(password)
        password_object = BCrypt::Password.new(self.password_digest)
        password_object.is_password?(password)
        # is.password? is a Password method that checks if whatever you pass into it
        # when given the same salt and number of itterations of BCrypt produces the
        # same hashed value as password_object (or whatever variable you call it on).
    end

    def generate_unique_session_token
        loop do
            session_token = SecureRandom.urlsafe_base64
            return session_token unless User.exists?(session_token: session_token)
        end
    end

    def reset_session_token!
        self.session_token = generate_unique_session_token
        self.save!
        self.session_token
    end

    def ensure_session_token
        self.session_token ||= generate_unique_session_token
    end
end