class AddInvoiceIdToTimeInvoices < ActiveRecord::Migration[4.2]
	def change
    add_column :time_invoices, :invoice_id, :integer
  end
end