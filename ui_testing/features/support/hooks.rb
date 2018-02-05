After ("@sign-up-student") do
  github.visit_github
  github.click_profile_icon
  github.click_sign_out
end

After ("@sub_student") do
  github.visit_github
  github.click_profile_icon
  github.click_sign_out
end

After ("@sign_out") do
  sign_in_page.click_menu_tab
  sign_in_page.click_sign_out_link
end

Before ("@before_hook_sign_out") do
  sign_in_page.click_menu_tab
  sign_in_page.click_sign_out_link
end
