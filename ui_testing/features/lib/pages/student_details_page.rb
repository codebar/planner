require 'capybara/dsl'

class Student
  include Capybara::DSL

  FIRSTNAME_ID = 'First name' unless const_defined?(:FIRSTNAME_ID)
  SURNAME_ID = 'Surname' unless const_defined?(:SURNAME_ID)
  PRONOUN_ID = 'What pronouns o you use?' unless const_defined?(:PRONOUN_ID)
  EMAIL_ID = 'Email Address' unless const_defined?(:EMAIL_ID)
  DESCRIPTION_ID = 'What do you want to work on at codebar? What have you done in the past? Tell us a little about yourself!' unless const_defined?(:DESCRIPTION_ID)

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

  def submit
    click('submit')
  end

  def done
    click_button('Done')
  end

  def find_profile
    find('h2')
  end
end
