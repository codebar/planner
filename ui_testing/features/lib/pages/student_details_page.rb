require 'capybara/dsl'

class Student
  include Capybara::DSL

  FIRSTNAME_ID = 'member_name' unless const_defined?(:FIRSTNAME_ID)
  SURNAME_ID = 'member_surname' unless const_defined?(:SURNAME_ID)
  PRONOUN_ID = 'member_pronouns' unless const_defined?(:PRONOUN_ID)
  EMAIL_ID = 'member_email' unless const_defined?(:EMAIL_ID)
  DESCRIPTION_ID = 'member_about_you' unless const_defined?(:DESCRIPTION_ID)

  def fill_first_name(firstname)
    fill_in(FIRSTNAME_ID, with: firstname)
  end

  def fill_surname(surname)
    fill_in(SURNAME_ID, with: surname)
  end

  def fill_pronouns(pronoun)
    fill_in(PRONOUN_ID, with: pronoun)
  end

  def fill_email(email)
    fill_in(PRONOUN_ID, with: email)
  end

  def fill_description(description)
    fill_in(DESCRIPTION_ID, with: description)
  end

end
