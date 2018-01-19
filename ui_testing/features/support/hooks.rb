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
