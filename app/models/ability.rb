class Ability
  include CanCan::Ability

  def initialize(user)
    # alias edit_role to update_role so that they don't have to be declared separately
    alias_action :edit_role, to: :update_role
    alias_action :edit_approval, to: :approve

    # alias activate and deactivate to "activate_deactivate" so its just a single permission
    alias_action :deactivate, to: :activate_deactivate
    alias_action :activate, to: :activate_deactivate

    alias_action :access_requests, to: :read

    # alias reject_as_spam to reject so they are considered the same
    alias_action :reject_as_spam, to: :reject

    return unless user.role

    if Role.superuser_roles.include? user.role
      can :read, User
      can :update_role, User
      can :activate_deactivate, User
      can :reject, User
      can :approve, User

      can :manage, Survey

      can :manage, Response
      cannot :create, Response

      can :manage, BatchFile
    end

    if user.role.is_data_provider?
      can :manage, Response, hospital_id: user.hospital_id
      can :manage, BatchFile
    end

    #All users can see all available surveys
    can :read, Survey

  end
end
