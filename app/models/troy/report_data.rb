class Troy::ReportData < ActiveRecord::Base
  self.inheritance_column = :_type_disabled
  self.table_name = "troy_report_data"
end