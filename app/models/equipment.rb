# = Informations
#
# == License
#
# Ekylibre - Simple ERP
# Copyright (C) 2009-2013 Brice Texier, Thibaud Merigon
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see http://www.gnu.org/licenses.
#
# == Table: products
#
#  active                   :boolean          not null
#  address_id               :integer
#  area_measure             :decimal(19, 4)
#  area_unit                :string(255)
#  asset_id                 :integer
#  born_at                  :datetime
#  content_maximal_quantity :decimal(19, 4)   default(0.0), not null
#  content_nature_id        :integer
#  content_unit             :string(255)
#  created_at               :datetime         not null
#  creator_id               :integer
#  current_place_id         :integer
#  dead_at                  :datetime
#  description              :text
#  external                 :boolean          not null
#  father_id                :integer
#  id                       :integer          not null, primary key
#  identification_number    :string(255)
#  lock_version             :integer          default(0), not null
#  maximal_quantity         :decimal(19, 4)   default(0.0), not null
#  minimal_quantity         :decimal(19, 4)   default(0.0), not null
#  mother_id                :integer
#  name                     :string(255)      not null
#  nature_id                :integer          not null
#  number                   :string(255)      not null
#  owner_id                 :integer          not null
#  parent_id                :integer
#  picture_content_type     :string(255)
#  picture_file_name        :string(255)
#  picture_file_size        :integer
#  picture_updated_at       :datetime
#  real_quantity            :decimal(19, 4)   default(0.0), not null
#  reproductor              :boolean          not null
#  reservoir                :boolean          not null
#  sex                      :string(255)
#  shape                    :spatial({:srid=>
#  tracking_id              :integer
#  type                     :string(255)      not null
#  unit                     :string(255)      not null
#  updated_at               :datetime         not null
#  updater_id               :integer
#  variety                  :string(127)      not null
#  virtual_quantity         :decimal(19, 4)   default(0.0), not null
#  work_number              :string(255)
#


class Equipment < Matter
  attr_accessible :nature_id, :asset_id, :picture, :name, :description, :born_at, :dead_at, :active, :external, :content_unit_id, :content_nature_id, :owner_id, :parent_id, :variety, :reservoir, :content_maximal_quantity
  # has_many :uses, :class_name => "OperationUse"
  # belongs_to :nature, :class_name => "ProductNature"
  # belongs_to :variety, :class_name => "ProductVariety"
  # belongs_to :parent_place, :class_name => "Place"
  belongs_to :owner, :class_name => "Entity"
  # belongs_to :content_nature, :class_name => "Product"
  # belongs_to :content_unit, :class_name => "Unit"
  belongs_to :asset
  #[VALIDATORS[ Do not edit these lines directly. Use `rake clean:validations`.
  #]VALIDATORS]

  default_scope -> { order(:name) }

  #def usage_duration_sum
  #  sum = 0
  # self.uses.each do |usage|
  #    sum += usage.operation.duration
   # end
   # sum/60
  #end

  #def usage_duration
  #  return Operation.sum(:duration, :conditions => ["moved_on IS NOT NULL AND id IN (SELECT operation_id FROM #{OperationUse.table_name} WHERE equipment_id=?)", self.id])
  #end

  #def remaining_duration
  #  return Operation.sum(:duration, :conditions => ["moved_on IS NULL AND id IN (SELECT operation_id FROM #{OperationUse.table_name} WHERE equipment_id=?)", self.id])
  #end

end
