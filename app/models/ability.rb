class Ability
  include CanCan::Ability

  def initialize(user)

    # aliases for user management actions
    alias_action :reject, to: :update
    alias_action :reject_as_spam, to: :update
    alias_action :deactivate, to: :update
    alias_action :activate, to: :update
    alias_action :edit_role, to: :update
    alias_action :update_role, to: :update
    alias_action :edit_approval, to: :update
    alias_action :approve, to: :update
    alias_action :access_requests, to: :read

    # aliases for responses actions
    alias_action :review_answers, to: :read

    # aliases for batch files actions
    alias_action :summary_report, to: :read
    alias_action :detail_report, to: :read

    alias_action :prepare_download, to: :download

    return unless user.role

    #All users can see all available surveys
    can :read, Survey

    if user.role.name == Role::DATA_PROVIDER_SUPERVISOR
      can :force_submit, BatchFile do |batch_file|
        batch_file.force_submittable?
      end
      can :submit, Response, hospital_id: user.hospital_id, submitted_status: Response::STATUS_UNSUBMITTED, validation_status: [Response::COMPLETE, Response::COMPLETE_WITH_WARNINGS]
    elsif user.role.name == Role::DATA_PROVIDER
      can :submit, Response, hospital_id: user.hospital_id, submitted_status: Response::STATUS_UNSUBMITTED, validation_status: Response::COMPLETE
    end

    case user.role.name
      when Role::SUPER_USER
        can :read, User
        can :update, User

        can :read, Response
        can :stats, Response
        can :download, Response
        can :batch_delete, Response
        can :confirm_batch_delete, Response
        can :perform_batch_delete, Response
        can :read, BatchFile

        can :manage, ConfigurationItem

      when Role::DATA_PROVIDER, Role::DATA_PROVIDER_SUPERVISOR
        can :read, Response, hospital_id: user.hospital_id, submitted_status: Response::STATUS_UNSUBMITTED
        can :create, Response, hospital_id: user.hospital_id
        can :update, Response, hospital_id: user.hospital_id, submitted_status: Response::STATUS_UNSUBMITTED

        can :read, BatchFile, hospital_id: user.hospital_id
        can :create, BatchFile, hospital_id: user.hospital_id

        can :submitted_baby_codes, Response
      else
        raise "Unknown role #{user.role.name}"
    end

  end
end
