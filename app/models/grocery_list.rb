class GroceryList < ApplicationRecord
  belongs_to :user
  
  # Validations
  validates :name, presence: true
  validates :items, presence: true
  
  # Default values
  after_initialize :set_defaults, if: :new_record?
  
  # Instance methods
  def add_item(item_name, quantity = 1, category = 'general')
    current_items = self.items || []
    new_item = {
      name: item_name,
      quantity: quantity,
      category: category,
      completed: false,
      added_at: Time.current
    }
    
    self.items = current_items << new_item
    save
  end
  
  def mark_item_completed(item_name)
    return false unless self.items
    
    self.items.each do |item|
      if item['name'] == item_name
        item['completed'] = true
        item['completed_at'] = Time.current
        break
      end
    end
    
    save
  end

  def mark_item_incomplete(item_name)
    return false unless self.items
    
    self.items.each do |item|
      if item['name'] == item_name
        item['completed'] = false
        item['completed_at'] = nil
        break
      end
    end
    
    save
  end
  
  def completed_items_count
    return 0 unless self.items
    self.items.count { |item| item['completed'] }
  end
  
  def total_items_count
    return 0 unless self.items
    self.items.count
  end
  
  def completion_percentage
    return 0 if total_items_count.zero?
    (completed_items_count.to_f / total_items_count * 100).round(1)
  end
  
  private
  
  def set_defaults
    self.items ||= []
    self.completed ||= false
  end
end
