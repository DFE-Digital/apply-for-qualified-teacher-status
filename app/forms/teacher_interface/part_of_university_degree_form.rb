class TeacherInterface::PartOfUniversityDegreeForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :qualification

  attribute :part_of_university_degree, :boolean

  validates :qualification, presence: true

  def save
    return false unless valid?

    qualification.part_of_university_degree = part_of_university_degree
    qualification.save!
  end
end
