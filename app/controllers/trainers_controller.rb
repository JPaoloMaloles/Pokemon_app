class TrainersController < ApplicationController
  before_action :authenticate_user

  def show
    @trainer = Trainer.find_by(id: params["id"])
    render :show
  end

  def index
    @trainers = Trainer.all
    render :index
  end

  def create
    @trainer = Trainer.new(
      name: params["name"],
      title: params["title"],
      level: params["level"],
      experience: params["experience"],
      user_id: current_user.id,
    )
    @trainer.save
    render :show
  end

  def update
    @trainer = Trainer.find_by(id: params["id"])
    @trainer.update(
      name: params["name"] || params.name,
      title: params["title"] || params.title,
      level: params["level"] || params.level,
      experience: params["experience"] || params.experience,
    )
    render :show
  end

  def destroy
    trainer = Trainer.find_by(id: params["id"])
    trainer.destroy
    render json: { message: "Trainer has been deleted" }
  end
end
