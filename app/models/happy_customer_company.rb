class HappyCustomerCompany < ApplicationRecord
  include SetsHappyCompany
  self.table_name = "happy_customer_companies"

  # Associations
  #belongs_to :happy_company, optional: true # tenant/org (you said only one tenant now)
  has_many :happy_customers, dependent: :nullify
  has_many :happy_quotes, through: :happy_customers

  # Scope
  scope :active, -> { where(active: true) }

  # Normalization (for duplicate prevention)
  before_validation :normalize_name

  validates :company_name, presence: true

  # If you add company_name_normalized + unique index:

  validates :company_name_normalized,
  uniqueness: {
    scope: :happy_company_id,
    message: "already exists (try searching and using the existing company)"
  },
  allow_nil: true

  validates :customer_street1, :customer_city, :customer_state, :customer_zipcode,
  presence: true,
  if: -> { customer_street1.present? || customer_city.present? || customer_state.present? || customer_zipcode.present? }

  validates :customer_zipcode,
  format: { with: /\A\d{5}(-\d{4})?\z/, message: "must be 5 digits (or 5+4)" },
  allow_blank: true

  scope :active, -> { where(active: true) }

  private

  def normalize_name
    self.company_name_normalized =
      company_name.to_s.downcase.gsub(/[^a-z0-9]+/, " ").strip
  end
end

