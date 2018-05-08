class Users::StoriesController < Users::BaseController
  before_action :set_project
  before_action :set_board
  before_action :set_story, only: [:show, :edit, :update, :destroy]

  def index
  end

  def new
    @story = @board.stories.new
  end

  def edit
  end

  def show
  end

  def create
    @story = @board.stories.new(stories_params)

    if @story.save
      flash[:notice] = "Estoria criada com sucesso"
      redirect_to [:users, @project]
    else
      flash[:error] = "Falha na criaçao da estoria"
      render :new
    end
  end

  def update
    if @story.update(stories_params)
      flash[:notice] = "Estoria atualizada com sucesso"
      redirect_to [:users, @project]
    else
      flash[:error] = "Falha na atualizaçao da estoria"
      render :edit
    end
  end

  def destroy
    @story.destroy
    flash[:notice] = "Estoria excluida com sucesso"
    redirect_to [:users, @project]
  end

  private
  def set_project
    @project = current_user.projects.find(params[:project_id])
  end

  def set_board
    @board = @project.boards.find(params[:board_id])
  end

  def set_story
    @story = @board.stories.find(params[:id])

end
  def stories_params
    params.require(:story).permit(:name, :position)
  end
end
