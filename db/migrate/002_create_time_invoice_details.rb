class CreateTimeInvoiceDetails < ActiveRecord::Migration
  def change
    create_table :time_invoice_details do |t|
      t.references :time_invoice
      t.references :user
      t.float :logged_hours
      t.float :invoiced_hours
      t.float :invoiced_quantity
      t.string :invoiced_unit
      t.text :comment
      t.timestamps
    end
    add_index :time_invoice_details, :time_invoice_id
    add_index :time_invoice_details, :user_id
  end
end
