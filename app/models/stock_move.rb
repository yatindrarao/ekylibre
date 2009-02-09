# == Schema Information
# Schema version: 20081111111111
#
# Table name: stock_moves
#
#  id                 :integer       not null, primary key
#  name               :string(255)   not null
#  planned_on         :date          not null
#  moved_on           :date          
#  quantity           :float         not null
#  comment            :text          
#  second_move_id     :integer       
#  second_location_id :integer       
#  tracking_id        :integer       
#  location_id        :integer       not null
#  unit_id            :integer       not null
#  product_id         :integer       not null
#  company_id         :integer       not null
#  created_at         :datetime      not null
#  updated_at         :datetime      not null
#  created_by         :integer       
#  updated_by         :integer       
#  lock_version       :integer       default(0), not null
#

class StockMove < ActiveRecord::Base
  attr_readonly :company_id

  def before_validation
    self.unit_id = self.product.unit_id if self.product and self.unit.nil?
  end
  

end
