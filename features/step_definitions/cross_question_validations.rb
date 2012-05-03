Given /^I have the following cross question validations$/ do |table|

  table.map_column!('set', false) { |str| str.is_a?(String) ? eval(str) : str }
  table.map_column!('conditional_set', false) { |str| str.is_a?(String) ? eval(str) : str }

  label_to_cqv_id = {}

  # store the labelled (secondary) rules first
  table.hashes.each do |hash|
    related_rule_labels = hash['rule_label_list']
    make_cqv(label_to_cqv_id, hash) unless related_rule_labels.present?
  end

  #now store any rules which reference labelled rules
  table.hashes.each do |hash|
    related_rule_labels = hash['rule_label_list']
    make_cqv(label_to_cqv_id, hash) if related_rule_labels.present?
  end

end

def make_cqv(label_to_cqv_id, hash)

  related_question_question = hash.delete 'related'
  related_rule_labels = hash.delete 'rule_label_list'
  question_list = hash.delete 'related_question_list'
  question_question = hash.delete 'question'
  label = hash.delete 'rule_label'

  hash[:related_question] = related_question_question.blank? ? nil : Question.find_by_question!(related_question_question)

  if question_list
    hash[:related_question_ids] = question_list.split(", ").map { |qn_code| Question.find_by_question!(qn_code).id }
  end


  if related_rule_labels
    hash[:related_rule_ids] = related_rule_labels.split(', ').map { |related_label| label_to_cqv_id[related_label] }
  end

  hash[:question] = Question.find_by_question! question_question

  validation = Factory(:cross_question_validation, hash)
  label_to_cqv_id[label] = validation.id
end
