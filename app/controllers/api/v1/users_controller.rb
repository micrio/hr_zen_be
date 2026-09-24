# frozen_string_literal: true

module Api
  module V1
    class UsersController < BaseController
      before_action :set_user, only: %i[show update destroy confirm]

      # GET /api/v1/users/me
      def me
        render_jsonapi(
          {
            user: Api::V1::UserSerializer.new(current_user).serializable_hash,
            organization: Api::V1::OrganizationSerializer.new(current_user.organization).serializable_hash
          },
          status: :ok
        )
      end

      # GET /api/v1/users
      def index
        authorize User

        users = Api::V1::ListUsersService.new(list_params).perform

        render_jsonapi(
          users.map { |user| Api::V1::UserSerializer.new(user).serializable_hash },
          meta: pagination_meta(users)
        )
      end

      # GET /api/v1/users/:id
      def show
        authorize @user

        render_jsonapi(Api::V1::UserSerializer.new(@user).serializable_hash)
      end

      # POST /api/v1/users
      def create
        authorize User

        user = Api::V1::CreateUserService.new(create_params).perform

        render_jsonapi(
          Api::V1::UserSerializer.new(user).serializable_hash,
          status: :created,
          meta: { message: "User created successfully." }
        )
      end

      # PATCH/PUT /api/v1/users/:id
      def update
        authorize @user

        user = Api::V1::UpdateUserService.new(update_params.merge(user: @user)).perform

        render_jsonapi(
          Api::V1::UserSerializer.new(user).serializable_hash,
          meta: { message: "User updated successfully." }
        )
      end

      # POST /api/v1/users/:id/confirm
      def confirm
        authorize @user

        user = Api::V1::ConfirmUserService.new(user: @user).perform

        render_jsonapi(
          Api::V1::UserSerializer.new(user).serializable_hash,
          meta: { message: "User confirmed successfully." }
        )
      end

      # DELETE /api/v1/users/:id
      def destroy
        authorize @user

        Api::V1::DeleteUserService.new(user: @user).perform

        render_jsonapi({}, meta: { message: "User deleted successfully." })
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def list_params
        params.permit(:page, :per_page, :query).to_h.symbolize_keys
      end

      def create_params
        permitted = permitted_user_params

        {
          organization: current_user.organization,
          user: permitted.slice(*Api::V1::CreateUserService::ATTRS),
          custom_fields: permitted[:custom_fields],
          role_names: params[:role_names]
        }
      end

      def update_params
        permitted = permitted_user_params

        {
          attributes: permitted.slice(*Api::V1::UpdateUserService::ATTRS),
          custom_fields: permitted.key?(:custom_fields) ? permitted[:custom_fields] : nil,
          role_names: params.key?(:role_names) ? params[:role_names] : nil
        }
      end

      def permitted_user_params
        params.require(:user).permit(
          *Api::V1::CreateUserService::ATTRS,
          *Api::V1::UpdateUserService::ATTRS,
          custom_fields: {}
        )
      end

      def pagination_meta(collection)
        {
          page: collection.current_page,
          per_page: collection.limit_value,
          total: collection.total_count
        }
      end
    end
  end
end
