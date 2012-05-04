Given /^I have the following cross question validations$/ do |table|

  table.map_column!('set', false) { |str| str.is_a?(String) ? eval(str) : str }
  table.map_column!('conditional_set', false) { |str| str.is_a?(String) ? eval(str) : str }

  hashes = table.hashes.map do |hash|
    hash.merge 'question_code' => hash.delete('question'), 'related_question_code' => hash.delete('related')
  end

  make_cqvs(hashes)

  CrossQuestionValidation.count.should eq table.hashes.count

end
