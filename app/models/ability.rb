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

    return unless user.role

    #All users can see all available surveys
    can :read, Survey

    case user.role.name
      when Role::SUPER_USER
        can :read, User
        can :update, User

        can :read, Response
        can :read, BatchFile

      when Role::DATA_PROVIDER, Role::DATA_PROVIDER_SUPERVISOR
        can :read, Response, hospital_id: user.hospital_id, submitted_status: Response::STATUS_UNSUBMITTED
        can :create, Response, hospital_id: user.hospital_id
        can :update, Response, hospital_id: user.hospital_id, submitted_status: Response::STATUS_UNSUBMITTED

        can :read, BatchFile, hospital_id: user.hospital_id
        can :create, BatchFile, hospital_id: user.hospital_id

        can :submit, Response do |response|
          if response.hospital_id == user.hospital_id
            status = response.status
            if status == Response::COMPLETE
              true
            elsif status == Response::COMPLETE_WITH_WARNINGS
              user.role.name == Role::DATA_PROVIDER_SUPERVISOR
            else
              false
            end
          else
            false
          end
        end
      else
        raise "Unknown role #{user.role.name}"
    end

  end
end
