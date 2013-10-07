class CreateTimeInvoices < ActiveRecord::Migration
  def change
    create_table :time_invoices do |t|
      t.date :start_date
      t.date :end_date
      t.integer :project_id
      t.integer :submitted_by
      
      t.timestamps
    end
  end
end
