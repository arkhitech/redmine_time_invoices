class AddInvoiceIdToTimeInvoices < ActiveRecord::Migration
  def change
    add_column :time_invoices, :invoice_id, :integer
  end
end