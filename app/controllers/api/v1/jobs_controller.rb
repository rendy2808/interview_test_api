module Api
  module V1
    class JobsController < BaseController
      before_action :set_job, only: [:show, :update, :destroy]

      # GET /api/v1/jobs
      def index
        if params[:user_id]
          # let's caching here
          cache_job_key = "jobs_user_id_#{params[:user_id]}"
          @jobs =  Rails.cache.fetch(cache_job_key, expires_in: 10.minutes) do
            Job.where(user_id: params[:user_id].to_i)
          end
        else
          @jobs = Job.all
        end

        render json: @jobs
      end

      # GET /api/v1/jobs/1
      def show
        render json: @job
      end

      # POST /api/v1/jobs
      def create
        @job = Job.new(job_params)

        if @job.save
          render json: @job, status: :created
        else
          render json: { errors: @job.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/jobs/1
      def update
        if @job.update(job_params)
          render json: @job
        else
          render json: { errors: @job.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/jobs/1
      def destroy
        @job.destroy
        head :no_content
      end

      private

      def set_job
        @job = Job.find(params[:id].to_i)
      end

      def job_params
        params.require(:job).permit(:title, :description, :status, :user_id)
      end
    end
  end
end
