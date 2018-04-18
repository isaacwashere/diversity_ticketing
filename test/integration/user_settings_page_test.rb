require 'test_helper'

feature 'User Settings Page' do
  def setup
    @user = make_user
  end

  test 'that name input field is present in settings page and updates user name' do
    sign_in_as_user

    visit root_path

    click_link 'Settings'

    assert page.text.include?('Edit your credentials')
    page.must_have_selector("form input[name='user[name]']")
    page.fill_in 'user_name', with: 'My Name'

    click_button 'Update User'

    assert page.text.include?('You have successfully updated your user data.')
  end
end
