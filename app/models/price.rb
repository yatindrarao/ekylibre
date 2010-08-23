# = Informations
# 
# == License
# 
# Ekylibre - Simple ERP
# Copyright (C) 2009-2010 Brice Texier, Thibaud Mérigon
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
# == Table: prices
#
#  active            :boolean          default(TRUE), not null
#  amount            :decimal(16, 4)   not null
#  amount_with_taxes :decimal(16, 4)   not null
#  by_default        :boolean          default(TRUE)
#  category_id       :integer          
#  company_id        :integer          not null
#  created_at        :datetime         not null
#  creator_id        :integer          
#  currency_id       :integer          
#  entity_id         :integer          
#  id                :integer          not null, primary key
#  lock_version      :integer          default(0), not null
#  product_id        :integer          not null
#  quantity_max      :decimal(16, 4)   default(0.0), not null
#  quantity_min      :decimal(16, 4)   default(0.0), not null
#  started_at        :datetime         
#  stopped_at        :datetime         
#  tax_id            :integer          not null
#  updated_at        :datetime         not null
#  updater_id        :integer          
#  use_range         :boolean          not null
#

class Price < ActiveRecord::Base
  after_save :set_by_default
  attr_readonly :company_id # , :started_at, :amount, :amount_with_taxes
  belongs_to :category, :class_name=>EntityCategory.name
  belongs_to :company
  belongs_to :currency
  belongs_to :entity
  belongs_to :product
  belongs_to :tax
  has_many :delivery_lines
  has_many :invoice_lines
  has_many :taxes
  has_many :purchase_order_lines
  has_many :sale_order_lines
  validates_presence_of :category_id, :if=>Proc.new{|price| price.entity_id == price.company.entity_id}
  validates_presence_of :currency_id, :product_id, :entity_id
  validates_numericality_of :amount, :greater_than_or_equal_to=>0
  validates_numericality_of :amount_with_taxes, :greater_than_or_equal_to=>0

  def prepare
    self.company_id  ||= self.product.company_id if self.product
    if self.company
      self.currency_id ||= self.company.currencies.first.id 
      self.entity_id ||=  self.company.entity_id
    end
    if self.amount_with_taxes.to_f > 0
      self.amount_with_taxes = self.amount_with_taxes.round(2)
      tax_amount = (self.tax ? self.tax.compute(self.amount_with_taxes, true) : 0)
      self.amount = self.amount_with_taxes - tax_amount.round(2)
    else  # if self.amount.to_f >= 0 
      tax_amount = (self.tax ? self.tax.compute(self.amount) : 0).to_f
      self.amount_with_taxes = (self.amount.to_f+tax_amount).round(2)
      self.amount = self.amount_with_taxes.to_f - tax_amount.round(2)
    end
    self.started_at = Time.now
    self.quantity_min ||= 0
    self.quantity_max ||= 0
  end

  def check
    #   if self.use_range
    #       price = self.company.prices.find(:first, :conditions=>["(? BETWEEN quantity_min AND quantity_max OR ? BETWEEN quantity_min AND quantity_max) AND product_id=? AND list_id=? AND id!=?", self.quantity_min, self.quantity_max, self.product_id, self.list_id, self.id])
    #       errors.add_to_base(:range_overlap, :min=>price.quantity_min, :max=>price.quantity_max) unless price.nil?
    #     else
    #       errors.add_to_base(:already_defined) unless self.company.prices.find(:first, :conditions=>["NOT use_range AND product_id=? AND stopped_on IS NULL AND list_id=? AND id!=COALESCE(?,0)", self.product_id, self.list_id, self.id]).nil?
    #     end
  end

  def update # _without_callbacks
    current_time = Time.now
    stamper_id = self.class.stamper_class.stamper.id rescue nil
    nc = self.class.create!(self.attributes.delete_if{|k,v| [:company_id].include?(k.to_sym)}.merge(:started_at=>current_time, :created_at=>current_time, :updated_at=>current_time, :creator_id=>stamper_id, :updater_id=>stamper_id, :active=>true))
    self.class.update_all({:stopped_at=>current_time, :active=>false}, {:id=>self.id})
    return nc
  end

  def destroy # _without_callbacks
    unless new_record?
      current_time = Time.now
      self.class.update_all({:stopped_at=>current_time, :active=>false}, {:id=>self.id})
    end
  end

  def set_by_default
    Price.update_all({:by_default=>false}, ["product_id=? AND company_id=? AND id!=? AND entity_id=?", self.product_id, self.company_id, self.id||0, self.company.entity_id]) if self.by_default
  end
  
  def refresh
    self.save
  end

  def change(amount, tax_id)
    conditions = {:product_id=>self.product_id, :amount=>amount, :tax_id=>tax_id, :active=>true, :entity_id=>self.entity_id, :currency_id=>self.currency_id, :category_id=>self.category_id}
    price = self.company.prices.find(:first, :conditions=>conditions)
    if price.nil?
      self.update_attribute(:active, false)
      price = self.company.prices.create!(conditions)
    end
    price
  end

#   def all_taxes(company, options={})
#     if self.new_record?
#       options[:select] = "taxes.*, #{connection.quoted_false} AS used"      
#     else
#       options[:select] = "taxes.*, (pt.id IS NOT NULL) AS used"
#       options[:joins]  = " LEFT JOIN price_taxes AS pt ON (taxes.id=tax_id)"
#       options[:conditions]  = {:price_id=>self.id}
#     end
#     company.taxes.find(:all, options)
#   end


  def range
    if self.use_range
      tc(:range, :min=>self.quantity_min, :max=>self.quantity_max)
    else
      tc(:no_range)
    end
  end

  def label
    tc(:label, :product=>self.product.name, :amount=>self.amount, :currency=>self.currency.code)
  end

end
