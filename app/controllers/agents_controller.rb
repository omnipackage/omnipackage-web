# frozen_string_literal: true

class AgentsController < ::ApplicationController
  def index
    @agents_public = ::Agent.public_shared.order(created_at: :asc)
    @agents_private = current_user.private_agents.order(created_at: :asc)
  end

  def show
    @agent = find_agent
  end

  def new
    @agent = build_agent
  end

  def edit
    @agent = find_agent
  end

  def create # rubocop: disable Metrics/AbcSize, Metrics/MethodLength
    @agent = build_agent
    @agent.user = nil if current_user.root? && params[:public] == '1'
    @agent.name = params[:name]
    @agent.arch = params[:arch]
    @agent.apikey = ::SecureRandom.hex
    if @agent.valid?
      @agent.save!
      redirect_to(agents_path, notice: "Agent #{@agent.id} has been successfully created")
    else
      render(:new, status: :unprocessable_entity)
    end
  end

  def update # rubocop: disable Metrics/AbcSize
    @agent = find_agent
    @agent.user = nil if current_user.root? && params[:public] == '1'
    @agent.name = params[:name] if params[:name]
    @agent.arch = params[:arch] if params[:arch]
    if @agent.save
      redirect_to(agents_path(@agent.id), notice: "Agent #{@agent.id} has been successfully updated")
    else
      render(:edit, status: :unprocessable_entity)
    end
  end

  def destroy
    find_agent.destroy!
    redirect_to(agents_path, notice: 'Agent has been successfully deleted')
  end

  private

  def build_agent
    current_user.private_agents.build
  end

  def find_agent
    if current_user.root?
      ::Agent.all
    else
      current_user.private_agents
    end.find(params[:id])
  end
end
