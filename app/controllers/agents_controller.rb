class AgentsController < ::ApplicationController
  def index
    @pagination, @agents = ::Pagination.new(current_user.private_agents.order(created_at: :asc), self).call

    breadcrumb.add('My account', identity_account_path)
    breadcrumb.add('Agents', agents_path)
  end

  def show
    @agent = find_agent

    breadcrumb.add('My account', identity_account_path)
    breadcrumb.add('Agents', agents_path)
    breadcrumb.add(@agent.name)
  end

  def new
    @agent = build_agent

    breadcrumb.add('My account', identity_account_path)
    breadcrumb.add('Agents', agents_path)
    breadcrumb.add('New')
  end

  def edit
    @agent = find_agent

    breadcrumb.add('My account', identity_account_path)
    breadcrumb.add('Agents', agents_path)
    breadcrumb.add(@agent.name, agent_path(@agent))
    breadcrumb.add('Edit')
  end

  def create
    @agent = build_agent
    @agent.assign_attributes(agent_params)
    if @agent.valid?
      @agent.save!
      redirect_to(agents_path, notice: "Agent #{@agent.id} has been successfully created")
    else
      render(:new, status: :unprocessable_content)
    end
  end

  def update
    @agent = find_agent
    @agent.assign_attributes(agent_params)
    if @agent.save
      redirect_to(agents_path(@agent.id), notice: "Agent #{@agent.id} has been successfully updated")
    else
      render(:edit, status: :unprocessable_content)
    end
  end

  def destroy
    find_agent.destroy!
    redirect_to(agents_path, notice: 'Agent has been successfully deleted')
  end

  private

  def agent_params
    params.expect(agent: [:name, :arch])
  end

  def build_agent
    current_user.private_agents.build
  end

  def find_agent
    current_user.private_agents.find(params[:id])
  end
end
