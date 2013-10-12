class CreateTimeInvoices < ActiveRecord::Migration
  def change
    create_table :time_invoices do |t|
      t.date :start_date
      t.date :end_date
<<<<<<< HEAD
      t.references :project
      t.references :submitted_by
      t.text :comment
      t.timestamps
    end
    add_index :time_invoices, :project_id
    add_index :time_invoices, :submitted_by_id
=======
      t.integer :project_id
      t.integer :submitted_by
      
      t.timestamps
    end
>>>>>>> 7b8cb405674ed3941ef7151d0dc7b29f823cba97
  end
end
