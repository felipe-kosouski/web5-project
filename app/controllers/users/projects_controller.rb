class Users::ProjectsController < Users::BaseController
  before_action :set_project, only: [:show, :edit, :update, :destroy, :show_collaborator, :send_email]
  #load_and_authorize_resource

  def index
    @projects = current_user.projects + current_user.shared_projects

  end

  def edit
  end

  def show
    @boards = @project.boards.sorted
  end

  def new
    @project = current_user.projects.new
  end

  def create
    @project = current_user.projects.new(projects_params)

    if @project.save
      current_user.add_role :manager, @project
      flash[:notice] = "Projeto criado com sucesso"
      redirect_to [:users, @project]
    else
      flash[:error] = "Falha na criaçao do projeto"
      render :new
    end
  end

  def update
    if @project.update(projects_params)
      flash[:notice] = "Projeto atualizado com sucesso"
      redirect_to [:users, @project]
    else
      flash[:error] = "Falha na atualizaçao do projeto"
      render :edit
    end
  end

  def destroy
    @project.destroy
    flash[:notice] = "Projeto excluido com sucesso"
    redirect_to [:users, :projects]
  end

  def new_collaborators
    @project = current_user.projects.find(params[:project_id])
  end

  def add_collaborators
    @project = current_user.projects.find(params[:project_id])
    @project.collaborator_ids = params[:project][:collaborator_ids]
    if @project.collaborator_ids.empty?
      flash[:success] = "Lista de colaboradores atualizada."
    else
      send_email
      flash[:success] = "Lista de colaboradores atualizada. Um email foi enviado para cada um dos colaboradores."
    end

    redirect_to [:users, @project]
  end

  def show_collaborator
    @project = current_user.projects.find_by(id: params[:project_id])
    @collaborator = @project.collaborators.find(params[:id])
  end

  def set_role
    @project = current_user.projects.find_by(id: params[:project_id])
    role = params[:user][:roles]
    @collaborator = @project.collaborators.find(params[:id])

    @collaborator.roles = []

    if role == 'manager'
      @collaborator.add_role :manager, @project
    elsif role == 'master'
      @collaborator.add_role :master, @project
    elsif role == 'developer'
      @collaborator.add_role :developer, @project
    end

    redirect_back(fallback_location: users_project_path(:users, @project))
  end

  def send_email
    UserMailer.add_collaborator(@project).deliver_now!
  end

  private
  def set_project
    @project = current_user.projects.find_by(id: params[:id]) || current_user.shared_projects.find_by(id: params[:id])
  end

  def projects_params
    params.require(:project).permit(:name)
  end
end
