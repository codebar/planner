
After('@sign_out_after_if_possible') do
  sign_in_page.sign_out_if_possible
  github_logout_page.github_logout_if_possible
end
