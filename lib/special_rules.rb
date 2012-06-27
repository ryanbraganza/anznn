class SpecialRules
  GEST_CODE = 'Gest'
  GEST_DAYS_CODE = 'GestDays'
  DOB_CODE = 'DOB'
  LAST_O2_CODE = 'LastO2'
  CEASE_CPAP_DATE_CODE = 'CeaseCPAPDate'
  CEASE_HI_FLO_DATE_CODE = 'CeaseHiFloDate'
  HOME_DATE_CODE = 'HomeDate'

  def self.register_additional_rules
    # put special rules here that aren't part of the generic rule set, that way they can easily be removed or replaced later
    CrossQuestionValidation.rules_with_no_related_question += %w(special_dob
                                 special_rop_prem_rop_vegf_1
                                 special_rop_prem_rop_vegf_2
                                 special_rop_prem_rop
                                 special_rop_prem_rop_retmaturity
                                 special_rop_prem_rop_roprx_1
                                 special_rop_prem_rop_roprx_2
                                 special_namesurg2
                                 special_namesurg3
                                 special_immun
                                 special_cool_hours
                                 special_date_of_assess
                                 special_height
                                 special_length
                                 special_cochimplt
                                 special_o2_a
                                 special_hmeo2
                                 special_same_name_linf)

    CrossQuestionValidation.register_checker 'special_o2_a', lambda { |answer, unused_related_answer, checker_params|
      raise 'Can only be used on question O2_36wk_' unless answer.question.code == 'O2_36wk_'
  
      #If O2_36wk_ is -1 and (Gest must be <32 or Wght must be <1500) and (Gest+Gestdays + weeks(DOB and the latest date of (LastO2|CeaseCPAPDate|CeaseHiFloDate))) >36
      break true unless (answer.comparable_answer == -1)
  
      # ok if not premature
      break true unless CrossQuestionValidation.check_gest_wght(answer)
  
      gest = answer.response.comparable_answer_or_nil_for_question_with_code(GEST_CODE)
      gest_days = answer.response.comparable_answer_or_nil_for_question_with_code(GEST_DAYS_CODE)
      dob = answer.response.comparable_answer_or_nil_for_question_with_code(DOB_CODE)
  
      last_o2 = answer.response.comparable_answer_or_nil_for_question_with_code(LAST_O2_CODE)
      cease_cpap_date = answer.response.comparable_answer_or_nil_for_question_with_code(CEASE_CPAP_DATE_CODE)
      cease_hi_flo_date = answer.response.comparable_answer_or_nil_for_question_with_code(CEASE_HI_FLO_DATE_CODE)
  
      break false unless dob.present?
      break false unless gest.present?
      break false unless gest_days.present?
      break false unless last_o2.present? || cease_cpap_date.present || cease_hi_flo_date.present?
  
      dates = [last_o2, cease_cpap_date, cease_hi_flo_date]
      last_date = dates.compact.sort.last
      max_elapsed = last_date - dob
  
      #The actual test (gest in in weeks)
  
      gest.weeks + gest_days.days + max_elapsed.to_i.days > 36.weeks
  
    }
    
    CrossQuestionValidation.register_checker 'special_hmeo2', lambda { |answer, unused_related_answer, checker_params|
      raise 'Can only be used on question HmeO2' unless answer.question.code == 'HmeO2'
      # If HmeO2 is -1 and (Gest must be <32 or Wght must be <1500) and HomeDate must be a date and HomeDate must be the same as LastO2
  
      home_date = answer.response.comparable_answer_or_nil_for_question_with_code(HOME_DATE_CODE)
      last_o2 = answer.response.comparable_answer_or_nil_for_question_with_code(LAST_O2_CODE)
  
      #Conditions (IF)
  
      break true unless (answer.comparable_answer == -1) # ok if not -1
      break true unless CrossQuestionValidation.check_gest_wght(answer) # ok if not premature
  
      #Requirements (THEN)
  
      break false unless home_date.present? # bad if homedate blank
      break false unless last_o2.present?
      break false unless last_o2.eql? home_date
  
      true
    }
  
    CrossQuestionValidation.register_checker 'special_dob', lambda { |answer, unused_related_answer, checker_params|
      answer.date_answer.year == answer.response.year_of_registration
    }
  
    CrossQuestionValidation.register_checker 'special_rop_prem_rop_vegf_1', lambda { |answer, ununused_related_answer, checker_params|
      #If ROPeligibleExam is -1 and (Gest is <32|Wght is <1500) and ROP is between 1 and 4, ROP_VEGF must be 0 or -1
  
      # if the answer is 0 or -1, no need to check further
      break true if [0, -1].include?(answer.comparable_answer)
  
      break true unless answer.response.comparable_answer_or_nil_for_question_with_code('ROPeligibleExam') == -1
      break true unless (1..4).include?(answer.response.comparable_answer_or_nil_for_question_with_code('ROP'))
      break true unless CrossQuestionValidation.check_gest_wght(answer)
      # if we get here, all the conditions are met, and ROP_VEGF is not 0 or -1, so its an error
      false
    }
  
    CrossQuestionValidation.register_checker 'special_rop_prem_rop_vegf_2', lambda { |answer, ununused_related_answer, checker_params|
      #If ROPeligibleExam is -1 and (Gest is <32|Wght is <1500) and ROP is 0, ROP_VEGF must be 0
  
      # if the answer is 0, no need to check further
      break true if answer.comparable_answer == 0
  
      break true unless answer.response.comparable_answer_or_nil_for_question_with_code('ROPeligibleExam') == -1
      break true unless answer.response.comparable_answer_or_nil_for_question_with_code('ROP') == 0
      break true unless CrossQuestionValidation.check_gest_wght(answer)
      # if we get here, all the conditions are met, and ROP_VEGF is not 0, so its an error
      false
    }
  
    CrossQuestionValidation.register_checker 'special_rop_prem_rop', lambda { |answer, ununused_related_answer, checker_params|
      #If ROPeligibleExam is -1 and (Gest is <32|Wght is <1500), ROP must be between 0 and 4
  
      # if the answer is 1..4, no need to check further
      break true if (0..4).include?(answer.comparable_answer)
  
      break true unless answer.response.comparable_answer_or_nil_for_question_with_code('ROPeligibleExam') == -1
      break true unless CrossQuestionValidation.check_gest_wght(answer)
      # if we get here, all the conditions are met, and ROP is not 0..4, so its an error
      false
    }
  
    CrossQuestionValidation.register_checker 'special_rop_prem_rop_retmaturity', lambda { |answer, ununused_related_answer, checker_params|
      #If ROPeligibleExam is -1 and (Gest is <32|Wght is <1500) and ROP is between 0 and 4, Retmaturity must be -1 or 0
  
      # if the answer is -1 or 0, no need to check further
      break true if [0, -1].include?(answer.comparable_answer)
  
      break true unless answer.response.comparable_answer_or_nil_for_question_with_code('ROPeligibleExam') == -1
      break true unless (0..4).include?(answer.response.comparable_answer_or_nil_for_question_with_code('ROP'))
      break true unless CrossQuestionValidation.check_gest_wght(answer)
      # if we get here, all the conditions are met, and ROP is not 1..4, so its an error
      false
    }
  
    CrossQuestionValidation.register_checker 'special_rop_prem_rop_roprx_1', lambda { |answer, ununused_related_answer, checker_params|
      #If ROPeligibleExam is -1 and (Gest is <32|Wght is <1500) and ROP is 0 or 1 or 5, ROPRx must be 0
  
      # if the answer is -1 or 0, no need to check further
      break true if answer.comparable_answer == 0
  
      break true unless answer.response.comparable_answer_or_nil_for_question_with_code('ROPeligibleExam') == -1
      break true unless [0, 1, 5].include?(answer.response.comparable_answer_or_nil_for_question_with_code('ROP'))
      break true unless CrossQuestionValidation.check_gest_wght(answer)
      # if we get here, all the conditions are met, and ROP is not 1..4, so its an error
      false
    }
  
    CrossQuestionValidation.register_checker 'special_rop_prem_rop_roprx_2', lambda { |answer, ununused_related_answer, checker_params|
      #If ROPeligibleExam is -1 and (Gest is <32|Wght is <1500) and ROP is 3 or 4, ROPRx must be -1
  
      # if the answer is -1 or 0, no need to check further
      break true if answer.comparable_answer == -1
  
      break true unless answer.response.comparable_answer_or_nil_for_question_with_code('ROPeligibleExam') == -1
      break true unless [3, 4].include?(answer.response.comparable_answer_or_nil_for_question_with_code('ROP'))
      break true unless CrossQuestionValidation.check_gest_wght(answer)
      # if we get here, all the conditions are met, and ROP is not 1..4, so its an error
      false
    }
    
    CrossQuestionValidation.register_checker 'special_usd6wk_dob_weeks', lambda { |answer, related_answer, checker_params|
      break true unless related_answer.comparable_answer.present?
      dob = answer.response.comparable_answer_or_nil_for_question_with_code(DOB_CODE)
      break true unless dob
      break true unless CrossQuestionValidation.set_meets_condition?(checker_params[:conditional_set], checker_params[:conditional_set_operator], related_answer.comparable_answer)
      break true unless CrossQuestionValidation.check_gest_wght(answer)
      break false unless answer.comparable_answer.present? # Fail if all conditions have been met so far, but we don't have an answer yet.
  
      elapsed_weeks = (answer.comparable_answer - dob).abs.days / 1.week
      CrossQuestionValidation.set_meets_condition?(checker_params[:set], checker_params[:set_operator], elapsed_weeks)
    }
  
    CrossQuestionValidation.register_checker 'special_namesurg2', lambda { |answer, ununused_related_answer, checker_params|
      #If DateSurg2=DateSurg1, NameSurg2 must not be the same as NameSurg1 (rule is on NameSurg2)
      raise 'Can only be used on question NameSurg2' unless answer.question.code == 'NameSurg2'
  
      datesurg1 = answer.response.comparable_answer_or_nil_for_question_with_code('DateSurg1')
      datesurg2 = answer.response.comparable_answer_or_nil_for_question_with_code('DateSurg2')
      break true unless (datesurg1 && datesurg2 && (datesurg1 == datesurg2))
      namesurg1 = answer.response.comparable_answer_or_nil_for_question_with_code('NameSurg1')
      break true unless namesurg1 == answer.comparable_answer
    }
  
    CrossQuestionValidation.register_checker 'special_namesurg3', lambda { |answer, ununused_related_answer, checker_params|
      #If DateSurg3=DateSurg2, NameSurg3 must not be the same as NameSurg2 (rule is on NameSurg3)
      raise 'Can only be used on question NameSurg3' unless answer.question.code == 'NameSurg3'
  
      datesurg2 = answer.response.comparable_answer_or_nil_for_question_with_code('DateSurg2')
      datesurg3 = answer.response.comparable_answer_or_nil_for_question_with_code('DateSurg3')
      break true unless (datesurg2 && datesurg3 && (datesurg2 == datesurg3))
      namesurg2 = answer.response.comparable_answer_or_nil_for_question_with_code('NameSurg2')
      break true unless namesurg2 == answer.comparable_answer
    }
  
    CrossQuestionValidation.register_checker 'special_cool_hours', lambda { |answer, ununused_related_answer, checker_params|
    #hours between |StartCoolDate+StartCoolTime - CeaseCoolDate+CeaseCoolTime| <=72
    raise 'Can only be used on question StartCoolDate' unless answer.question.code == 'StartCoolDate'

    start_cool_date = answer.response.comparable_answer_or_nil_for_question_with_code('StartCoolDate')
    start_cool_time = answer.response.comparable_answer_or_nil_for_question_with_code('StartCoolTime')
    cease_cool_date = answer.response.comparable_answer_or_nil_for_question_with_code('CeaseCoolDate')
    cease_cool_time = answer.response.comparable_answer_or_nil_for_question_with_code('CeaseCoolTime')
    break true unless start_cool_date && start_cool_time && cease_cool_date && cease_cool_time

    datetime1 = aggregate_date_time(start_cool_date, start_cool_time)
    datetime2 = aggregate_date_time(cease_cool_date, cease_cool_time)
    hour_difference = (datetime2 - datetime1) / 1.hour

    hour_difference <= 72
  }

  CrossQuestionValidation.register_checker 'special_immun', lambda { |answer, ununused_related_answer, checker_params|
    #If Gest<32|Wght<1500 and days(DOB and HomeDate|DiedDate)>=60, DateImmun must be a date
    # dob is the best place to put this, even though its a bit weird
    raise 'Can only be used on question DOB' unless answer.question.code == 'DOB'

    # we're ok if DateImmun is filled
    break true if answer.response.comparable_answer_or_nil_for_question_with_code('DateImmun')
    # ok if not premature
    break true unless CrossQuestionValidation.check_gest_wght(answer)

    home_date = answer.response.comparable_answer_or_nil_for_question_with_code('HomeDate')
    died_date = answer.response.comparable_answer_or_nil_for_question_with_code('DiedDate')
    # if home date is filled, use that
    if home_date
      days_diff = (home_date - answer.answer_value).to_i
      days_diff < 60
    elsif died_date
      # if died date is filled, use that
      days_diff = (died_date - answer.answer_value).to_i
      days_diff < 60
    else
      # neither is filled, its ok
      true
    end
  }

  CrossQuestionValidation.register_checker 'special_date_of_assess', lambda { |answer, ununused_related_answer, checker_params|
    #DateOfAssess must be greater than DOB+24 months (rule is on DateOfAssess)
    raise 'Can only be used on question DateOfAssess' unless answer.question.code == 'DateOfAssess'

    dob = answer.response.comparable_answer_or_nil_for_question_with_code('DOB')

    break true unless dob
    answer.answer_value > (dob + 24.months)
  }

  CrossQuestionValidation.register_checker 'special_height', lambda { |answer, ununused_related_answer, checker_params|
    #If years between DOB and DateOfAssess is greater than 3, Hght must be between 50 and 100 (rule on Hght)
    raise 'Can only be used on question Hght' unless answer.question.code == 'Hght'

    dob = answer.response.comparable_answer_or_nil_for_question_with_code('DOB')
    doa = answer.response.comparable_answer_or_nil_for_question_with_code('DateOfAssess')
    break true unless dob && doa

    if doa > (dob + 3.years)
      answer.comparable_answer >= 50 && answer.comparable_answer <= 100
    else
      true
    end
  }


  CrossQuestionValidation.register_checker 'special_length', lambda { |answer, ununused_related_answer, checker_params|
    #If years between DOB and DateOfAssess is less than or equal to 3, than Length must be between 50 and 100 (rule on Length)
    raise 'Can only be used on question Length' unless answer.question.code == 'Length'

    dob = answer.response.comparable_answer_or_nil_for_question_with_code('DOB')
    doa = answer.response.comparable_answer_or_nil_for_question_with_code('DateOfAssess')
    break true unless dob && doa

    if doa <= (dob + 3.years)
      answer.comparable_answer >= 50 && answer.comparable_answer <= 100
    else
      true
    end
  }

  CrossQuestionValidation.register_checker 'special_cochimplt', lambda { |answer, ununused_related_answer, checker_params|
    #If Heartest is 2 or 4 and Hearaid is 1 or 2, Cochlmplt must be 1 or 2 (rule on CochImplt)
    raise 'Can only be used on question CochImplt' unless answer.question.code == 'CochImplt'

    heartest = answer.response.comparable_answer_or_nil_for_question_with_code('Heartest')
    hearaid = answer.response.comparable_answer_or_nil_for_question_with_code('Hearaid')
    break true unless heartest && [2, 4].include?(heartest) && hearaid && [1, 2].include?(hearaid)
    [1, 2].include?(answer.comparable_answer)
  }

  CrossQuestionValidation.register_checker 'special_same_name_linf', lambda { |answer, ununused_related_answer, checker_params|
    #If Name_Linf2=Name_Linf1, days between Date_Linf1 and Date_Linf2 >14
    raise 'Can only be used on question Date_Linf2' unless answer.question.code == 'Date_Linf2'

    name1 = answer.response.comparable_answer_or_nil_for_question_with_code('Name_Linf1')
    name2 = answer.response.comparable_answer_or_nil_for_question_with_code('Name_Linf2')
    date1 = answer.response.comparable_answer_or_nil_for_question_with_code('Date_Linf1')
    date2 = answer.response.comparable_answer_or_nil_for_question_with_code('Date_Linf2')

    break true unless name1 && name2 && date1 && date2
    break true unless name1 == name2
    delta_days = (date1 - date2).to_i.abs
    delta_days > 14
  }
    
  end
end