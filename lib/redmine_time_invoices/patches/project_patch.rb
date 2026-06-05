module RedmineTimeInvoices
  module Patches
    module ProjectPatch
      def self.included(base)
        base.class_eval do
          has_many :time_invoices
        end
      end
    end
  end
end