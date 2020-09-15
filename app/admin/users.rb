ActiveAdmin.register User do
  permit_params :email, :admin, :first_name, :last_name, :username

  index do
    selectable_column
    id_column
    column :uid
    column :provider
    column :email
    column :first_name
    column :last_name
    column :username
    column :admin
    column :created_at
    column :updated_at
    actions
  end

  filter :uid
  filter :provider
  filter :email
  filter :first_name
  filter :last_name
  filter :username
  filter :admin
  filter :created_at
  filter :updated_at

  form do |f|
    f.object.admin = true unless f.object.persisted?
    f.inputs do
      f.input :email
      f.input :admin
      f.input :first_name
      f.input :last_name
      f.input :username
    end
    f.actions
  end
end
