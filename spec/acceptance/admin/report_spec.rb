require File.dirname(__FILE__) + '/../acceptance_helper'

feature "Reports", %q{
  In order to monitor site usage
  As an administrator
  I want to generate reports on site usage in HTML and CSV formats
} do

  scenario "generating analysis/downloads report as HTML" do
    AnuLog.destroy_all
    1.times  { AnuLog.make(:analize)  }
    2.times  { AnuLog.make(:download) }

    @admin = User.find_by_user("administrator") || User.make(:administrator, :user => "administrator")
    log_in_as(@admin)

    [:html, :csv].each do |format|
      visit "/admin/report/new"

      fill_in 'report_start_date', :with => Date.today.strftime('%d-%m-%Y')
      fill_in 'report_end_date', :with => Date.today.strftime('%d-%m-%Y')
      choose 'Analysis/downloads Report'

      # Expected table:
      # | ANALIZE  | 1 |
      # | DOWNLOAD | 2 |

      if format == :html
        click_button 'HTML Report'

        selector_exists?("tr") { |tr| tr.has_selector?("td", :text => "ANALIZE")  and tr.has_selector?("td", :text => "1") }.should be_true
        selector_exists?("tr") { |tr| tr.has_selector?("td", :text => "DOWNLOAD") and tr.has_selector?("td", :text => "2") }.should be_true

      elsif format == :csv
        click_button 'CSV Report'

        page.should have_content "ANALIZE,1"
        page.should have_content "DOWNLOAD,2"
      end
    end
  end
end
