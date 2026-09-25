# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Work management (teams, projects, tasks)", type: :request do
  let(:organization) { create(:organization) }

  before { AuthMatrix::Initializer.setup_workspace!(organization) }

  let(:admin) do
    create(:user, organization: organization).tap do |user|
      ActsAsTenant.with_tenant(organization) { user.assign_role("admin") }
    end
  end
  let(:alice) { create(:user, organization: organization) }
  let(:bob) { create(:user, organization: organization) }
  let(:member) { create(:user, organization: organization) }
  let(:headers) { auth_headers(admin) }

  describe "teams" do
    it "creates a team with a lead and members" do
      admin

      expect do
        post "/api/v1/teams",
             params: {
               team: { name: "Platform", description: "Core", lead_id: alice.id },
               member_ids: [ alice.id, bob.id ]
             },
             headers: headers,
             as: :json
      end.to change(Team, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(response_body.dig("data", "members_count")).to eq(2)
      expect(response_body.dig("data", "lead_name")).to eq(alice.full_name)
    end

    it "replaces members on update" do
      admin
      team = ActsAsTenant.with_tenant(organization) do
        Team.create!(name: "QA").tap do |t|
          t.team_members.create!(user: alice)
          t.team_members.create!(user: bob)
        end
      end

      patch "/api/v1/teams/#{team.id}",
            params: { team: { name: "QA" }, member_ids: [ bob.id ] },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:ok)
      expect(response_body.dig("data", "member_ids")).to eq([ bob.id ])
    end

    it "rejects a duplicate name" do
      admin
      ActsAsTenant.with_tenant(organization) { Team.create!(name: "Platform") }

      post "/api/v1/teams",
           params: { team: { name: "Platform" } },
           headers: headers,
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_body["details"]).to have_key("name")
    end

    it "forbids non-admins" do
      get "/api/v1/teams", headers: auth_headers(member), as: :json

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "projects" do
    let(:team) do
      ActsAsTenant.with_tenant(organization) { Team.create!(name: "Platform") }
    end

    it "creates a project and filters by status" do
      admin

      post "/api/v1/projects",
           params: {
             project: {
               name: "Onboarding", team_id: team.id, status: "active",
               start_date: "2026-01-01", end_date: "2026-03-31"
             }
           },
           headers: headers,
           as: :json

      expect(response).to have_http_status(:created)
      expect(response_body.dig("data", "team_name")).to eq("Platform")

      get "/api/v1/projects?status=active", headers: headers, as: :json
      expect(response_body["data"].map { |p| p["name"] }).to include("Onboarding")

      get "/api/v1/projects?status=archived", headers: headers, as: :json
      expect(response_body["data"]).to be_empty
    end

    it "rejects an inverted date range" do
      admin

      post "/api/v1/projects",
           params: { project: { name: "Bad", start_date: "2026-05-01", end_date: "2026-01-01" } },
           headers: headers,
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_body["details"]).to have_key("end_date")
    end
  end

  describe "tasks" do
    let(:project) do
      ActsAsTenant.with_tenant(organization) { Project.create!(name: "Onboarding") }
    end

    it "creates a task and filters by project/status" do
      admin

      post "/api/v1/tasks",
           params: {
             task: {
               project_id: project.id, assignee_id: alice.id, title: "Draft plan",
               status: "in_progress", priority: "high", due_date: "2026-02-01"
             }
           },
           headers: headers,
           as: :json

      expect(response).to have_http_status(:created)
      expect(response_body.dig("data", "assignee_name")).to eq(alice.full_name)

      get "/api/v1/tasks?project_id=#{project.id}&status=in_progress", headers: headers, as: :json
      expect(response_body["data"].length).to eq(1)

      get "/api/v1/tasks?status=done", headers: headers, as: :json
      expect(response_body["data"]).to be_empty
    end

    it "rejects an invalid status" do
      admin

      post "/api/v1/tasks",
           params: { task: { project_id: project.id, title: "X", status: "nope" } },
           headers: headers,
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_body["details"]).to have_key("status")
    end

    it "deletes a task" do
      admin
      task = ActsAsTenant.with_tenant(organization) do
        Task.create!(project: project, title: "X")
      end

      expect do
        delete "/api/v1/tasks/#{task.id}", headers: headers, as: :json
      end.to change(Task, :count).by(-1)
    end
  end
end
