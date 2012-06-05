require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature 'manage users' do
  
  context 'logged as admin' do

    scenario 'edit user role' do
      user = User.make!
      admin = login_admin
      click_link 'Admin'
      click_link 'Edit'
      page.should have_content 'Users#edit'
      page.should have_field 'Full name', :with => user.full_name
      select 'Moderator', :from => 'Role'
      click_button 'Submit'
      page.should have_content 'User was successfully updated.'      
      page.should have_content 'Role: moderator'
    end
  end

  context 'logged as normal' do

    scenario 'cannot access users' do
      normal = login_normal
      normal.role.should_not == 'admin'
      page.should_not have_link 'Admin'
    end    
  end 

end 




