# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Eligibility check', type: :system do
  it 'happy path' do
    when_i_visit_the_start_page
    then_i_see_the_start_page

    when_i_press_continue
    then_i_see_the_clean_record_page

    when_i_choose_yes
    and_i_submit
    then_i_see_the_eligible_page
  end

  private

  def and_i_submit
    click_button 'Continue', visible: false
  end

  def when_i_choose_yes
    choose 'Yes', visible: false
  end

  def when_i_press_continue
    click_link 'Continue'
  end

  def when_i_visit_the_start_page
    visit '/teacher'
  end

  def then_i_see_the_clean_record_page
    expect(page).to have_current_path('/teacher/misconduct')
    expect(page).to have_content('Is your employment record as a teacher free of sanctions?')
  end

  def then_i_see_the_eligible_page
    expect(page).to have_current_path('/teacher/eligible')
    expect(page).to have_content('You might be eligible to apply for QTS')
  end

  def then_i_see_the_start_page
    expect(page).to have_content('Apply for qualified teacher status')
    expect(page).to have_content('Teacher training in England leads to qualified teacher status (QTS). QTS is a legal requirement to teach in many English schools.')
  end
end
