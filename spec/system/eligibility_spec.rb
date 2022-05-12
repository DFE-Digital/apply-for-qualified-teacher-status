# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Eligibility check', type: :system do
  it 'happy path' do
    when_i_visit_the_start_page
    then_i_see_the_start_page

    when_i_press_continue
    then_i_see_the_eligible_page
  end

  private

  def when_i_press_continue
    click_link 'Continue'
  end

  def when_i_visit_the_start_page
    visit '/teacher'
  end

  def then_i_see_the_eligible_page
    expect(page).to have_content('You might be eligible to apply for QTS')
  end

  def then_i_see_the_start_page
    expect(page).to have_content('Apply for qualified teacher status')
    expect(page).to have_content('Teacher training in England leads to qualified teacher status (QTS). QTS is a legal requirement to teach in many English schools.')
  end
end
