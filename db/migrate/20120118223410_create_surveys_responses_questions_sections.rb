class CreateSurveysResponsesQuestionsSections < ActiveRecord::Migration
  def change
    create_table :surveys do |t|
      t.timestamps
    end

    create_table :responses do |t|
      t.integer :survey_id
    end

    create_table :sections do |t|
      t.integer :survey_id
    end


    create_table :questions do |t|
      t.integer :section_id
    end

    create_table :answers do |t|
      t.integer :response_id
      t.integer :question_id
    end
  end
end
