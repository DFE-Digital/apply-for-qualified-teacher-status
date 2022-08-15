class TeacherInterface::NewSessionForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :email, :string
  attribute :create_or_sign_in, :string

  validates :create_or_sign_in, presence: true
  validates :email, presence: true, valid_for_notify: true, if: -> { sign_in? }

  def sign_in?
    create_or_sign_in == "sign_in"
  end

  def create?
    create_or_sign_in == "create"
  end
end
