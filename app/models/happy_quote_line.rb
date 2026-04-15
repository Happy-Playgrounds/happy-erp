class HappyQuoteLine < ApplicationRecord

  attr_accessor :quote_subtotal
  attr_accessor :quote_margin
  attr_accessor :cost_override
  #before_save :total_line_amount
  before_validation :normalize_line_product_listing
  belongs_to :happy_quote
  acts_as_list scope: :happy_quote 
  belongs_to :happy_vendor
   
  validates :description,         presence: true
  validates :quantity,            presence: true, numericality: true
  validates :weight,              presence: true, numericality: true
  validates :unit_of_measure,     presence: true
  validates :unit_price,          presence: true, numericality: true
  validates :buyout_unit_price,   presence: true, numericality: true
  validate :unit_price_greater_buyout_unit_price

  # below are new setters for currency fields

  def unit_price=(num)
      num.gsub!(',','') if num.is_a?(String)
      self[:unit_price] = num.to_d
  end

  def buyout_unit_price=(num)
      num.gsub!(',','') if num.is_a?(String)
      self[:buyout_unit_price] = num.to_d
  end

  def total_line_amount=(num)
      num.gsub!(',','') if num.is_a?(String)
      self[:total_line_amount] = num.to_d
  end

  def total_cost_amount=(num)
      num.gsub!(',','') if num.is_a?(String)
      self[:total_cost_amount] = num.to_d
  end

  def tax_amount=(num)
      num.gsub!(',','') if num.is_a?(String)
      self[:tax_amount] = num.to_d
  end

  #validates :fruit,       presence: true, exclusion_array: { in: User::FRUIT.first, presence: true, deny_blank: true }
  #validates :music,       presence: true, exclusion_array: { in: User::MUSIC.first, presence: true, deny_blank: true }
  #validates :language,    inclusion: { in: User::LANGUAGE.map(&:to_s) }
  #validates :pill,        inclusion: { in: [User::PILL.first.to_s] } 
  #validates :choises,     presence: true, exclusion_array: { in: User::CHOISES.first, presence: true, deny_blank: true }
  #validates :active,      presence: true, acceptance: true
  #validates :friends,     numericality: { only_integer: true, greater_than: 1, less_than: 10_000 }
  #validates :mood,        numericality: { only_integer: true, greater_than: 50, less_than_or_equal_to: 100 } 
  #validates :awake,       presence: true, timeliness: { type: :time, before: '12:00' }
  #validates :first_kiss,  presence: true, timeliness: { type: :datetime, after: '20:00' }
  #validates :terms,       acceptance: true

private

def unit_price_greater_buyout_unit_price
  puts "model cost_override"
  puts cost_override
  if unit_price > 0
    errors.add(:unit_price, "must be greater that unit cost") unless
    ((buyout_unit_price <= unit_price) || cost_override == "1")
  end
end

def normalize_line_product_listing
  self.description = description&.upcase
  self.product_id = product_id&.upcase
end

end
