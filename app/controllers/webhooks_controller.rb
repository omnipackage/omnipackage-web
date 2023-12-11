# frozen_string_literal: true

class WebhooksController < ::ApplicationController
  def index
    @project = find_project
    @webhooks = @project.webhooks.order(created_at: :desc)
  end

  def show
    @webhook = find_webhook
  end

  def new
    @webhook = find_project.webhooks.build
  end

  def create
    @webhook = find_project.webhooks.build(webhook_params)
    if @webhook.save
      redirect_to(project_webhooks_path(@webhook.project), notice: "Webhook has been successfully created")
    else
      render(:new, status: :unprocessable_entity)
    end
  end

  def update
    @webhook = find_webhook
    if @webhook.update(webhook_params)
      redirect_to(project_webhooks_path(@webhook.project), notice: "Webhook has been successfully updated")
    else
      render(:show, status: :unprocessable_entity)
    end
  end

  def destroy
    @webhook = find_webhook
    @webhook.destroy
    redirect_to(project_webhooks_path(@webhook.project), notice: "Webhook has been successfully deleted")
  end

  private

  def webhook_params
    params.require(:webhook).permit(:key, :secret)
  end

  def find_project
    current_user.projects.find(params[:project_id])
  end

  def find_webhook
    find_project.webhooks.find(params[:id])
  end
end
