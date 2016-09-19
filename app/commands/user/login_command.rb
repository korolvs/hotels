# Login command
class User::LoginCommand < Core::Command
  attr_accessor :email, :password

  validate  :if_the_credentials_are_right

  # Sets all services
  # @param [Object] params
  # @see User::UserRepository
  # @see User::TokenRepository
  def initialize(params)
    super(params)
    @user_repository = User::UserRepository.get
    @token_repository = User::TokenRepository.get
  end

  # Checks if the email and password are right
  def if_the_credentials_are_right
    user = @user_repository.find_by_email(email)
    if user
      unless user.password_is_right? password
        errors.add(:email, 'Wrong email or password')
      end
    else
      errors.add(:email, 'Wrong email or password')
    end
  end

  # Rules for authorization
  # @return [Hash]
  def authorization_rules
    { token_type: nil }
  end

  # Runs command
  # @return [Hash]
  def execute
    user = @user_repository.find_by_email(email)
    token = User::Token.new(user, User::Token::TYPE_LOGIN)
    token = @token_repository.save!(token)
    { token: token.code }
  end
end
