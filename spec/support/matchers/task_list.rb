# frozen_string_literal: true

require "rspec/expectations"

RSpec::Matchers.define :include_task_list_section do |title|
  match do |task_list_sections|
    rendered_sections =
      task_list_sections.filter { |section| section[:items].present? }
    expect(rendered_sections).to include(hash_including(title:))
  end

  match_when_negated do |task_list_sections|
    rendered_sections =
      task_list_sections.filter { |section| section[:items].present? }
    expect(rendered_sections).not_to include(hash_including(title:))
  end
end

RSpec::Matchers.define :include_task_list_item do |section_title, name, **attributes|
  match do |task_list_sections|
    all_items =
      task_list_sections.flat_map do |section|
        section[:items].map do |item|
          item.merge(section_title: section[:title])
        end
      end

    expect(all_items).to include(
      hash_including(section_title:, name:, **attributes),
    )
  end

  match_when_negated do |task_list_sections|
    all_items =
      task_list_sections.flat_map do |section|
        section[:items].map do |item|
          item.merge(section_title: section[:title])
        end
      end
    expect(all_items).not_to include(
      hash_including(section_title:, name:, **attributes),
    )
  end
end
