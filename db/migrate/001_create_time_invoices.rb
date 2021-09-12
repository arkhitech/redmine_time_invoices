class CreateTimeInvoices < ActiveRecord::Migration[4.2]
	def change
    create_table :time_invoices do |t|
      t.date :start_date
      t.date :end_date
      t.references :project
      t.references :submitted_by
      t.text :comment
      t.timestamps
    end
    add_index :time_invoices, :project_id
    add_index :time_invoices, :submitted_by_id
  end
end
