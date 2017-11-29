module Admin
  class TeamsController < AdminController
    def index
      @teams = FilterTeams.new(filter_params).call(Team.all)
    end

    def new
      @team = Team.new
      @models = Model.team(@team)
      render :edit
    end

    def edit
      @team = Team.find(params[:id])
      @models = Model.team(@team)
    end

    def create
      @team = Team.new(team_params)

      if @team.save
        redirect_to edit_admin_team_path(@team), notice: 'Team was successfully created.'
      else
        @models = Model.team(@team)
        flash[:alert] =
          'We could not create the team. Please check the inputs in red'
        render :edit
      end
    end

    def update
      @team = Team.find(params[:id])
      if @team.update_attributes(team_params)
        redirect_to edit_admin_team_path(@team), notice: 'Team was successfully updated.'
      else
        @models = Model.team(@team)
        flash[:alert] =
          'We could not update the team. Please check the inputs in red'
        render :edit
      end
    end

    def destroy
      @team = Team.find(params[:id])
      @team.destroy
      redirect_to admin_teams_path, alert: @team.errors[:base].first
    end

    private

    def team_params
      params.require(:team).permit(
        :name, model_ids: [], users_attributes: [:id, :email, :name, :admin]
      )
    end

    def filter_params
      params.permit(:order_type, :order_direction, :search)
    end
  end
end
