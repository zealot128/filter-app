# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return if !user

    can [:edit, :update], User, id: user.id

    if user.admin?
      can :manage, Source
      can :manage, MailSubscription
      can :manage, Category
      can :manage, Setting
      can :manage, :twitter
      can :manage, User
      can :manage, :trends
      can :manage, Trends::Word
      can :manage, Trends::Trend
    elsif user.sources_admin?
      can :manage, Source
      can :manage, Category
      can :manage, :trends
      can :manage, Trends::Word
      can :manage, Trends::Trend
    end
  end
end
