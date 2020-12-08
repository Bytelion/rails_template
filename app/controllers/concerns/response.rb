# frozen_string_literal: true

module Response
  def json_response(object, status = :ok)
    render json: object, status: status
  end

  def json_collection(collection, serializer)
    ActiveModel::Serializer::CollectionSerializer.new(collection, serializer: serializer)
  end

  def json_item(item, serializer)
    serializer.new(item).to_json
  end
end
