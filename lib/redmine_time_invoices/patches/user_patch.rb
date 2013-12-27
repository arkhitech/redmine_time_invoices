module RedmineTimeInvoices
  module Patches
    module UserPatch
      def self.included(base)
        base.class_eval do
          unloadable
          has_many :time_invoices, :foreign_key => 'submitted_by_id', :class_name => "TimeInvoice"
          has_many :time_invoice_details
        end
      end
    end
  end
end