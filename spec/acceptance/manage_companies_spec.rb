require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature 'manage companies' do

  context 'unauthenticated user' do

    scenario 'cannot manage companies' do
      visit '/'
      find('#companies_button').click
      page.should_not have_link 'New Company'
      page.should_not have_link 'Edit'
      page.should_not have_link 'Destroy'
    end

  end # context

  context 'regular user' do

    scenario 'can create new company' do
      company = Company.make(:name => "Dabee")
      market = Market.make!
      location = Location.make!
      login_normal
      click_link 'Companies'
      click_button 'New Company'
      fill_in 'Name', :with => company.name
      fill_in 'Description', :with => company.description
      fill_in 'Website', :with => company.website
      fill_in 'Linkedin', :with => company.linkedin
      select 'active', :from => 'Status'
      select market.name, :from => 'Markets'
      select location.full, :from => 'Locations'
      expect do
        click_button 'Create Company'
      end.to change {Company.count}.by(1)
      page.should have_content 'Company was successfully created.'
      page.should have_content company.name
      uri = URI.parse(current_url)
      uri.path.should == "/companies/dabee"
    end

    scenario 'can edit companies' do
      company = Company.make!
      new_name = "#{company.name} Clone"
      login_normal
      click_link 'Companies'
      click_button "edit_#{company.id}"
      fill_in ' Name', :with => new_name
      expect do
        click_button 'Update Company'
      end.to change {Company.count}.by(0)
      page.should have_content 'Company was successfully updated.'
      page.should have_content new_name
    end

    scenario 'can delete companies' do
      company = Company.make!
      login_normal
      click_link 'Companies'
      expect do
        click_button "destroy_#{company.id}"
      end.to change {Company.count}.by(-1)
      page.should have_content 'Company was successfully deleted.'
      page.should_not have_content company.name
      uri = URI.parse(current_url)
      uri.path.should == '/companies'
    end

  end # context

end # feature
