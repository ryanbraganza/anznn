require 'spec_helper'

describe User do
  describe "Associations" do
    it { should belong_to(:role) }
    it { should have_many(:responses) }
    it { should belong_to(:hospital) }
  end

  describe "Named Scopes" do
    describe "Users Pending Approval Scope" do
      it "should return users that are unapproved ordered by email address" do
        u1 = Factory(:user, :status => 'U', :email => "fasdf1@intersect.org.au")
        u2 = Factory(:user, :status => 'A')
        u3 = Factory(:user, :status => 'U', :email => "asdf1@intersect.org.au")
        u2 = Factory(:user, :status => 'R')
        User.pending_approval.should eq([u3,u1])
      end
    end
    describe "Approved Users Scope" do
      it "should return users that are approved ordered by email address" do
        u1 = Factory(:user, :status => 'A', :email => "fasdf1@intersect.org.au")
        u2 = Factory(:user, :status => 'U')
        u3 = Factory(:user, :status => 'A', :email => "asdf1@intersect.org.au")
        u4 = Factory(:user, :status => 'R')
        u5 = Factory(:user, :status => 'D')
        User.approved.should eq([u3,u1])
      end
    end
    describe "Deactivated or Approved Users Scope" do
      it "should return users that are approved or deactivated" do
        u1 = Factory(:user, :status => 'A', :email => "fasdf1@intersect.org.au")
        u2 = Factory(:user, :status => 'U')
        u3 = Factory(:user, :status => 'A', :email => "asdf1@intersect.org.au")
        u4 = Factory(:user, :status => 'R')
        u5 = Factory(:user, :status => 'D', :email => "zz@inter.org")
        User.deactivated_or_approved.order(:email).should eq([u3, u1, u5])
      end
    end
    describe "Approved Administrators Scope" do
      it "should return users that are approved ordered by email address" do
        #super_role = Factory(:role, :name => "Administrator")
        other_role = Factory(:role, :name => "Other")
        u1 = Factory(:super_user, :status => 'A', :email => "fasdf1@intersect.org.au")
        u2 = Factory(:user, :status => 'A', :role => other_role)
        u3 = Factory(:super_user, :status => 'U')
        u4 = Factory(:super_user, :status => 'R')
        u5 = Factory(:super_user, :status => 'D')
        User.approved_superusers.should eq([u1])
      end
    end
  end

  describe "Approve Access Request" do
    it "should set the status flag to A" do
      user = Factory(:user, :status => 'U')
      user.approve_access_request
      user.status.should eq("A")
    end
  end

  describe "Reject Access Request" do
    it "should set the status flag to R" do
      user = Factory(:user, :status => 'U')
      user.reject_access_request
      user.status.should eq("R")
    end
  end

  describe "Status Methods" do
    context "Active" do
      it "should be active" do
        user = Factory(:user, :status => 'A')
        user.approved?.should be_true
      end
      it "should not be pending approval" do
        user = Factory(:user, :status => 'A')
        user.pending_approval?.should be_false
      end
    end

    context "Unapproved" do
      it "should not be active" do
        user = Factory(:user, :status => 'U')
        user.approved?.should be_false
      end
      it "should be pending approval" do
        user = Factory(:user, :status => 'U')
        user.pending_approval?.should be_true
      end
    end

    context "Rejected" do
      it "should not be active" do
        user = Factory(:user, :status => 'R')
        user.approved?.should be_false
      end
      it "should not be pending approval" do
        user = Factory(:user, :status => 'R')
        user.pending_approval?.should be_false
      end
    end
  end

  describe "Update password" do
    it "should fail if current password is incorrect" do
      user = Factory(:user, :password => "Pass.123")
      result = user.update_password({:current_password => "asdf", :password => "Pass.456", :password_confirmation => "Pass.456"})
      result.should be_false
      user.errors[:current_password].should eq ["is invalid"]
    end
    it "should fail if current password is blank" do
      user = Factory(:user, :password => "Pass.123")
      result = user.update_password({:current_password => "", :password => "Pass.456", :password_confirmation => "Pass.456"})
      result.should be_false
      user.errors[:current_password].should eq ["can't be blank"]
    end
    it "should fail if new password and confirmation blank" do
      user = Factory(:user, :password => "Pass.123")
      result = user.update_password({:current_password => "Pass.123", :password => "", :password_confirmation => ""})
      result.should be_false
      user.errors[:password].should eq ["can't be blank", "must be between 6 and 20 characters long and contain at least one uppercase letter, one lowercase letter, one digit and one symbol"]
    end
    it "should fail if confirmation blank" do
      user = Factory(:user, :password => "Pass.123")
      result = user.update_password({:current_password => "Pass.123", :password => "Pass.456", :password_confirmation => ""})
      result.should be_false
      user.errors[:password].should eq ["doesn't match confirmation"]
    end
    it "should fail if confirmation doesn't match new password" do
      user = Factory(:user, :password => "Pass.123")
      result = user.update_password({:current_password => "Pass.123", :password => "Pass.456", :password_confirmation => "Pass.678"})
      result.should be_false
      user.errors[:password].should eq ["doesn't match confirmation"]
    end
    it "should fail if password doesn't meet rules" do
      user = Factory(:user, :password => "Pass.123")
      result = user.update_password({:current_password => "Pass.123", :password => "Pass4567", :password_confirmation => "Pass4567"})
      result.should be_false
      user.errors[:password].should eq ["must be between 6 and 20 characters long and contain at least one uppercase letter, one lowercase letter, one digit and one symbol"]
    end
    it "should succeed if current password correct and new password ok" do
      user = Factory(:user, :password => "Pass.123")
      result = user.update_password({:current_password => "Pass.123", :password => "Pass.456", :password_confirmation => "Pass.456"})
      result.should be_true
    end
    it "should always blank out passwords" do
      user = Factory(:user, :password => "Pass.123")
      result = user.update_password({:current_password => "Pass.123", :password => "Pass.456", :password_confirmation => "Pass.456"})
      user.password.should be_blank
      user.password_confirmation.should be_blank
    end
  end

  describe "Find the number of superusers method" do
    it "should return true if there are at least 2 superusers" do
      user_1 = Factory(:super_user, :status => 'A', :email => 'user1@intersect.org.au')
      user_2 = Factory(:super_user, :status => 'A', :email => 'user2@intersect.org.au')
      user_3 = Factory(:super_user, :status => 'A', :email => 'user3@intersect.org.au')
      user_1.check_number_of_superusers(1, 1).should eq(true)
    end

    it "should return false if there is only 1 superuser" do
      user_1 = Factory(:super_user, :status => 'A', :email => 'user1@intersect.org.au')
      user_1.check_number_of_superusers(1, 1).should eq(false)
    end
    
    it "should return true if the logged in user does not match the user record being modified" do  
      research_role = Factory(:role, :name => 'Data Provider')
      user_1 = Factory(:super_user, :status => 'A', :email => 'user1@intersect.org.au')
      user_2 = Factory(:user, :role => research_role, :status => 'A', :email => 'user2@intersect.org.au')
      user_1.check_number_of_superusers(1, 2).should eq(true)
    end
  end

  describe "Validations" do
    it { should validate_presence_of :first_name }
    it { should validate_presence_of :last_name }
    it { should validate_presence_of :email }
    it { should validate_presence_of :password }

    it "should validate presence of a hospital UNLESS user has no role OR user is a super user" do
      #NB: this could also be if they are inactive instead of no role, however this works fine
      research_role = Factory(:role, :name => 'Data Provider')

      users = Array.new

      users << Factory(:super_user, :status => 'A', :email => 'user1@intersect.org.au')
      users << Factory(:user, :role => nil, :status => 'A', :email => 'user2@intersect.org.au')
      users << Factory(:user, :role => research_role, :status => 'A', :email => 'user3@intersect.org.au')

      users.each do |u|
        u.hospital = nil
      end

      users[0].should be_valid
      users[1].should be_valid
      users[2].should_not be_valid

    end

    it "should clear the hospital on before validation if a user becomes a super user" do
      super_role = Factory(:role, :name => Role::SUPER_USER)
      hospital = Factory(:hospital)
      user1 = Factory(:user, :status => 'A', :email => 'user1@intersect.org.au', :hospital => hospital)
      user1.hospital.should eq(hospital)

      user1.role = super_role
      user1.should be_valid
      user1.hospital.should eq(nil)

    end

    it "should never clear the hospital for regular users" do
      hospital = Factory(:hospital)
      user1 = Factory(:user, :status => 'A', :email => 'user1@intersect.org.au', :hospital => hospital)

      user1.should be_valid
      user1.save
      user1a = User.find_by_email('user1@intersect.org.au')
      user1a.hospital.should eq(hospital)


    end

    #password rules: at least one lowercase, uppercase, number, symbol
    # too short < 6
    it { should_not allow_value("AB$9a").for(:password) }
    # too long > 20
    it { should_not allow_value("Aa0$56789012345678901").for(:password) }
    # missing upper
    it { should_not allow_value("aaa000$$$").for(:password) }
    # missing lower
    it { should_not allow_value("AAA000$$$").for(:password) }
    # missing digit
    it { should_not allow_value("AAAaaa$$$").for(:password) }
    # missing symbol
    it { should_not allow_value("AAA000aaa").for(:password) }
    # ok
    it { should allow_value("AB$9aa").for(:password) }

    # check each of the possible symbols we allow
    it { should allow_value("AAAaaa000!").for(:password) }
    it { should allow_value("AAAaaa000@").for(:password) }
    it { should allow_value("AAAaaa000#").for(:password) }
    it { should allow_value("AAAaaa000$").for(:password) }
    it { should allow_value("AAAaaa000%").for(:password) }
    it { should allow_value("AAAaaa000^").for(:password) }
    it { should allow_value("AAAaaa000&").for(:password) }
    it { should allow_value("AAAaaa000*").for(:password) }
    it { should allow_value("AAAaaa000(").for(:password) }
    it { should allow_value("AAAaaa000)").for(:password) }
    it { should allow_value("AAAaaa000-").for(:password) }
    it { should allow_value("AAAaaa000_").for(:password) }
    it { should allow_value("AAAaaa000+").for(:password) }
    it { should allow_value("AAAaaa000=").for(:password) }
    it { should allow_value("AAAaaa000{").for(:password) }
    it { should allow_value("AAAaaa000}").for(:password) }
    it { should allow_value("AAAaaa000[").for(:password) }
    it { should allow_value("AAAaaa000]").for(:password) }
    it { should allow_value("AAAaaa000|").for(:password) }
    it { should allow_value("AAAaaa000\\").for(:password) }
    it { should allow_value("AAAaaa000;").for(:password) }
    it { should allow_value("AAAaaa000:").for(:password) }
    it { should allow_value("AAAaaa000'").for(:password) }
    it { should allow_value("AAAaaa000\"").for(:password) }
    it { should allow_value("AAAaaa000<").for(:password) }
    it { should allow_value("AAAaaa000>").for(:password) }
    it { should allow_value("AAAaaa000,").for(:password) }
    it { should allow_value("AAAaaa000.").for(:password) }
    it { should allow_value("AAAaaa000?").for(:password) }
    it { should allow_value("AAAaaa000/").for(:password) }
    it { should allow_value("AAAaaa000~").for(:password) }
    it { should allow_value("AAAaaa000`").for(:password) }
  end

  describe "Get superuser emails" do
    it "should find all approved superusers and extract their email address" do

      admin_role = Factory(:role, :name => "Admin") # Testing near matches - Role::SUPER_USER => "Administrator"
      super_1 = Factory(:super_user, :status => "A", :email => "a@intersect.org.au")
      super_2 = Factory(:super_user, :status => "U", :email => "b@intersect.org.au")
      super_3 = Factory(:super_user, :status => "A", :email => "c@intersect.org.au")
      super_4 = Factory(:super_user, :status => "D", :email => "d@intersect.org.au")
      super_5 = Factory(:super_user, :status => "R", :email => "e@intersect.org.au")
      admin = Factory(:user, :role => admin_role, :status => "A", :email => "f@intersect.org.au")

      supers = User.get_superuser_emails
      supers.should eq(["a@intersect.org.au", "c@intersect.org.au"])
    end
  end
  
end
