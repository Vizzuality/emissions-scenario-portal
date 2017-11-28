module Admin
  class TeamsController < AdminController
    load_and_authorize_resource
    before_action :set_filter_params, only: [:index]

    def index
      @teams = FilterTeams.new(@filter_params).call(Team.all)
    end

    def new
      @team = Team.new
      set_available_models
      render :edit
    end

    def edit
      set_available_models
    end

    def create
      @team = Team.new(team_params)

      if @team.save
        redirect_to edit_admin_team_url(@team), notice: 'Team was successfully created.'
      else
        set_available_models
        flash[:alert] =
          'We could not create the team. Please check the inputs in red'
        render :edit
      end
    end

    def update
      if @team.update_attributes(team_params)
        redirect_to edit_admin_team_url(@team), notice: 'Team was successfully updated.'
      else
        set_available_models
        flash[:alert] =
          'We could not update the team. Please check the inputs in red'
        render :edit
      end
    end

    def destroy
      @team.destroy
      redirect_to admin_teams_url, notice: 'Team was successfully destroyed.'
    end

    private

    def set_available_models
      @models =
        if @team.present? && @team.persisted?
          Model.where('team_id IS NULL OR team_id = ?', @team.id)
        else
          Model.where('team_id IS NULL')
        end
    end

    def team_params
      params.require(:team).permit(
        :name, model_ids: [], users_attributes: [:id, :email, :name, :admin]
      )
    end
  end
end
