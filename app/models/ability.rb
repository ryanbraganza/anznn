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

    return unless user.role

    #All users can see all available surveys
    can :read, Survey

    case user.role.name
      when Role::SuperUserRole
        can :read, User
        can :update, User

        can :read, Response
        can :read, BatchFile

      when Role::DATA_PROVIDER
        can :read, Response, hospital_id: user.hospital_id
        can :create, Response, hospital_id: user.hospital_id
        can :update, Response, hospital_id: user.hospital_id

        can :read, BatchFile, hospital_id: user.hospital_id
        can :create, BatchFile, hospital_id: user.hospital_id

      when Role::DATA_PROVIDER_SUPERVISOR
        can :read, BatchFile, hospital_id: user.hospital_id
        can :create, BatchFile, hospital_id: user.hospital_id

      else
        raise "Unknown role #{user.role.name}"
    end

  end
end
