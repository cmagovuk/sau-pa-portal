class AddIssuesLinkToPostReports < ActiveRecord::Migration[6.1]
  def change
    add_column :post_reports, :other_issues_link, :string
  end
end
