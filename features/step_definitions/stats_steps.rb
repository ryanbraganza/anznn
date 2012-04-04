Then /^I should see survey stats table for "([^"]*)" with$/ do |survey, expected_table|
  table_id = "stats_#{Survey.find_by_name!(survey).id}"

  rows = find("table##{table_id}").all('tr')
  actual = rows.map do |row|
    cells = row.all('th, td')
    # if the cell has a colspan, add in the required number of empty cells so we can still use table diff
    array_of_cells = cells.map do |cell|
      colspan = cell[:colspan]
      if colspan
        [cell.text.strip.gsub("\n\n", " ")] + Array.new((colspan.to_i - 1), "")
      else
        cell.text.strip.gsub("\n\n", " ")
      end

    end
    array_of_cells.flatten
  end

  chatty_diff_table!(expected_table, actual)
end