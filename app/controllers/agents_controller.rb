# frozen_string_literal: true

class AgentsController < ::ApplicationController
  def index
    @pagination, @agents = ::Pagination.new(current_user.private_agents.order(created_at: :asc), self).call
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

  def create
    @agent = build_agent
    @agent.assign_attributes(agent_params)
    if @agent.valid?
      @agent.save!
      redirect_to(agents_path, notice: "Agent #{@agent.id} has been successfully created")
    else
      render(:new, status: :unprocessable_entity)
    end
  end

  def update
    @agent = find_agent
    @agent.assign_attributes(agent_params)
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

  def agent_params
    params.require(:agent).permit(:name, :arch)
  end

  def build_agent
    current_user.private_agents.build
  end

  def find_agent
    current_user.private_agents.find(params[:id])
  end
end
