class BugController < ApplicationController
  def index
    @bugs = Bug.search(params)
  end
  def create
    begin
      @bug = Bug.new(bug_params)

      @bug.number = Bug.next_bug_number(bug_api.token)
      @state = State.new(state_params)
      data = {}

      data[:bug] = { app_id: bug_api.id,
                  number: @bug_number,
                  status: 'new',
                  priority: params[:bug][:priority],
                  comment: params[:bug][:comment] }

      data[:state] = { devise: params[:state][:devise],
                    os: params[:state][:os],
                    memory: params[:state][:memory],
                    storage: params[:state][:storage] }

      queue = get_bunny_channel.queue(ENV['NEW_BUGS_QUEUE'], auto_delete: true)

      queue.subscribe do |delivery_info, properties, payload|
        ActiveRecord::Base.transaction do
          bug, state = JSON.parse(payload)
          Bug.create!(bug)
          State.create!(state)
        end
      end

      queue.publish(data, :routing_key => queue.name)

      render action: '/create/success', status: :ok

    end
  end

  def show
    begin
      @bug = Bug.where(number: params[:id], app_id: bug_api.id).first ||
          raise(ActiveRecord::RecordNotFound, "Bug #{params[:id]} is not found for this app")
    rescue => e
      if e.class == ActiveRecord::RecordNotFound
        error(e, 404)
      else
        error(e)
      end
    end
  end

  def count
    begin
      @count = bug_api.bug_count
    rescue => e
      error(e)
    end
    def show
      application_token = request.headers["application-token"]
      bug_number = params[:number]
      @bug = Bug.where("application_token = ? AND number = ?", application_token, bug_number)[0]
      if @bug
        render action: '/show/success', status: :ok
      else
        render action: '/show/error', status: :unprocessable_entity
      end
    end

    private

    def bug_params
      params.require(:bug).permit(:status, :priority, :comment)
    end

    def state_params
      params.require(:state).permit(:device, :os, :storage, :memory)
    end
  end

end

